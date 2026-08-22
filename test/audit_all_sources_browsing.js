const fs = require('fs');
const https = require('https');
const http = require('http');

function fetch(url, headers = {}) {
  return new Promise((resolve) => {
    const isHttps = url.startsWith('https');
    const client = isHttps ? https : http;
    const req = client.get(url, { headers: { 'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)', 'Referer': 'https://google.com/', ...headers } }, (res) => {
      let data = [];
      res.on('data', chunk => data.push(chunk));
      res.on('end', () => resolve({ status: res.statusCode, headers: res.headers, body: Buffer.concat(data).toString('utf8') }));
    });
    req.on('error', (e) => resolve({ status: 500, error: e.message, body: '' }));
    req.setTimeout(8000, () => { req.destroy(); resolve({ status: 408, error: 'timeout', body: '' }); });
  });
}

function checkImage(url, referer) {
  return new Promise((resolve) => {
    if (!url || !url.startsWith('http')) return resolve({ ok: false, status: 0 });
    const isHttps = url.startsWith('https');
    const client = isHttps ? https : http;
    const req = client.get(url, { headers: { 'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)', 'Referer': referer || 'https://google.com/' } }, (res) => {
      let bytes = 0;
      res.on('data', chunk => { bytes += chunk.length; if (bytes > 5000) req.destroy(); });
      res.on('close', () => resolve({ ok: res.statusCode === 200 || res.statusCode === 206, status: res.statusCode, bytes }));
      res.on('end', () => resolve({ ok: res.statusCode === 200 || res.statusCode === 206, status: res.statusCode, bytes }));
    });
    req.on('error', (e) => resolve({ ok: false, status: 500, error: e.message }));
    req.setTimeout(6000, () => { req.destroy(); resolve({ ok: false, status: 408, error: 'timeout' }); });
  });
}

// -------------------------------------------------------------
// Source Browser Audit Engine
// -------------------------------------------------------------
class SourceAuditor {
  static extractBaseUrl(jsCode) {
    const match = jsCode.match(/["']baseUrl["']\s*:\s*["']([^"']+)["']/);
    return match ? match[1] : '';
  }

  static async auditSource(filename) {
    const jsPath = `/home/zoro/Documents/extensions/${filename}`;
    if (!fs.existsSync(jsPath)) return { name: filename, status: 'FILE_MISSING' };
    const jsCode = fs.readFileSync(jsPath, 'utf8');

    const baseUrl = SourceAuditor.extractBaseUrl(jsCode);
    const sourceName = filename.replace('.js', '').replace(/_/g, ' ');

    const report = {
      filename,
      sourceName,
      baseUrl: baseUrl || 'NONE',
      popular: { ok: false, count: 0, sampleTitle: '', coverOk: false, coverUrl: '' },
      latest: { ok: false, count: 0, sampleTitle: '' },
      search: { ok: false, count: 0, sampleTitle: '' },
      filtersSupported: jsCode.includes('getFilterList') || jsCode.includes('Filter'),
      issues: []
    };

    if (!baseUrl) {
      report.issues.push('Missing explicit baseUrl in header');
      return report;
    }

    // 1. Audit Popular Feed
    try {
      let popUrl = `${baseUrl}/`;
      const s = filename.toLowerCase();
      if (s.includes('weeb')) popUrl = `${baseUrl}/search?sort=Subscribers&order=Desc&page=1`;
      else if (s.includes('webtoon')) popUrl = `${baseUrl}/en/dailySchedule`;
      else if (s.includes('mangapill')) popUrl = `${baseUrl}/chapters?page=1`;
      else if (s.includes('mangahere')) popUrl = `${baseUrl}/directory/1.htm`;
      else if (s.includes('mangafreak')) popUrl = `${baseUrl}/Genre/All/1`;
      else if (s.includes('mangago')) popUrl = `${baseUrl}/genre/all/1/?f=1&o=1&sortby=view&e=`;
      else if (s.includes('mangadex')) popUrl = `https://api.mangadex.org/manga?limit=20&offset=0&includes[]=cover_art`;
      else if (s.includes('comick')) popUrl = `https://api.comick.fun/v1.0/search?sort=trending&page=1`;
      else if (s.includes('xoxo')) popUrl = `${baseUrl}/comic-list?sort=views&page=1`;
      else if (s.includes('read_comics') || s.includes('readcomiconline')) popUrl = `${baseUrl}/ComicList/MostPopular`;

      const res = await fetch(popUrl, { Referer: `${baseUrl}/` });
      if (res.status === 200 && res.body.length > 50) {
        // Extract items
        let titles = [];
        let covers = [];
        if (popUrl.includes('mangadex.org')) {
          try {
            const data = JSON.parse(res.body);
            if (data.data && Array.isArray(data.data)) {
              titles = data.data.map(d => Object.values(d.attributes.title)[0]);
            }
          } catch (_) {}
        } else {
          const titleMatches = [...res.body.matchAll(/<a[^>]*href=["']([^"']*(?:\/manga\/|\/series\/|\/comic\/|\/read\/|title_no=)[^"']*)["'][^>]*>([\s\S]*?)<\/a>/gi)];
          for (const tm of titleMatches) {
            const t = tm[2].replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim();
            if (t.length > 2 && t.length < 80 && !titles.includes(t) && !t.includes('Read') && !t.includes('Chapter')) {
              titles.push(t);
            }
          }
          const imgMatches = [...res.body.matchAll(/<img[^>]*src=["'](https?:\/\/[^"']+)["'][^>]*>|<img[^>]*data-src=["'](https?:\/\/[^"']+)["'][^>]*>/gi)];
          for (const im of imgMatches) {
            const c = im[1] || im[2];
            if (c && !c.includes('logo') && !c.includes('avatar') && !c.includes('favicon') && !c.includes('icon')) {
              covers.push(c);
            }
          }
        }

        if (titles.length > 0) {
          report.popular.ok = true;
          report.popular.count = titles.length;
          report.popular.sampleTitle = titles[0];
          if (covers.length > 0) {
            report.popular.coverUrl = covers[0];
            const imgTest = await checkImage(covers[0], `${baseUrl}/`);
            report.popular.coverOk = imgTest.ok;
            if (!imgTest.ok) report.issues.push(`Cover CDN blocked (HTTP ${imgTest.status})`);
          }
        } else {
          report.issues.push('0 titles parsed from popular feed');
        }
      } else {
        report.issues.push(`Popular HTTP ${res.status}`);
      }
    } catch (e) {
      report.issues.push(`Popular fetch failed: ${e.message}`);
    }

    // 2. Audit Search Feed
    try {
      let searchUrl = `${baseUrl}/search?q=one+piece`;
      const s = filename.toLowerCase();
      if (s.includes('weeb')) searchUrl = `${baseUrl}/search?text=one+piece`;
      else if (s.includes('webtoon')) searchUrl = `${baseUrl}/en/search?keyword=tower+of+god`;
      else if (s.includes('mangapill')) searchUrl = `${baseUrl}/quick-search?q=one+piece`;
      else if (s.includes('mangahere')) searchUrl = `${baseUrl}/search?title=one+piece`;
      else if (s.includes('mangafreak')) searchUrl = `${baseUrl}/Search/one+piece`;
      else if (s.includes('mangago')) searchUrl = `${baseUrl}/r/l_search/?name=one+piece`;
      else if (s.includes('mangadex')) searchUrl = `https://api.mangadex.org/manga?title=one+piece&limit=5`;

      const searchRes = await fetch(searchUrl, { Referer: `${baseUrl}/` });
      if (searchRes.status === 200 && searchRes.body.length > 50) {
        report.search.ok = true;
        report.search.count = searchRes.body.includes('piece') || searchRes.body.includes('Piece') || searchRes.body.includes('tower') ? 1 : 0;
      } else {
        report.issues.push(`Search endpoint HTTP ${searchRes.status}`);
      }
    } catch (e) {
      report.issues.push(`Search failed: ${e.message}`);
    }

    return report;
  }
}

async function runFullSourceAudit() {
  console.log('========================================================================================');
  console.log('🔬 AUDITING BROWSE, THUMBNAILS, SEARCH, AND FILTERS ACROSS ALL INSTALLED SOURCES');
  console.log('========================================================================================\n');

  const files = fs.readdirSync('/home/zoro/Documents/extensions').filter(f => f.endsWith('.js'));
  const results = [];

  for (const f of files) {
    const res = await SourceAuditor.auditSource(f);
    results.push(res);
  }

  console.log('----------------------------------------------------------------------------------------');
  console.log(String('SOURCE NAME').padEnd(22) + String('BASE URL').padEnd(28) + String('POPULAR').padEnd(10) + String('COVERS').padEnd(10) + String('SEARCH').padEnd(10) + String('STATUS'));
  console.log('----------------------------------------------------------------------------------------');

  for (const r of results) {
    const pop = r.popular.ok ? `✓ (${r.popular.count})` : '❌ 0';
    const cov = r.popular.coverOk ? '✓ 200 OK' : (r.popular.coverUrl ? '❌ 403/Err' : '—');
    const srch = r.search.ok ? '✓ OK' : '❌ Err';
    const status = r.issues.length === 0 ? '🟢 WORKING' : `🟡 ISSUES (${r.issues.join(', ')})`;
    console.log(
      String(r.sourceName).padEnd(22) +
      String(r.baseUrl).substring(0, 26).padEnd(28) +
      String(pop).padEnd(10) +
      String(cov).padEnd(10) +
      String(srch).padEnd(10) +
      status
    );
  }

  console.log('----------------------------------------------------------------------------------------\n');
}

runFullSourceAudit();

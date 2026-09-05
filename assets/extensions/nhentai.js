const mangayomiSources = [
  {
    "name": "nHentai",
    "lang": "en",
    "id": 559183086,
    "baseUrl": "https://nhentai.net",
    "apiUrl": "https://nhentai.net/api/v2",
    "iconUrl": "https://www.google.com/s2/favicons?sz=128&domain=https://nhentai.net",
    "typeSource": "single",
    "isManga": true,
    "isNsfw": true,
    "itemType": 0,
    "version": "1.1.1",
    "pkgPath": "javascript/manga/src/en/nhentai.js"
  }
];

const IMAGE_SERVER = "https://i3.nhentai.net/";
const THUMB_SERVER = "https://t3.nhentai.net/";
const API_BASE = "https://nhentai.net/api/v2";

class DefaultExtension extends MProvider {
  constructor() {
    super();
    this.client = new Client();
  }

  getHeaders() {
    return {
      "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.6832.64 Safari/537.36",
      "Referer": "https://nhentai.net/"
    };
  }

  _mapGallery(g) {
    if (!g || !g.id) return null;
    const title = (g.english_title || (g.title && (g.title.english || g.title.pretty || g.title.japanese)) || ("Gallery #" + g.id)).trim();
    let thumb = g.thumbnail || "";
    if (thumb) {
      if (!thumb.startsWith("http")) {
        thumb = THUMB_SERVER + thumb.replace(/^\//, '');
      }
    } else if (g.media_id) {
      thumb = `${THUMB_SERVER}galleries/${g.media_id}/thumb.jpg`;
    }
    return {
      name: title,
      imageUrl: thumb,
      link: `https://nhentai.net/g/${g.id}/`
    };
  }

  async getPopular(page) {
    const res = await this.client.get(`${API_BASE}/search?query=language:english&sort=popular&page=${page}&per_page=25`, this.getHeaders());
    const data = JSON.parse(res.body);
    const result = data.result || (Array.isArray(data) ? data : []);
    const list = result.map(g => this._mapGallery(g)).filter(Boolean);
    return { list: list, hasNextPage: list.length >= 20 };
  }

  async getLatestUpdates(page) {
    const res = await this.client.get(`${API_BASE}/galleries?page=${page}&per_page=25`, this.getHeaders());
    const data = JSON.parse(res.body);
    const result = data.result || (Array.isArray(data) ? data : []);
    const list = result.map(g => this._mapGallery(g)).filter(Boolean);
    return { list: list, hasNextPage: list.length >= 20 };
  }

  async search(query, page, filters) {
    let sort = "";
    const qParts = [];

    if (query && query.trim().length > 0) {
      qParts.push(query.trim());
    }

    if (filters && filters.length > 0) {
      for (const f of filters) {
        if (f.name === "Sort By") {
          if (f.values && f.state < f.values.length) sort = f.values[f.state].value;
        } else if (f.name === "Language") {
          if (f.state > 0 && f.values && f.state < f.values.length) qParts.push(`language:${f.values[f.state].value}`);
        } else if (f.name === "Category") {
          if (f.state > 0 && f.values && f.state < f.values.length) qParts.push(`category:${f.values[f.state].value}`);
        } else if (f.type_name === "GroupFilter" && Array.isArray(f.state)) {
          for (const cb of f.state) {
            if (cb.state) qParts.push(`tag:${cb.value}`);
          }
        }
      }
    }

    const finalQuery = qParts.join(" ");
    if (!finalQuery) return this.getPopular(page);

    let url = `${API_BASE}/search?query=${encodeURIComponent(finalQuery || "")}&page=${page}&per_page=25`;
    if (sort) url += `&sort=${sort}`;

    const res = await this.client.get(url, this.getHeaders());
    const data = JSON.parse(res.body);
    const result = data.result || (Array.isArray(data) ? data : []);
    const list = result.map(g => this._mapGallery(g)).filter(Boolean);
    return { list: list, hasNextPage: list.length >= 20 };
  }

  async getDetail(url) {
    const idMatch = url.match(/\/g\/(\d+)/);
    const id = idMatch ? idMatch[1] : url.split("?")[0].replace(/\/$/, "").split("/").pop();
    const res = await this.client.get(`${API_BASE}/galleries/${id}`, this.getHeaders());
    const g = JSON.parse(res.body);

    const title = ((g.title && (g.title.english || g.title.pretty || g.title.japanese)) || ("Gallery #" + id)).trim();

    let cover = (g.cover && g.cover.path) || (g.thumbnail && g.thumbnail.path) || "";
    if (cover && !cover.startsWith("http")) cover = IMAGE_SERVER + cover;

    const tags = (g.tags || []).map(t => t.name).filter(Boolean);
    const artists = (g.tags || []).filter(t => t.type === "artist").map(t => t.name).join(", ") || "Unknown";

    return {
      name: title,
      imageUrl: cover,
      description: `Tags: ${tags.join(", ")}\nPages: ${g.num_pages || 0}`,
      status: 1,
      author: artists,
      genre: tags,
      chapters: [{
        name: "Read Online",
        url: url,
        dateUpload: g.upload_date ? new Date(g.upload_date * 1000).toISOString().split('T')[0] : ""
      }]
    };
  }

  async getPageList(url) {
    const idMatch = url.match(/\/g\/(\d+)/);
    const id = idMatch ? idMatch[1] : url.split("?")[0].replace(/\/$/, "").split("/").pop();
    const res = await this.client.get(`${API_BASE}/galleries/${id}`, this.getHeaders());
    const g = JSON.parse(res.body);

    return (g.pages || []).map(p => {
      let path = p.path || "";
      if (path && !path.startsWith("http")) path = IMAGE_SERVER + path;
      return { url: path, headers: this.getHeaders() };
    }).filter(p => p.url);
  }

  getFilterList() {
    return [
      {
        type_name: "SelectFilter",
        name: "Sort By",
        state: 0,
        values: [
          { type_name: "SelectOption", name: "Popular All Time", value: "popular" },
          { type_name: "SelectOption", name: "Popular Today", value: "popular-today" },
          { type_name: "SelectOption", name: "Popular This Week", value: "popular-week" },
          { type_name: "SelectOption", name: "Recent", value: "date" }
        ]
      },
      {
        type_name: "SelectFilter",
        name: "Language",
        state: 0,
        values: [
          { type_name: "SelectOption", name: "All", value: "" },
          { type_name: "SelectOption", name: "English", value: "english" },
          { type_name: "SelectOption", name: "Japanese", value: "japanese" },
          { type_name: "SelectOption", name: "Chinese", value: "chinese" }
        ]
      },
      {
        type_name: "SelectFilter",
        name: "Category",
        state: 0,
        values: [
          { type_name: "SelectOption", name: "All", value: "" },
          { type_name: "SelectOption", name: "Doujinshi", value: "doujinshi" },
          { type_name: "SelectOption", name: "Manga", value: "manga" },
          { type_name: "SelectOption", name: "Artist CG", value: "artistcg" },
          { type_name: "SelectOption", name: "Game CG", value: "gamecg" }
        ]
      },
      {
        type_name: "GroupFilter",
        name: "Tags",
        state: [
          { type_name: "CheckBox", name: "Schoolgirl", value: "schoolgirl", state: false },
          { type_name: "CheckBox", name: "Romance", value: "romance", state: false },
          { type_name: "CheckBox", name: "Yuri", value: "yuri", state: false },
          { type_name: "CheckBox", name: "Yaoi", value: "yaoi", state: false },
          { type_name: "CheckBox", name: "Harem", value: "harem", state: false },
          { type_name: "CheckBox", name: "Milf", value: "milf", state: false },
          { type_name: "CheckBox", name: "NTR", value: "ntr", state: false },
          { type_name: "CheckBox", name: "Vanilla", value: "vanilla", state: false }
        ]
      }
    ];
  }
}

// prettier-ignore
const mangayomiSources = [{
    "name": "Webtoons",
    "id": 1938475629,
    "langs": ["en", "fr", "id", "th", "es", "zh", "de"],
    "baseUrl": "https://www.webtoons.com",
    "apiUrl": "",
    "iconUrl": "https://upload.wikimedia.org/wikipedia/commons/0/09/Naver_Line_Webtoon_logo.png",
    "typeSource": "single",
    "isManga": true,
    "isNsfw": false,
    "version": "1.1.0",
    "dateFormat": "",
    "dateFormatLocale": "",
    "pkgPath": "javascript/manga/src/en/webtoons.js"
}];

class DefaultExtension extends MProvider {
  getHeaders(url) {
    return {
      "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
      "Referer": "https://www.webtoons.com/"
    };
  }
  get headers() {
    return this.getHeaders();
  }
  get mobileUrl() {
    return "https://m.webtoons.com";
  }

  getFormattedUrl(preferenceKey) {
    const preference = new SharedPreferences();
    let url = preference.get(preferenceKey) || this.source.baseUrl;

    return url.endsWith("/") ? url.slice(0, -1) : url;
  }

  getBaseUrl() {
    return this.getFormattedUrl("domain_url");
  }

  getMobileUrl() {
    return this.getFormattedUrl("mobile_url");
  }

  mangaFromElement(doc) {
    const list = [];
    const seen = new Set();
    for (const el of doc.select(
      `div.webtoon_list_wrap li a, ul.webtoon_list li a, ul.card_lst li a, a[href*='title_no=']`,
    )) {
      const img = el.selectFirst("img");
      if (!img) continue;
      let imageUrl = img.getSrc || img.attr("src") || "";
      if (imageUrl.startsWith("//")) imageUrl = `https:${imageUrl}`;
      const titleEl = el.selectFirst("strong.title, p.subj, .subj, strong, p.title");
      const name = titleEl ? titleEl.text.trim() : "";
      const link = el.getHref || el.attr("href") || "";
      if (name && link && !link.includes('/viewer?') && !seen.has(link)) {
        seen.add(link);
        list.push({ name, imageUrl, link });
      }
    }

    return list;
  }

  async getPopular(page) {
    const res = await new Client().get(
      `${this.getBaseUrl()}/${this.langCode()}/originals`,
    );
    const doc = new Document(res.body);

    return {
      list: this.mangaFromElement(doc),
      hasNextPage: false,
    };
  }

  async getLatestUpdates(page) {
    const res = await new Client().get(
      `${this.getBaseUrl()}/${this.langCode()}/originals?sortOrder=UPDATE`,
    );
    const doc = new Document(res.body);

    return {
      list: this.mangaFromElement(doc),
      hasNextPage: false,
    };
  }

  async search(query, page, filters) {
    const keyword = (query || "").trim().replace(/\s+/g, "+");
    let url = `${this.getBaseUrl()}/${this.langCode()}`;
    let hasNextPage = false;

    const getFilterValue = (type, defaultValue = "") => {
      if (!filters || !Array.isArray(filters)) return defaultValue;
      const filter = filters.find((f) => f.type === type);
      return filter?.values?.[filter.state]?.value ?? defaultValue;
    };
    if (keyword) {
      const searchType = getFilterValue("searchType");
      url += searchType ? `/search/${searchType}?keyword=${keyword}&page=${page}` : `/search?keyword=${keyword}&page=${page}`;
    } else {
      const sortOrder = getFilterValue("sortOrder");
      const rankingType = getFilterValue("rankingType");
      const weekday = getFilterValue("weekday");
      const genreType = getFilterValue("genre");

      if (rankingType) {
        url += `/ranking/${rankingType}`;
      } else if (weekday) {
        url += `/originals/${weekday}?sortOrder=${sortOrder}`;
      } else if (genreType) {
        url += `/genres?genre=${genreType.toUpperCase()}&sortOrder=${sortOrder}`;
      }
    }

    const res = await new Client().get(url);
    const doc = new Document(res.body);
    const list = this.mangaFromElement(doc);
    if (keyword) {
      hasNextPage = list.length !== 0;
    }

    return {
      list,
      hasNextPage,
    };
  }

  async getDetail(url) {
    let cleanUrl = (url || "").replace(/&amp;/g, "&").trim();
    if (!cleanUrl.startsWith("http://") && !cleanUrl.startsWith("https://")) {
      const base = this.getBaseUrl() || "https://www.webtoons.com";
      cleanUrl = `${base.endsWith("/") ? base.slice(0, -1) : base}${cleanUrl.startsWith("/") ? "" : "/"}${cleanUrl}`;
    }
    let res = await new Client().get(cleanUrl, this.getHeaders(cleanUrl));
    let doc = new Document(res.body);

    const nameEl = doc.selectFirst("h1.subj, h3.subj, .subj_info h1, .detail_header .subj, .info h1, .subj");
    const name = nameEl ? nameEl.text.trim() : "Webtoon";

    const genre = [];
    const genreEls = doc.select("p.genre, .genre, span.genre");
    for (const g of genreEls) {
      const t = g.text.trim();
      if (t && !genre.includes(t)) genre.push(t);
    }

    const authorEl = doc.selectFirst("div.author_area, a.author, .author_area, .author");
    const author = authorEl ? authorEl.text.replace(/\s+/g, " ").replace(/author info/g, "").trim() : "";

    const dayInfoEl = doc.selectFirst("p.day_info, .day_info, .txt_ico_up");
    const dayInfoText = dayInfoEl ? dayInfoEl.text : "";
    const status = (dayInfoText.includes("UP") || dayInfoText.includes("EVERY") || dayInfoText.includes("NOUVEAU")) ? 0 :
                   (dayInfoText.includes("END") || dayInfoText.includes("TERMINÉ") || dayInfoText.includes("COMPLETED")) ? 1 : 0;

    const descEl = doc.selectFirst("p.summary, .summary, .detail_info p");
    const description = descEl ? descEl.text.replace(/\s+/g, " ").trim() : "";

    // chapters
    const chapters = [];
    const seenCh = new Set();

    const parsePageEpisodes = (d) => {
      const links = d.select("a[href*='episode_no='], ul#_listUl li a, ul.detail_list li a, li._episodeItem a, a[href*='/viewer']");
      for (const el of links) {
        var chUrl = el.attr("href") || "";
        if (!chUrl || typeof chUrl !== 'string' || !chUrl.includes("/viewer")) continue;
        chUrl = chUrl.replace(/&amp;/g, "&");
        if (!chUrl.startsWith("http")) {
          chUrl = `https://www.webtoons.com${chUrl.startsWith("/") ? "" : "/"}${chUrl}`;
        }

        const nameEl = el.selectFirst("span.subj, span.ellipsis, .tx") || el.selectFirst("img");
        const name = (nameEl ? (nameEl.text || nameEl.attr("alt")) : "Episode").trim();
        const dateEl = el.selectFirst("span.date, span.tx");
        
        // Dedup logic: keep if it's new, OR if we previously saved a generic fallback but this one has a real name
        if (seenCh.has(chUrl)) {
            // Already seen. But check if the old one had a generic name and this one doesn't.
            const oldIdx = chapters.findIndex(c => c.url === chUrl);
            if (oldIdx !== -1 && chapters[oldIdx].name === "Episode" && name !== "Episode") {
                // Update it
                chapters.splice(oldIdx, 1);
            } else {
                continue;
            }
        }
        seenCh.add(chUrl);
        var dateUpload = "";
        if (dateEl && dateEl.text) {
          const t = dateEl.text.trim();
          const parsed = this.formatDateString(t, this.source.lang || (this.source.langs && this.source.langs[0]) || "en") || Date.parse(t) || 0;
          if (!isNaN(parsed) && parsed > 0) {
            dateUpload = parsed.toString();
          } else {
            dateUpload = t;
          }
        }
        chapters.push({
          name: name || "Episode",
          url: chUrl,
          dateUpload: dateUpload
        });
      }
    };

    parsePageEpisodes(doc);

    // Fetch remaining episode pages only if pagination links exist (cap at 3 pages to avoid network storms)
    const hasNextOnFirst = doc.selectFirst("a.pg_next, div.paginate a, .paginate a");
    if (hasNextOnFirst) {
      let p = 2;
      while (p <= 3) {
        try {
          const pUrl = `${url}${url.includes('?') ? '&' : '?'}page=${p}`;
          const pRes = await new Client().get(pUrl, this.getHeaders(pUrl));
          const pDoc = new Document(pRes.body);
          const countBefore = chapters.length;
          parsePageEpisodes(pDoc);
          if (chapters.length === countBefore || !pDoc.selectFirst("a.pg_next, a.pg_page, .paginate a")) {
            // No more episodes or reached end of pagination
            break;
          }
          p++;
        } catch (_) {
          break;
        }
      }
    }

    if (chapters.length === 0) {
      try {
        const mobUrl = url.replace(this.getBaseUrl(), this.getMobileUrl());
        res = await new Client().get(mobUrl, this.getHeaders(mobUrl));
        doc = new Document(res.body);
        for (const el of doc.select("ul#_episodeList li, ul._episodeList li, li[id*=episode]")) {
          const linkEl = el.selectFirst("a");
          if (!linkEl) continue;
          let mUrl = linkEl.getHref || linkEl.attr("href") || "";
          if (mUrl) {
            mUrl = mUrl.replace(/&amp;/g, "&");
            mUrl = mUrl.replace(this.getMobileUrl(), this.getBaseUrl());
            if (!mUrl.startsWith("http")) {
              mUrl = `https://www.webtoons.com${mUrl.startsWith("/") ? "" : "/"}${mUrl}`;
            }
            const numEl = el.selectFirst(".tx");
            let epName = linkEl.selectFirst(".subj span")?.text || linkEl.selectFirst(".subj")?.text || linkEl.selectFirst(".sub_title")?.text || "Episode";
            if (numEl) {
              epName = `#${numEl.text.trim()} ${epName.trim()}`;
            }
            const dateUpload = el.selectFirst(".sub_info .date, .date")?.text || "";

            if (!chapters.some(c => c.url === mUrl)) {
              chapters.push({
                name: epName.trim() || "Episode",
                url: mUrl,
                dateUpload: dateUpload
              });
            }
          }
        }
      } catch (_) {}
    }

    return {
      name,
      link: url,
      genre,
      description,
      author,
      status,
      chapters: chapters,
    };
  }

  langCode() {
    const lang = (this.source && (this.source.lang || (this.source.langs && this.source.langs[0]))) || "en";
    return {
      en: "en",
      fr: "fr",
      id: "id",
      th: "th",
      es: "es",
      zh: "zh-hant",
      de: "de",
    }[lang] || "en";
  }

  formatDateString(dateStr, lang) {
    // Month translations for supported languages
    const monthTranslations = {
      en: [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
      ],
      fr: [
        "janv.",
        "févr.",
        "mars",
        "avr.",
        "mai",
        "juin",
        "juil.",
        "août",
        "sept.",
        "oct.",
        "nov.",
        "déc.",
      ],
      id: ["Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agt", "Sep", "Okt", "Nov", "Des"],
      th: [
        "ม.ค.",
        "ก.พ.",
        "มี.ค.",
        "เม.ย.",
        "พ.ค.",
        "มิ.ย.",
        "ก.ค.",
        "ส.ค.",
        "ก.ย.",
        "ต.ค.",
        "พ.ย.",
        "ธ.ค.",
      ],
      es: [
        "ene.",
        "feb.",
        "mar.",
        "abr.",
        "may.",
        "jun.",
        "jul.",
        "ago.",
        "sep.",
        "oct.",
        "nov.",
        "dic.",
      ],
      zh: [], // No need for month names; uses yyyy年MM月dd日 format
      de: [], // No need for month names; uses dd.MM.yyyy format
    };
    const months = (monthTranslations && lang && monthTranslations[lang]) ? monthTranslations[lang] : (monthTranslations["en"] || []);
    let parts;
    let month;
    let day;
    let year;
    // Handle formats based on the language
    switch (lang) {
      case "zh": {
        // Expected format: yyyy年MM月dd日
        const match = dateStr.match(/(\d{4})年(\d{1,2})月(\d{1,2})日/);
        if (match) {
          year = match[1];
          month = match[2];
          day = match[3];
        }
        break;
      }
      case "de":
        // Expected format: dd.MM.yyyy
        parts = dateStr.split(".");
        if (parts.length === 3) {
          month = parts[1];
          day = parts[0];
          year = parts[2];
        }
        break;
      case "es":
      case "fr":
      case "id":
      case "th":
        // Expected format: dd MMM yyyy
        parts = dateStr.split(" ");
        if (parts.length === 3) {
          month = months.indexOf(parts[1]) + 1;
          day = parts[0];
          year = parts[2];
        }
        break;
      default:
        parts = dateStr.split(" ");
        if (parts.length === 3) {
          month = months.indexOf(parts[0]) + 1;
          day = parts[1].replace(",", "");
          year = parts[2];
        }
    }
    if (!month || !year || !day) {
      return Date.now();
    }
    return `${year}-${month.toString().padStart(2, "0")}-${day.toString().padStart(2, "0")}`;
  }

  async getPageList(url) {
    let cleanUrl = url.replace(/&amp;/g, "&").trim();
    if (!cleanUrl.startsWith("http://") && !cleanUrl.startsWith("https://")) {
      const base = this.getBaseUrl() || "https://www.webtoons.com";
      cleanUrl = `${base.endsWith("/") ? base.slice(0, -1) : base}${cleanUrl.startsWith("/") ? "" : "/"}${cleanUrl}`;
    }

    const fetchImagesFromDoc = (doc) => {
      const urls = [];
      const seen = new Set();
      let images = [];
      if (typeof doc.select === "function") {
        images = doc.select("img._images");
        if (!images || images.length === 0) {
          images = doc.select("div#_imageList img, div.viewer_img img, .viewer_lst img, div.viewer img, div.viewer_img_lst img");
        }
      } else if (typeof doc.querySelectorAll === "function") {
        images = doc.querySelectorAll("img._images");
        if (!images || images.length === 0) {
          images = doc.querySelectorAll("div#_imageList img, div.viewer_img img, .viewer_lst img, div.viewer img, div.viewer_img_lst img");
        }
      }
      for (let i = 0; i < images.length; i++) {
        const img = images[i];
        const src = (typeof img.attr === "function" ? (img.attr("data-url") || img.attr("data-src") || img.attr("src")) : (img.getSrc || img.getAttribute?.("data-url") || img.getAttribute?.("data-src") || img.getAttribute?.("src"))) || "";
        if (src && !src.includes("sp_error") && !src.includes("banner") && !src.includes("logo") && !src.includes("bg_transparency") && !src.includes("Thumb") && !src.includes("thumb_") && !src.includes("type=f218") && !src.includes("type=a92") && !seen.has(src)) {
          seen.add(src);
          urls.push({
            url: src.trim(),
            headers: { "Referer": "https://www.webtoons.com/" }
          });
        }
      }
      return urls;
    };

    // If cleanUrl is already a valid slugged viewer URL, try it directly
    const isGenericViewer = cleanUrl.includes('/viewer?') && !cleanUrl.match(/\/ep[^\/]+\/viewer/i);
    if (!isGenericViewer) {
      try {
        const res = await new Client().get(cleanUrl, this.getHeaders(cleanUrl));
        if (res && res.statusCode === 200 && res.body) {
          const doc = new Document(res.body);
          const urls = fetchImagesFromDoc(doc);
          if (urls.length > 0) return urls;
        }
      } catch (_) {}
    }

    // Auto-recovery for generic slugless viewer URLs or 500 error URLs:
    // Extract title_no and episode_no, find the exact viewer URL from the list page in 1 fast calculation
    const titleMatch = cleanUrl.match(/[?&]title_no=(\d+)/i);
    const epMatch = cleanUrl.match(/[?&]episode_no=(\d+)/i);
    if (titleMatch && epMatch) {
      try {
        const titleNo = titleMatch[1];
        const epNo = parseInt(epMatch[1], 10);
        let listBase = cleanUrl.split('/viewer')[0].replace(/\/ep[^\/]+$/i, '');
        if (!listBase.includes('/list')) {
          listBase = `${listBase}/list`;
        }
        const listUrl = `${listBase}?title_no=${titleNo}`;

        // 1. Fetch page 1 of list
        const p1Url = `${listUrl}&page=1`;
        const p1Res = await new Client().get(p1Url, this.getHeaders(p1Url));
        if (p1Res && p1Res.body) {
          const p1Doc = new Document(p1Res.body);
          const p1Links = p1Doc.select("ul#_listUl li a, #_episodeList li a, li._episodeItem a, a[href*='episode_no=']");
          
          for (let i = 0; i < p1Links.length; i++) {
            let directUrl = (typeof p1Links[i].attr === "function" ? p1Links[i].attr("href") : p1Links[i].getHref) || "";
            if (directUrl && directUrl.includes(`episode_no=${epNo}`)) {
              if (!directUrl.startsWith("http")) directUrl = `https://www.webtoons.com${directUrl.startsWith("/") ? "" : "/"}${directUrl}`;
              const dRes = await new Client().get(directUrl, this.getHeaders(directUrl));
              if (dRes && dRes.body) {
                const dDoc = new Document(dRes.body);
                const urls = fetchImagesFromDoc(dDoc);
                if (urls.length > 0) return urls;
              }
            }
          }

          // 2. If not on page 1, calculate candidate pages: Webtoons lists ~10 episodes per page descending
          if (p1Links.length > 0) {
            const firstEpUrl = (typeof p1Links[0].attr === "function" ? p1Links[0].attr("href") : p1Links[0].getHref) || "";
            const maxEpMatch = firstEpUrl.match(/[?&]episode_no=(\d+)/);
            if (maxEpMatch) {
              const maxEp = parseInt(maxEpMatch[1], 10);
              const estPage = Math.max(1, Math.floor((maxEp - epNo) / 10) + 1);
              const candidatePages = [estPage, estPage + 1, estPage - 1].filter((p) => p >= 1 && p !== 1);

              for (const pageNum of candidatePages) {
                const pTargetUrl = `${listUrl}&page=${pageNum}`;
                const ptRes = await new Client().get(pTargetUrl, this.getHeaders(pTargetUrl));
                if (ptRes && ptRes.body) {
                  const ptDoc = new Document(ptRes.body);
                  const ptLinks = ptDoc.select("ul#_listUl li a, #_episodeList li a, li._episodeItem a, a[href*='episode_no=']");
                  for (let i = 0; i < ptLinks.length; i++) {
                    let directUrl = (typeof ptLinks[i].attr === "function" ? ptLinks[i].attr("href") : ptLinks[i].getHref) || "";
                    if (directUrl && directUrl.includes(`episode_no=${epNo}`)) {
                      if (!directUrl.startsWith("http")) directUrl = `https://www.webtoons.com${directUrl.startsWith("/") ? "" : "/"}${directUrl}`;
                      const dRes = await new Client().get(directUrl, this.getHeaders(directUrl));
                      if (dRes && dRes.body) {
                        const dDoc = new Document(dRes.body);
                        const urls = fetchImagesFromDoc(dDoc);
                        if (urls.length > 0) return urls;
                      }
                    }
                  }
                }
              }
            }
          }
        }
      } catch (_) {}
    }

    return [];
  }

  getFilterList() {
    return [
      {
        type: "header",
        name: "Filter Priority: Search > Ranking > Day > Genre | Sort applies to Day/Genre",
        type_name: "HeaderFilter",
      },
      {
        type: "separator",
        type_name: "SeparatorFilter",
      },

      {
        type: "searchType",
        name: "Search Type",
        type_name: "SelectFilter",
        values: [
          {
            type_name: "SelectOption",
            name: "Originals",
            value: "originals",
          },
          {
            type_name: "SelectOption",
            name: "Canvas",
            value: "canvas",
          },
        ],
        state: 0,
      },
      {
        type: "separator",
        type_name: "SeparatorFilter",
      },

      {
        type: "rankingType",
        name: "Ranking Category",
        type_name: "SelectFilter",
        values: [
          {
            type_name: "SelectOption",
            name: "Not Selected",
            value: "",
          },
          {
            type_name: "SelectOption",
            name: "Trending",
            value: "trending",
          },
          {
            type_name: "SelectOption",
            name: "Popular",
            value: "popular",
          },
          {
            type_name: "SelectOption",
            name: "Originals",
            value: "originals",
          },
          {
            type_name: "SelectOption",
            name: "Canvas",
            value: "canvas",
          },
        ],
      },
      {
        type: "separator",
        type_name: "SeparatorFilter",
      },

      {
        type: "sortOrder",
        name: "Sort By (For Schedule & Genres)",
        type_name: "SelectFilter",
        values: [
          { type_name: "SelectOption", name: "Popular (MANA)", value: "MANA" },
          { type_name: "SelectOption", name: "Likes", value: "LIKEIT" },
          { type_name: "SelectOption", name: "Newest", value: "UPDATE" },
        ],
        state: 0,
        appliesTo: ["weekday", "genre"],
      },

      {
        type: "weekday",
        name: "Update Schedule",
        type_name: "SelectFilter",
        values: [
          {
            type_name: "SelectOption",
            name: "Day",
            value: "",
            data: "",
          },
          {
            type_name: "SelectOption",
            name: "Monday",
            value: "monday",
            data: "MONDAY",
          },
          {
            type_name: "SelectOption",
            name: "Tuesday",
            value: "tuesday",
            data: "TUESDAY",
          },
          {
            type_name: "SelectOption",
            name: "Wednesday",
            value: "wednesday",
            data: "WEDNESDAY",
          },
          {
            type_name: "SelectOption",
            name: "Thursday",
            value: "thursday",
            data: "THURSDAY",
          },
          {
            type_name: "SelectOption",
            name: "Friday",
            value: "friday",
            data: "FRIDAY",
          },
          {
            type_name: "SelectOption",
            name: "Saturday",
            value: "saturday",
            data: "SATURDAY",
          },
          {
            type_name: "SelectOption",
            name: "Sunday",
            value: "sunday",
            data: "SUNDAY",
          },
          {
            type_name: "SelectOption",
            name: "Completed",
            value: "complete",
            data: "COMPLETE",
          },
        ],
      },

      {
        type: "genre",
        name: "Genre",
        type_name: "SelectFilter",
        values: [
          {
            type_name: "SelectOption",
            name: "All Genres",
            value: "",
            data: "",
          },
          {
            type_name: "SelectOption",
            name: "Drama",
            value: "drama",
            data: "DRAMA",
          },
          {
            type_name: "SelectOption",
            name: "Fantasy",
            value: "fantasy",
            data: "FANTASY",
          },
          {
            type_name: "SelectOption",
            name: "Comedy",
            value: "comedy",
            data: "COMEDY",
          },
          {
            type_name: "SelectOption",
            name: "Action",
            value: "action",
            data: "ACTION",
          },
          {
            type_name: "SelectOption",
            name: "Slice of Life",
            value: "slice_of_life",
            data: "SLICE_OF_LIFE",
          },
          {
            type_name: "SelectOption",
            name: "Romance",
            value: "romance",
            data: "ROMANCE",
          },
          {
            type_name: "SelectOption",
            name: "Superhero",
            value: "super_hero",
            data: "SUPER_HERO",
          },
          {
            type_name: "SelectOption",
            name: "Sci-Fi",
            value: "sf",
            data: "SF",
          },
          {
            type_name: "SelectOption",
            name: "Thriller",
            value: "thriller",
            data: "THRILLER",
          },
          {
            type_name: "SelectOption",
            name: "Supernatural",
            value: "supernatural",
            data: "SUPERNATURAL",
          },
          {
            type_name: "SelectOption",
            name: "Mystery",
            value: "mystery",
            data: "MYSTERY",
          },
          {
            type_name: "SelectOption",
            name: "Sports",
            value: "sports",
            data: "SPORTS",
          },
          {
            type_name: "SelectOption",
            name: "Historical",
            value: "historical",
            data: "HISTORICAL",
          },
          {
            type_name: "SelectOption",
            name: "Heartwarming",
            value: "heartwarming",
            data: "HEARTWARMING",
          },
          {
            type_name: "SelectOption",
            name: "Horror",
            value: "horror",
            data: "HORROR",
          },
          {
            type_name: "SelectOption",
            name: "Graphic Novel",
            value: "graphic_novel",
            data: "GRAPHIC_NOVEL",
          },
          {
            type_name: "SelectOption",
            name: "Informative",
            value: "tiptoon",
            data: "TIPTOON",
          },
        ],
      },
    ];
  }

  //  Preferences
  getSourcePreferences() {
    return [
      {
        key: "domain_url",
        editTextPreference: {
          title: "Override BaseUrl",
          summary: "",
          value: this.source.baseUrl,
          dialogTitle: "URL",
          dialogMessage: "",
        },
      },
      {
        key: "mobile_url",
        editTextPreference: {
          title: "Override mobileUrl",
          summary: "",
          value: this.mobileUrl,
          dialogTitle: "URL",
          dialogMessage: "",
        },
      },
    ];
  }
}

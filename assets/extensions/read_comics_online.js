const mangayomiSources = [
  {
    "name": "Read Comics Online",
    "lang": "en",
    "id": 376287717,
    "baseUrl": "https://readcomicsonline.ru",
    "apiUrl": "",
    "iconUrl":
      "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/main/dart/manga/multisrc/mmrcms/src/en/readcomicsonline/icon.png",
    "typeSource": "single",
    "isManga": true,
    "itemType": 0,
    "version": "1.2.0",
    "pkgPath": "javascript/manga/src/en/read_comics_online.js",
  },
];

class DefaultExtension extends MProvider {
  parseComicList(items) {
    const list = [];
    const seen = new Set();
    for (const a of items) {
      const link = a.attr("href");
      if (!link || !link.includes("/comic/")) continue;
      const parts = link.replace("https://readcomicsonline.ru", "").split("/").filter(Boolean);
      if (parts.length !== 2) continue;

      const name = a.text.trim();
      if (!name || seen.has(link)) continue;
      seen.add(link);

      const slug = parts[1];
      let imageUrl = "";
      const parent = a.parentElement;
      const grandParent = parent ? parent.parentElement : null;
      const img = (grandParent ? grandParent.querySelector("img") : null) || (parent ? parent.querySelector("img") : null);
      if (img) {
        imageUrl = img.attr("src") || img.attr("data-src") || "";
      }
      if (!imageUrl || imageUrl.includes("loading") || !imageUrl.startsWith("http")) {
        imageUrl = `https://cdn.readcomicsonline.ru/uploads/manga/${slug}/cover/cover_250x350.jpg`;
      }

      list.push({
        name: name,
        imageUrl: imageUrl,
        link: link.startsWith("http") ? link : `https://readcomicsonline.ru${link}`
      });
    }
    return list;
  }

  constructor() {
    super();
    this.client = new Client();
  }

  getHeaders() {
    return {
      "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.6832.64 Safari/537.36",
      "Referer": "" // Deliberately empty per site requirements,
    };
  }

  async getPopular(page) {
    const url = page === 1 
      ? `https://readcomicsonline.ru/changeMangaList?type=top_views`
      : `https://readcomicsonline.ru/comic-list?page=${page}&sort=views`;
    const res = await this.client.get(url, this.getHeaders());
    const doc = new Document(res.body);
    const list = [];
    const items = doc.querySelectorAll("a[href*='/comic/']");
    const seen = new Set();

    for (const a of items) {
      const link = a.attr("href");
      if (!link || !link.includes("/comic/")) continue;
      const parts = link.replace("https://readcomicsonline.ru", "").split("/").filter(Boolean);
      if (parts.length !== 2) continue; // ['comic', 'slug']

      const name = a.text.trim();
      if (!name || seen.has(link)) continue;
      seen.add(link);

      const slug = parts[1];
      let imageUrl = "";
      const parent = a.parentElement;
      const grandParent = parent ? parent.parentElement : null;
      const img = (grandParent ? grandParent.querySelector("img") : null) || (parent ? parent.querySelector("img") : null);
      if (img) {
        imageUrl = img.attr("src") || img.attr("data-src") || "";
      }
      if (!imageUrl || imageUrl.includes("loading") || !imageUrl.startsWith("http")) {
        imageUrl = `https://cdn.readcomicsonline.ru/uploads/manga/${slug}/cover/cover_250x350.jpg`;
      }

      list.push({
        name: name,
        imageUrl: imageUrl,
        link: link.startsWith("http") ? link : `https://readcomicsonline.ru${link}`
      });
    }

    return {
      list: list,
      hasNextPage: list.length >= 20
    };
  }

  async getLatestUpdates(page) {
    const url = `https://readcomicsonline.ru/latest-release?page=${page}`;
    const res = await this.client.get(url, this.getHeaders());
    const doc = new Document(res.body);
    const list = [];
    const items = doc.querySelectorAll("a[href*='/comic/']");
    const seen = new Set();

    for (const a of items) {
      const link = a.attr("href");
      if (!link) continue;
      const parts = link.replace("https://readcomicsonline.ru", "").split("/").filter(Boolean);
      if (parts.length !== 2) continue;

      const name = a.text.trim();
      if (!name || seen.has(link)) continue;
      seen.add(link);

      const slug = parts[1];
      let imageUrl = "";
      const parent = a.parentElement;
      const grandParent = parent ? parent.parentElement : null;
      const img = (grandParent ? grandParent.querySelector("img") : null) || (parent ? parent.querySelector("img") : null);
      if (img) {
        imageUrl = img.attr("src") || img.attr("data-src") || "";
      }
      if (!imageUrl || imageUrl.includes("loading") || !imageUrl.startsWith("http")) {
        imageUrl = `https://cdn.readcomicsonline.ru/uploads/manga/${slug}/cover/cover_250x350.jpg`;
      }

      list.push({
        name: name,
        imageUrl: imageUrl,
        link: link.startsWith("http") ? link : `https://readcomicsonline.ru${link}`
      });
    }

    return {
      list: list,
      hasNextPage: list.length >= 20
    };
  }


    getFilterList() {
        return [
            {
                type_name: "SelectFilter",
                name: "Sort By",
                state: 1,
                values: [
                    { type_name: "SelectOption", name: "Name", value: "name" },
                    { type_name: "SelectOption", name: "Views", value: "views" },
                    { type_name: "SelectOption", name: "Last Update", value: "last_release" }
                ]
            },
            {
                type_name: "SelectFilter",
                name: "Order",
                state: 1,
                values: [
                    { type_name: "SelectOption", name: "Ascending", value: "true" },
                    { type_name: "SelectOption", name: "Descending", value: "false" }
                ]
            },
            {
                type_name: "SelectFilter",
                name: "Status",
                state: 0,
                values: [
                    { type_name: "SelectOption", name: "All", value: "" },
                    { type_name: "SelectOption", name: "Ongoing", value: "1" },
                    { type_name: "SelectOption", name: "Completed", value: "2" },
                    { type_name: "SelectOption", name: "Canceled", value: "3" },
                    { type_name: "SelectOption", name: "On Hold", value: "4" }
                ]
            }
        ];
    }

    async search(query, page, filters) {
        let sortBy = "views";
        let asc = "false";
        let status = "";
        
        let hasFilters = false;

        if (filters && filters.length > 0) {
            for (const filter of filters) {
                if (filter.name === "Sort By") {
                    sortBy = filter.values[filter.state].value;
                    if (filter.state !== 1) hasFilters = true;
                } else if (filter.name === "Order") {
                    asc = filter.values[filter.state].value;
                    if (filter.state !== 1) hasFilters = true;
                } else if (filter.name === "Status") {
                    status = filter.values[filter.state].value;
                    if (filter.state !== 0) hasFilters = true;
                }
            }
        }

        if (query && query.trim().length > 0 && !hasFilters) {
            const url = `https://readcomicsonline.ru/search?query=${encodeURIComponent(query.trim())}`;
            const res = await this.client.get(url, this.getHeaders());
            try {
                let jsonStr = res.body;
                if (jsonStr.includes("<pre>")) {
                    jsonStr = jsonStr.split("<pre>")[1].split("</pre>")[0];
                }
                const data = JSON.parse(jsonStr);
                const suggestions = data.suggestions || [];
                const list = suggestions.map((s) => ({
                    name: s.value ? s.value.replace(/&amp;/g, '&').trim() : '',
                    imageUrl: s.cover || '',
                    link: s.url || `https://readcomicsonline.ru/comic/${s.data}`
                })).filter((item) => item.name && item.link);

                return {
                    list: list,
                    hasNextPage: false
                };
            } catch (_) {
                return { list: [], hasNextPage: false };
            }
        }

        let url = `https://readcomicsonline.ru/filterList?page=${page}&sortBy=${sortBy}&asc=${asc}`;
        if (status) {
            url += `&status=${status}`;
        }
        if (query && query.trim().length > 0) {
            url += `&alpha=${query.trim().charAt(0).toUpperCase()}`;
        }

        const res = await this.client.get(url, this.getHeaders());
        const doc = new Document(res.body);
        const list = [];
        const items = doc.querySelectorAll("a[href*='/comic/']");
        const seen = new Set();

        for (const a of items) {
            const link = a.attr("href");
            if (!link || !link.includes("/comic/")) continue;
            const parts = link.replace("https://readcomicsonline.ru", "").split("/").filter(Boolean);
            if (parts.length !== 2) continue; // ['comic', 'slug']

            const name = a.text.trim();
            if (!name || seen.has(link)) continue;
            seen.add(link);

            const slug = parts[1];
            let imageUrl = "";
            const parent = a.parentElement;
            const grandParent = parent ? parent.parentElement : null;
            const img = (grandParent ? grandParent.querySelector("img") : null) || (parent ? parent.querySelector("img") : null);
            if (img) {
                imageUrl = img.attr("src") || img.attr("data-src") || "";
            }
            if (!imageUrl || imageUrl.includes("loading") || !imageUrl.startsWith("http")) {
                imageUrl = `https://cdn.readcomicsonline.ru/uploads/manga/${slug}/cover/cover_250x350.jpg`;
            }

            list.push({
                name: name,
                imageUrl: imageUrl,
                link: link.startsWith("http") ? link : `https://readcomicsonline.ru${link}`
            });
        }

        return {
            list: list,
            hasNextPage: list.length >= 20
        };
    }

  async getDetail(url) {
    let fullUrl = url.startsWith("http") ? url : `https://readcomicsonline.ru${url}`;
    
    const res = await this.client.get(fullUrl, this.getHeaders());
    const doc = new Document(res.body);

    const titleEl = doc.querySelector("h2.listmanga-header") || doc.querySelector("h1") || doc.querySelector("h2");
    const name = titleEl ? titleEl.text.trim() : "";

    const imgEl = doc.querySelector(".boxed img") || doc.querySelector("img[src*='cover']");
    let imageUrl = imgEl ? (imgEl.attr("src") || imgEl.attr("data-src") || "") : "";
    if (!imageUrl || !imageUrl.startsWith("http")) {
      const slug = fullUrl.replace("https://readcomicsonline.ru/comic/", "").split("/")[0].split("?")[0];
      imageUrl = `https://cdn.readcomicsonline.ru/uploads/manga/${slug}/cover/cover_250x350.jpg`;
    }

    const descEl = doc.querySelector(".manga-details .p-desc") || doc.querySelector(".panel-body p");
    const description = descEl ? descEl.text.trim() : "";

    const chapters = [];
    const chapterLinks = doc.querySelectorAll("ul.chapters li a, a[href*='/comic/']");
    const seen = new Set();

    for (const a of chapterLinks) {
      const href = a.attr("href");
      if (!href) continue;
      const parts = href.replace("https://readcomicsonline.ru", "").split("/").filter(Boolean);
      if (parts.length < 3) continue; // Must be ['comic', 'slug', 'chapter_num']
      if (seen.has(href)) continue;
      seen.add(href);

      const chName = a.text.trim() || `Chapter ${parts[2]}`;
      chapters.push({
        name: chName,
        url: href.startsWith("http") ? href : `https://readcomicsonline.ru${href}`
      });
    }

    return {
      name: name,
      imageUrl: imageUrl,
      description: description,
      status: 0,
      author: "Various",
      genre: ["Comics"],
      chapters: chapters
    };
  }

  async getPageList(url) {
    let fullUrl = url.startsWith("http") ? url : `https://readcomicsonline.ru${url}`;
    
    const res = await this.client.get(fullUrl, this.getHeaders());
    const doc = new Document(res.body);

    const pages = [];
    const seen = new Set();
    const imgs = doc.querySelectorAll("img[src*='uploads/manga'], img[data-src*='uploads/manga'], img[src*='cdn.readcomicsonline.ru'], img.mx-auto, .img-responsive");

    for (const img of imgs) {
      const src = img.attr("src") || img.attr("data-src");
      if (src && !src.includes("banner") && !src.includes("no-image") && !src.includes("logo") && !src.includes("cover_")) {
        const cleanSrc = src.trim().startsWith("http") ? src.trim() : `https:${src.trim()}`;
        if (!seen.has(cleanSrc)) {
          seen.add(cleanSrc);
          pages.push({
            url: cleanSrc,
            headers: { "Referer": "" /* Deliberately empty per site requirements */ }
          });
        }
      }
    }

    return pages;
  }
}

const mangayomiSources = [
  {
    "name": "NineHentai",
    "lang": "en",
    "id": 768949056,
    "baseUrl": "https://9hentai.so",
    "apiUrl": "https://9hentai.so/api",
    "iconUrl": "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/main/javascript/icon/en.ninehentai.png",
    "typeSource": "single",
    "isManga": true,
    "isNsfw": true,
    "itemType": 0,
    "version": "1.1.0",
    "pkgPath": "javascript/manga/src/en/ninehentai.js"
  }
];

class DefaultExtension extends MProvider {
  constructor() {
    super();
    this.client = new Client();
  }

  getHeaders() {
    return {
      "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.6832.64 Safari/537.36",
      "Referer": "https://9hentai.so/",
      "Content-Type": "application/json"
    };
  }

  _mapBook(b) {
    if (!b || !b.id) return null;
    let server = b.image_server || "https://i.9hentai.so/images/";
    server = server.replace("i.9hentai.com", "i.9hentai.so");
    if (!server.endsWith("/")) server += "/";
    const imageUrl = `${server}${b.id}/cover-small.jpg`;
    return {
      name: (b.title || "Untitled").trim(),
      imageUrl: imageUrl,
      link: `https://9hentai.so/g/${b.id}/`
    };
  }

  async getPopular(page) {
    const url = "https://9hentai.so/api/getBook";
    const body = {
      search: {
        text: "",
        page: page - 1,
        sort: 1, // Popular
        pages: { range: [0, 2000] },
        tag: { text: "", type: 1, tags: [], items: { included: [], excluded: [] } }
      }
    };
    try {
      const res = await this.client.post(url, this.getHeaders(), body);
      const data = typeof res.body === "string" ? JSON.parse(res.body) : res.body;
      const results = data.results || [];
      const list = results.map((b) => this._mapBook(b)).filter(Boolean);

      return {
        list: list,
        hasNextPage: results.length >= 18
      };
    } catch (e) { 
      return { list: [], hasNextPage: false };
    }
  }

  async getLatestUpdates(page) {
    const url = "https://9hentai.so/api/getBook";
    const body = {
      search: {
        text: "",
        page: page - 1,
        sort: 0, // Latest
        pages: { range: [0, 2000] },
        tag: { text: "", type: 1, tags: [], items: { included: [], excluded: [] } }
      }
    };
    try {
      const res = await this.client.post(url, this.getHeaders(), body);
      const data = typeof res.body === "string" ? JSON.parse(res.body) : res.body;
      const results = data.results || [];
      const list = results.map((b) => this._mapBook(b)).filter(Boolean);

      return {
        list: list,
        hasNextPage: results.length >= 18
      };
    } catch (e) { 
      return { list: [], hasNextPage: false };
    }
  }


  getFilterList() {
    return [
      {
        type_name: "SelectFilter",
        name: "Sort By",
        state: 0,
        values: [
          { type_name: "SelectOption", name: "Popular (Most Viewed)", value: "1" },
          { type_name: "SelectOption", name: "Newest / Recent", value: "0" },
          { type_name: "SelectOption", name: "Top Rated", value: "2" },
          { type_name: "SelectOption", name: "Most Downloaded", value: "3" }
        ]
      },
      {
        type_name: "GroupFilter",
        name: "Categories",
        state: [
          { type_name: "CheckBox", name: "Manga", value: "Manga", state: false },
          { type_name: "CheckBox", name: "Doujinshi", value: "Doujinshi", state: false },
          { type_name: "CheckBox", name: "Western", value: "Western", state: false },
          { type_name: "CheckBox", name: "Non-H", value: "Non-H", state: false },
          { type_name: "CheckBox", name: "Artist CG", value: "Artist CG", state: false },
          { type_name: "CheckBox", name: "Game CG", value: "Game CG", state: false }
        ]
      }
    ];
  }

  async search(query, page, filters) {
    let sortVal = 1;
    const includedTags = [];

    if (filters && filters.length > 0) {
      for (const f of filters) {
        if (f.name === "Sort By" && f.values && f.values.length > f.state) {
          sortVal = parseInt(f.values[f.state].value) || 0;
        } else if (f.type_name === "GroupFilter" && Array.isArray(f.state)) {
          for (const cb of f.state) {
            if (cb.state && cb.value) {
              includedTags.push(cb.value);
            }
          }
        }
      }
    }

    const url = "https://9hentai.so/api/getBook";
    const body = {
      search: {
        text: query || "",
        page: page - 1,
        sort: sortVal,
        pages: { range: [0, 2000] },
        tag: {
          text: "",
          type: 1,
          tags: includedTags,
          items: { included: [], excluded: [] }
        }
      }
    };
    try {
      const res = await this.client.post(url, this.getHeaders(), body);
      const data = typeof res.body === "string" ? JSON.parse(res.body) : res.body;
      const results = data.results || [];
      const list = results.map((b) => this._mapBook(b)).filter(Boolean);

      return {
        list: list,
        hasNextPage: results.length >= 18
      };
    } catch (e) { 
      return { list: [], hasNextPage: false };
    }
  }

  async getDetail(url) {
    const idMatch = url.match(/\/g\/(\d+)/);
    const id = idMatch ? idMatch[1] : url.replace(/[^0-9]/g, "");
    const apiUrl = "https://9hentai.so/api/getBookByID";
    try {
      const res = await this.client.post(apiUrl, this.getHeaders(), { id: parseInt(id) });
      const data = typeof res.body === "string" ? JSON.parse(res.body) : res.body;
      const b = data.results || data;

      const tags = (b.tags || []).map((t) => t.name || t);
      let rawServer = b.image_server || "https://i.9hentai.so/images/";
      rawServer = rawServer.replace("i.9hentai.com", "i.9hentai.so");
      if (!rawServer.endsWith("/")) rawServer += "/";
      const imageUrl = `${rawServer}${b.id}/cover-small.jpg`;

      return {
        name: b.title || "Untitled",
        imageUrl: imageUrl,
        description: `Total Pages: ${b.total_page || 0}`,
        status: 1,
        author: "Various",
        genre: tags,
        chapters: [
          {
            name: "Read Online",
            url: `https://9hentai.so/g/${b.id}/`
          }
        ]
      };
    } catch (e) { 
      return {
        name: "NineHentai Doujin",
        imageUrl: "",
        description: "",
        status: 1,
        author: "Various",
        genre: [],
        chapters: [{ name: "Read", url: url }]
      };
    }
  }

  async getPageList(url) {
    const idMatch = url.match(/\/g\/(\d+)/);
    const id = idMatch ? idMatch[1] : url.replace(/[^0-9]/g, "");
    const apiUrl = "https://9hentai.so/api/getBookByID";
    try {
      const res = await this.client.post(apiUrl, this.getHeaders(), { id: parseInt(id) });
      const data = typeof res.body === "string" ? JSON.parse(res.body) : res.body;
      const b = data.results || data;
      // API returns image_server as "https://i.9hentai.com/images/" but correct CDN is .so
      const rawServer = b.image_server || "https://i.9hentai.so/images/";
      const server = rawServer.replace("i.9hentai.com", "i.9hentai.so");
      const total = b.total_page || 1;
      const pages = [];

      for (let i = 1; i <= total; i++) {
        pages.push({
          url: `${server}${b.id}/${i}.${(b.pages && b.pages[i-1] && b.pages[i-1].t === "p") ? "png" : "jpg"}`,
          headers: { "Referer": "https://9hentai.so/" }
        });
      }

      return pages;
    } catch (e) { 
      return [];
    }
  }
}

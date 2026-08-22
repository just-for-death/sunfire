const mangayomiSources = [
  {
    "name": "NineHentai",
    "lang": "en",
    "id": 768949056,
    "baseUrl": "https://ninehentai.to",
    "apiUrl": "https://api.ninehentai.to",
    "iconUrl": "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/main/javascript/icon/en.ninehentai.png",
    "typeSource": "single",
    "isManga": true,
    "isNsfw": true,
    "itemType": 0,
    "version": "1.0.0",
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
      "Referer": "https://ninehentai.to/",
      "Content-Type": "application/json"
    };
  }

  async getPopular(page) {
    const url = "https://api.ninehentai.to/api/books";
    const body = {
      total: 20,
      page: page - 1,
      sort: 1, // Popular / Top views
      search: { text: "", params: {} }
    };
    try {
      const res = await this.client.post(url, this.getHeaders(), body);
      const data = typeof res.body === "string" ? JSON.parse(res.body) : res.body;
      const results = data.results || [];
      const list = results.map((b) => ({
        name: b.title || "Untitled",
        imageUrl: b.image_server ? `${b.image_server}${b.id}/cover-l.jpg` : "",
        link: `https://ninehentai.to/g/${b.id}/`
      }));

      return {
        list: list,
        hasNextPage: results.length >= 20
      };
    } catch (_) {
      return { list: [], hasNextPage: false };
    }
  }

  async getLatestUpdates(page) {
    const url = "https://api.ninehentai.to/api/books";
    const body = {
      total: 20,
      page: page - 1,
      sort: 0, // Latest
      search: { text: "", params: {} }
    };
    try {
      const res = await this.client.post(url, this.getHeaders(), body);
      const data = typeof res.body === "string" ? JSON.parse(res.body) : res.body;
      const results = data.results || [];
      const list = results.map((b) => ({
        name: b.title || "Untitled",
        imageUrl: b.image_server ? `${b.image_server}${b.id}/cover-l.jpg` : "",
        link: `https://ninehentai.to/g/${b.id}/`
      }));

      return {
        list: list,
        hasNextPage: results.length >= 20
      };
    } catch (_) {
      return { list: [], hasNextPage: false };
    }
  }

  async search(query, page, filters) {
    const url = "https://api.ninehentai.to/api/books";
    const body = {
      total: 20,
      page: page - 1,
      sort: 1,
      search: { text: query || "", params: {} }
    };
    try {
      const res = await this.client.post(url, this.getHeaders(), body);
      const data = typeof res.body === "string" ? JSON.parse(res.body) : res.body;
      const results = data.results || [];
      const list = results.map((b) => ({
        name: b.title || "Untitled",
        imageUrl: b.image_server ? `${b.image_server}${b.id}/cover-l.jpg` : "",
        link: `https://ninehentai.to/g/${b.id}/`
      }));

      return {
        list: list,
        hasNextPage: results.length >= 20
      };
    } catch (_) {
      return { list: [], hasNextPage: false };
    }
  }

  async getDetail(url) {
    const id = url.replace("https://ninehentai.to", "").replace(/[^0-9]/g, "");
    const apiUrl = "https://api.ninehentai.to/api/bookById";
    try {
      const res = await this.client.post(apiUrl, this.getHeaders(), { id: parseInt(id) });
      const data = typeof res.body === "string" ? JSON.parse(res.body) : res.body;
      const b = data.result || data;

      const tags = (b.tags || []).map((t) => t.name || t);
      const imageUrl = b.image_server ? `${b.image_server}${b.id}/cover-l.jpg` : "";

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
            url: `https://ninehentai.to/g/${b.id}/`
          }
        ]
      };
    } catch (_) {
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
    const id = url.replace("https://ninehentai.to", "").replace(/[^0-9]/g, "");
    const apiUrl = "https://api.ninehentai.to/api/bookById";
    try {
      const res = await this.client.post(apiUrl, this.getHeaders(), { id: parseInt(id) });
      const data = typeof res.body === "string" ? JSON.parse(res.body) : res.body;
      const b = data.result || data;
      const server = b.image_server || "https://f01.ninehentai.to/images/";
      const total = b.total_page || 1;
      const pages = [];

      for (let i = 1; i <= total; i++) {
        pages.push(`${server}${b.id}/${i}.jpg`);
      }

      return pages;
    } catch (_) {
      return [];
    }
  }
}

const mangayomiSources = [
  {
    "name": "nHentai.com (unoriginal)",
    "lang": "en",
    "id": 559183086,
    "baseUrl": "https://nhentai.net",
    "apiUrl": "",
    "iconUrl": "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/main/javascript/icon/all.nhentai.png",
    "typeSource": "single",
    "isManga": true,
    "isNsfw": true,
    "itemType": 0,
    "version": "1.0.0",
    "pkgPath": "javascript/manga/src/en/nhentai.js"
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
      "Referer": "https://nhentai.net/"
    };
  }

  async getPopular(page) {
    const url = `https://nhentai.net/?page=${page}`;
    const res = await this.client.get(url, this.getHeaders());
    const doc = new Document(res.body);
    const list = [];
    const galleries = doc.querySelectorAll(".gallery");

    for (const g of galleries) {
      const a = g.querySelector("a.cover");
      const img = g.querySelector("img");
      const caption = g.querySelector(".caption");

      if (a) {
        const link = a.attr("href") || "";
        const name = (caption ? caption.text.trim() : "") || (img ? img.attr("alt") : "");
        let imageUrl = img ? (img.attr("data-src") || img.attr("src") || "") : "";
        if (imageUrl.startsWith("//")) imageUrl = "https:" + imageUrl;

        if (link && name) {
          list.push({
            name: name,
            imageUrl: imageUrl,
            link: link.startsWith("http") ? link : `https://nhentai.net${link}`
          });
        }
      }
    }

    return {
      list: list,
      hasNextPage: list.length >= 20
    };
  }

  async getLatestUpdates(page) {
    return await this.getPopular(page);
  }

  async search(query, page, filters) {
    const url = query && query.trim().length > 0
      ? `https://nhentai.net/search/?q=${encodeURIComponent(query.trim())}&page=${page}`
      : `https://nhentai.net/?page=${page}`;

    const res = await this.client.get(url, this.getHeaders());
    const doc = new Document(res.body);
    const list = [];
    const galleries = doc.querySelectorAll(".gallery");

    for (const g of galleries) {
      const a = g.querySelector("a.cover");
      const img = g.querySelector("img");
      const caption = g.querySelector(".caption");

      if (a) {
        const link = a.attr("href") || "";
        const name = (caption ? caption.text.trim() : "") || (img ? img.attr("alt") : "");
        let imageUrl = img ? (img.attr("data-src") || img.attr("src") || "") : "";
        if (imageUrl.startsWith("//")) imageUrl = "https:" + imageUrl;

        if (link && name) {
          list.push({
            name: name,
            imageUrl: imageUrl,
            link: link.startsWith("http") ? link : `https://nhentai.net${link}`
          });
        }
      }
    }

    return {
      list: list,
      hasNextPage: list.length >= 20
    };
  }

  async getDetail(url) {
    const fullUrl = url.startsWith("http") ? url : `https://nhentai.net${url}`;
    const res = await this.client.get(fullUrl, this.getHeaders());
    const doc = new Document(res.body);

    const titleEl = doc.querySelector("#info h1") || doc.querySelector("h1.title") || doc.querySelector("h1");
    const name = titleEl ? titleEl.text.trim() : "";

    const coverEl = doc.querySelector("#cover img");
    let imageUrl = coverEl ? (coverEl.attr("data-src") || coverEl.attr("src") || "") : "";
    if (imageUrl.startsWith("//")) imageUrl = "https:" + imageUrl;

    const tags = [];
    const tagEls = doc.querySelectorAll(".tag-container .tags a.tag .name");
    for (const t of tagEls) {
      if (t.text) tags.push(t.text.trim());
    }

    return {
      name: name,
      imageUrl: imageUrl,
      description: `Tags: ${tags.join(", ")}`,
      status: 1, // Completed doujin
      author: "Various",
      genre: tags,
      chapters: [
        {
          name: "Read Online",
          url: fullUrl
        }
      ]
    };
  }

  async getPageList(url) {
    const fullUrl = url.startsWith("http") ? url : `https://nhentai.net${url}`;
    const res = await this.client.get(fullUrl, this.getHeaders());
    const doc = new Document(res.body);
    const pages = [];

    // Extract thumbs and convert to full image URLs
    // Thumb: https://t2.nhentai.net/galleries/4130667/thumb.webp or /1t.webp
    // Image: https://i2.nhentai.net/galleries/4130667/1.webp
    const thumbImgs = doc.querySelectorAll(".thumb-container img") || doc.querySelectorAll("#thumbnail-container img");

    for (let i = 0; i < thumbImgs.length; i++) {
      const img = thumbImgs[i];
      let src = img.attr("data-src") || img.attr("src") || "";
      if (src) {
        if (src.startsWith("//")) src = "https:" + src;
        // Replace t.nhentai.net -> i.nhentai.net and {n}t.ext -> {n}.ext
        let fullSrc = src
          .replace("t.nhentai.net", "i.nhentai.net")
          .replace("t1.nhentai.net", "i1.nhentai.net")
          .replace("t2.nhentai.net", "i2.nhentai.net")
          .replace("t3.nhentai.net", "i3.nhentai.net")
          .replace(/([0-9]+)t\.(jpg|png|webp|gif)/, "$1.$2");
        pages.push(fullSrc);
      }
    }

    return pages;
  }
}

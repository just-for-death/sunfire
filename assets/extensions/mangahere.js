const mangayomiSources = [{
    "name": "MangaHere",
    "lang": "en",
    "baseUrl": "https://www.mangahere.cc",
    "apiUrl": "",
    "iconUrl": "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/main/javascript/icon/en.mangahere.png",
    "typeSource": "single",
    "itemType": 0,
    "version": "1.0.0",
    "pkgPath": "manga/src/en/mangahere.js"
}];

class DefaultExtension extends MProvider {
    constructor() {
        super();
        this.client = new Client();
    }

    getHeaders() {
        return {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            "Referer": "https://www.mangahere.cc/"
        };
    }

    async getPopular(page) {
        const url = `${this.source.baseUrl}/directory/${page}.htm`;
        const res = await this.client.get(url, this.getHeaders());
        const doc = new Document(res.body);
        const list = [];
        const items = doc.querySelectorAll(".manga-list-1-list li, .manga-list-4-list li");

        for (const item of items) {
            const a = item.querySelector("a");
            const img = item.querySelector("img");
            if (a) {
                const title = a.attr("title") || (img ? img.attr("alt") : "") || a.text;
                const link = a.attr("href");
                const imageUrl = img ? (img.attr("src") || img.attr("data-src")) : "";
                if (title && link && link.indexOf('/manga/') !== -1) {
                    list.push({
                        name: title.trim(),
                        imageUrl: imageUrl,
                        link: link.startsWith('http') ? link : `${this.source.baseUrl}${link}`
                    });
                }
            }
        }

        return {
            list: list,
            hasNextPage: list.length > 0
        };
    }

    async getLatestUpdates(page) {
        const url = `${this.source.baseUrl}/directory/${page}.htm?latest`;
        const res = await this.client.get(url, this.getHeaders());
        const doc = new Document(res.body);
        const list = [];
        const items = doc.querySelectorAll(".manga-list-1-list li, .manga-list-4-list li");

        for (const item of items) {
            const a = item.querySelector("a");
            const img = item.querySelector("img");
            if (a) {
                const title = a.attr("title") || (img ? img.attr("alt") : "") || a.text;
                const link = a.attr("href");
                const imageUrl = img ? (img.attr("src") || img.attr("data-src")) : "";
                if (title && link && link.indexOf('/manga/') !== -1) {
                    list.push({
                        name: title.trim(),
                        imageUrl: imageUrl,
                        link: link.startsWith('http') ? link : `${this.source.baseUrl}${link}`
                    });
                }
            }
        }

        return {
            list: list,
            hasNextPage: list.length > 0
        };
    }

    async search(query, page, filters) {
        const url = `${this.source.baseUrl}/search?title=${encodeURIComponent(query)}&page=${page}`;
        const res = await this.client.get(url, this.getHeaders());
        const doc = new Document(res.body);
        const list = [];
        const items = doc.querySelectorAll(".manga-list-4-list li");

        for (const item of items) {
            const a = item.querySelector("a");
            const img = item.querySelector("img");
            if (a) {
                const title = a.attr("title") || (img ? img.attr("alt") : "") || a.text;
                const link = a.attr("href");
                const imageUrl = img ? (img.attr("src") || img.attr("data-src")) : "";
                if (title && link) {
                    list.push({
                        name: title.trim(),
                        imageUrl: imageUrl,
                        link: link.startsWith('http') ? link : `${this.source.baseUrl}${link}`
                    });
                }
            }
        }

        return {
            list: list,
            hasNextPage: list.length > 0
        };
    }

    async getDetail(url) {
        const fullUrl = url.startsWith('http') ? url : `${this.source.baseUrl}${url}`;
        const res = await this.client.get(fullUrl, this.getHeaders());
        const doc = new Document(res.body);

        const title = doc.querySelector(".detail-info-right-title-font")?.text || "";
        const description = doc.querySelector(".fullcontent")?.text || "";
        const img = doc.querySelector(".detail-info-cover-img");
        const imageUrl = img ? (img.attr("src") || img.attr("data-src")) : "";
        const author = doc.querySelector(".detail-info-right-say a")?.text || "";

        const chapters = [];
        const chapItems = doc.querySelectorAll(".detail-main-list li a");
        for (const c of chapItems) {
            const link = c.attr("href");
            const name = c.querySelector(".detail-main-list-main")?.text || c.text;
            if (link && name) {
                chapters.push({
                    name: name.trim(),
                    url: link.startsWith('http') ? link : `${this.source.baseUrl}${link}`
                });
            }
        }

        return {
            title: title.trim(),
            description: description.trim(),
            imageUrl: imageUrl,
            author: author.trim(),
            chapters: chapters
        };
    }

    async getPageList(url) {
        const fullUrl = url.startsWith('http') ? url : `${this.source.baseUrl}${url}`;
        const res = await this.client.get(fullUrl, this.getHeaders());
        const match = res.body.match(/var\s+imagebrowse\s*=\s*(\[[^\]]+\])/);
        if (match) {
            try {
                const urls = JSON.parse(match[1]);
                return urls.map(u => ({ url: u.startsWith('//') ? `https:${u}` : u, headers: this.getHeaders() }));
            } catch (_) {}
        }
        return [];
    }
}

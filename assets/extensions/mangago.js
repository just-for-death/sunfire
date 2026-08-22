const mangayomiSources = [{
    "name": "Mangago",
    "lang": "en",
    "baseUrl": "https://www.mangago.me",
    "apiUrl": "",
    "iconUrl": "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/main/javascript/icon/en.mangago.png",
    "typeSource": "single",
    "itemType": 0,
    "version": "1.0.0",
    "pkgPath": "manga/src/en/mangago.js"
}];

class DefaultExtension extends MProvider {
    constructor() {
        super();
        this.client = new Client();
    }

    getHeaders() {
        return {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            "Referer": "https://www.mangago.me/"
        };
    }

    async getPopular(page) {
        const url = `https://www.mangago.me/genre/all/${page}/?f=1&o=1&sortby=view&e=`;
        const res = await this.client.get(url, this.getHeaders());
        const doc = new Document(res.body);
        const list = [];
        const items = doc.querySelectorAll(".updatesli") || doc.querySelectorAll(".flex1.listitem") || doc.querySelectorAll("#information li");

        for (const item of items) {
            const a = item.querySelector("a.thm-effect") || item.querySelector("span.title a") || item.querySelector("a");
            const img = item.querySelector("img");
            if (a) {
                const title = a.attr("title") || a.attr("alt") || (img ? img.attr("alt") : "") || a.text;
                const link = a.attr("href");
                const imageUrl = img ? (img.attr("data-src") || img.attr("src")) : "";
                if (title && link) {
                    list.push({
                        name: title.trim(),
                        imageUrl: imageUrl,
                        link: link
                    });
                }
            }
        }

        return {
            list: list,
            hasNextPage: list.length >= 24
        };
    }

    async getLatestUpdates(page) {
        const url = `https://www.mangago.me/genre/all/${page}/?f=1&o=1&sortby=update&e=`;
        const res = await this.client.get(url, this.getHeaders());
        const doc = new Document(res.body);
        const list = [];
        const items = doc.querySelectorAll(".pic_list .flex1.listitem") || doc.querySelectorAll("#information li");

        for (const item of items) {
            const a = item.querySelector("a.thm-effect") || item.querySelector("a");
            const img = item.querySelector("img");
            if (a) {
                const title = a.attr("title") || (img ? img.attr("alt") : "") || a.text;
                const link = a.attr("href");
                const imageUrl = img ? (img.attr("data-src") || img.attr("src")) : "";
                if (title && link) {
                    list.push({
                        name: title.trim(),
                        imageUrl: imageUrl,
                        link: link
                    });
                }
            }
        }

        return {
            list: list,
            hasNextPage: list.length >= 24
        };
    }

    async search(query, page, filters) {
        const url = `https://www.mangago.me/r/l_search/?name=${encodeURIComponent(query)}&page=${page}`;
        const res = await this.client.get(url, this.getHeaders());
        const doc = new Document(res.body);
        const list = [];
        const items = doc.querySelectorAll(".pic_list .flex1.listitem") || doc.querySelectorAll("#information li") || doc.querySelectorAll(".uk-grid li");

        for (const item of items) {
            const a = item.querySelector("a.thm-effect") || item.querySelector("a");
            const img = item.querySelector("img");
            if (a) {
                const title = a.attr("title") || (img ? img.attr("alt") : "") || a.text;
                const link = a.attr("href");
                const imageUrl = img ? (img.attr("data-src") || img.attr("src")) : "";
                if (title && link) {
                    list.push({
                        name: title.trim(),
                        imageUrl: imageUrl,
                        link: link
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
        const res = await this.client.get(url, this.getHeaders());
        const doc = new Document(res.body);

        const descElem = doc.querySelector("#item_details .manga-desc") || doc.querySelector("#item_details .m-desc") || doc.querySelector(".description");
        const description = descElem ? descElem.text.trim() : "";

        const authorElem = doc.querySelector(".manga-author") || doc.querySelector("a[href*='/author/']");
        const author = authorElem ? authorElem.text.trim() : "";

        const genreElems = doc.querySelectorAll(".manga-genres a") || doc.querySelectorAll("a[href*='/genre/']");
        const genres = genreElems ? genreElems.map(g => g.text.trim()).filter(Boolean) : [];

        const chapters = [];
        const rows = doc.querySelectorAll("table#chapter_table tbody tr") || doc.querySelectorAll("#chapter_table tr");

        for (const row of rows) {
            const a = row.querySelector("a.chpt") || row.querySelector("a[href*='/read-manga/']");
            if (a) {
                const name = a.text.trim();
                const link = a.attr("href");
                if (name && link && !link.includes("/home/people/")) {
                    chapters.push({
                        name: name,
                        url: link
                    });
                }
            }
        }

        return {
            description: description,
            author: author,
            genre: genres,
            chapters: chapters
        };
    }

    async getPageList(url) {
        const res = await this.client.get(url, this.getHeaders());
        const doc = new Document(res.body);
        const pages = [];

        // Check static img tags
        const imgs = doc.querySelectorAll("#pic_container img") || doc.querySelectorAll("img#comic_page") || doc.querySelectorAll(".page-image img");
        if (imgs && imgs.length > 0) {
            for (const img of imgs) {
                const src = img.attr("data-src") || img.attr("src") || img.attr("data-original");
                if (src && src.startsWith("http")) {
                    pages.push(src);
                }
            }
        }

        // Check if imgsrcs string is in the HTML
        const html = res.body || "";
        const match = html.match(/var\s+imgsrcs\s*=\s*['"]([^'"]+)['"]/);
        if (match && match[1]) {
            try {
                // Base64 / array decode
                const raw = atob(match[1]);
                const urls = raw.split(",").filter(u => u.startsWith("http"));
                if (urls.length > 0) {
                    return urls;
                }
            } catch (_) {}
        }

        return pages;
    }
}
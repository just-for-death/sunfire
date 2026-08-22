const mangayomiSources = [{
    "name": "MangaFreak",
    "lang": "en",
    "baseUrl": "https://ww3.mangafreak.me",
    "apiUrl": "",
    "iconUrl": "https://raw.githubusercontent.com/m2k3a/mangayomi-extensions/main/javascript/icon/en.mangafreak.png",
    "typeSource": "single",
    "itemType": 0,
    "version": "1.0.1",
    "pkgPath": "manga/src/en/mangafreak.js"
}];

class DefaultExtension extends MProvider {
    constructor() {
        super();
        this.client = new Client();
    }

    getHeaders() {
        return {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
            "Referer": "https://ww3.mangafreak.me/"
        };
    }

    async getPopular(page) {
        const url = `${this.source.baseUrl}/Genre/All/${page}`;
        const res = await this.client.get(url, this.getHeaders());
        const doc = new Document(res.body);
        const list = [];
        const items = doc.querySelectorAll(".ranking_item") || doc.querySelectorAll(".genre_main .manga_series_item");

        for (const item of items) {
            const a = item.querySelector(".ranking_item_info a") || item.querySelector("a");
            const img = item.querySelector("img");
            if (a) {
                const title = (a.querySelector(".title") ? a.querySelector(".title").text : null) || a.attr("title") || (img ? img.attr("alt") : "") || a.text;
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

    async getLatestUpdates(page) {
        const url = `${this.source.baseUrl}/Latest_Releases/${page}`;
        const res = await this.client.get(url, this.getHeaders());
        const doc = new Document(res.body);
        const list = [];
        // ww3.mangafreak.me uses .latest_releases_item (not .latest_series_item)
        const items = doc.querySelectorAll(".latest_releases_item");

        for (const item of items) {
            const a = item.querySelector(".latest_releases_info a");
            const img = item.querySelector("img");
            if (a) {
                const strong = a.querySelector("strong");
                const title = (strong ? strong.text : null) || a.attr("title") || (img ? img.attr("alt") : "") || a.text;
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

    async search(query, page, filters) {
        // When no query is provided but filters are active, use the genre browse URL
        // with query params (ww3.mangafreak.me supports ?Status=X&SortBy=Y)
        if (!query || query.trim() === '') {
            let statusParam = '';
            let sortParam = '';
            let typeParam = '';
            if (filters && Array.isArray(filters)) {
                for (const f of filters) {
                    if (f.name === 'Status' && f.value && f.value !== 'All') statusParam = f.value;
                    if (f.name === 'SortBy' && f.value && f.value !== 'Popularity') sortParam = f.value;
                    if (f.name === 'Type' && f.value && f.value !== 'All') typeParam = f.value;
                }
            }
            let qs = '';
            if (statusParam) qs += `Status=${encodeURIComponent(statusParam)}&`;
            if (sortParam) qs += `SortBy=${encodeURIComponent(sortParam)}&`;
            if (typeParam) qs += `Type=${encodeURIComponent(typeParam)}`;
            const url = `${this.source.baseUrl}/Genre/All/${page}?${qs}`;
            const res = await this.client.get(url, this.getHeaders());
            const doc = new Document(res.body);
            const list = [];
            const items = doc.querySelectorAll(".ranking_item");
            for (const item of items) {
                const a = item.querySelector(".ranking_item_info a") || item.querySelector("a");
                const img = item.querySelector("img");
                if (a) {
                    const titleEl = a.querySelector(".title");
                    const title = (titleEl ? titleEl.text : null) || a.attr("title") || (img ? img.attr("alt") : "") || a.text;
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
            return { list: list, hasNextPage: list.length > 0 };
        }

        // Normal text search
        const url = `${this.source.baseUrl}/Search/${encodeURIComponent(query)}`;
        const res = await this.client.get(url, this.getHeaders());
        const doc = new Document(res.body);
        const list = [];
        const items = doc.querySelectorAll(".manga_search_item, .manga_series_item, .ranking_item");

        for (const item of items) {
            const a = item.querySelector(".ranking_item_info a") || item.querySelector("a");
            const img = item.querySelector("img");
            if (a) {
                const strong = a.querySelector("strong");
                const title = (strong ? strong.text : null) || a.attr("title") || (img ? img.attr("alt") : "") || a.text;
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

        const title = doc.querySelector(".manga_series_data h5")?.text || "";
        const description = doc.querySelector(".manga_series_description p")?.text || "";
        const img = doc.querySelector(".manga_series_image img");
        const imageUrl = img ? (img.attr("src") || img.attr("data-src")) : "";

        const chapters = [];
        // ww3.mangafreak.me uses class="chapter-link" on all chapter <a> tags
        const chapItems = doc.querySelectorAll(".chapter-link");
        for (const c of chapItems) {
            const link = c.attr("href");
            const name = c.text;
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
            chapters: chapters
        };
    }

    async getPageList(url) {
        const fullUrl = url.startsWith('http') ? url : `${this.source.baseUrl}${url}`;
        const res = await this.client.get(fullUrl, this.getHeaders());
        const doc = new Document(res.body);
        const pages = [];
        // ww3.mangafreak.me renders chapter pages inside div.mySlides.fade > img
        // Old selectors (#gauto img, .my-slides img) no longer exist on the new domain
        const imgTags = doc.querySelectorAll(".mySlides img");
        for (const img of imgTags) {
            const src = img.attr("src") || img.attr("data-src");
            if (src) pages.push({ url: src, headers: this.getHeaders() });
        }
        return pages;
    }
}

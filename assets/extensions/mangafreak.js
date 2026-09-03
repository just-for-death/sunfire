const mangayomiSources = [{
    "id": 142987519,
    "name": "MangaFreak",
    "lang": "en",
    "baseUrl": "https://ww3.mangafreak.me",
    "apiUrl": "",
    "iconUrl": "https://www.google.com/s2/favicons?sz=128&domain=https://ww3.mangafreak.me",
    "typeSource": "single",
    "itemType": 0,
    "version": "1.0.1",
    "pkgPath": "javascript/manga/src/en/mangafreak.js"
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

    _cleanImageUrl(url) {
        if (!url) return "";
        return url.replace("/mini_images/", "/manga_images/").replace(/\/55x85.*$/, ".jpg");
    }

    async getPopular(page) {
        const url = `${this.source.baseUrl}/Genre/All/${page}`;
        const res = await this.client.get(url, this.getHeaders());
        const doc = new Document(res.body);
        const list = [];
        const items = doc.querySelectorAll(".ranking_item, .genre_main .manga_series_item, .manga_series_item");

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
                        imageUrl: this._cleanImageUrl(imageUrl),
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
                        imageUrl: this._cleanImageUrl(imageUrl),
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


    getFilterList() {
        return [
            {
                type_name: "SelectFilter",
                name: "Genre",
                state: 0,
                values: [
                    { type_name: "SelectOption", name: "All", value: "All" },
                    { type_name: "SelectOption", name: "Action", value: "Action" },
                    { type_name: "SelectOption", name: "Adult", value: "Adult" },
                    { type_name: "SelectOption", name: "Adventure", value: "Adventure" },
                    { type_name: "SelectOption", name: "Animated", value: "Animated" },
                    { type_name: "SelectOption", name: "Comedy", value: "Comedy" },
                    { type_name: "SelectOption", name: "Demons", value: "Demons" },
                    { type_name: "SelectOption", name: "Drama", value: "Drama" },
                    { type_name: "SelectOption", name: "Ecchi", value: "Ecchi" },
                    { type_name: "SelectOption", name: "Fantasy", value: "Fantasy" },
                    { type_name: "SelectOption", name: "Full Color", value: "Full_Color" },
                    { type_name: "SelectOption", name: "Gender Bender", value: "Gender_Bender" },
                    { type_name: "SelectOption", name: "Harem", value: "Harem" },
                    { type_name: "SelectOption", name: "Historical", value: "Historical" },
                    { type_name: "SelectOption", name: "Horror", value: "Horror" },
                    { type_name: "SelectOption", name: "Isekai", value: "Isekai" },
                    { type_name: "SelectOption", name: "Josei", value: "Josei" },
                    { type_name: "SelectOption", name: "Life", value: "Life" },
                    { type_name: "SelectOption", name: "Lolicon", value: "Lolicon" },
                    { type_name: "SelectOption", name: "Magic", value: "Magic" },
                    { type_name: "SelectOption", name: "Manhwa", value: "Manhwa" },
                    { type_name: "SelectOption", name: "Martial Arts", value: "Martial_Arts" },
                    { type_name: "SelectOption", name: "Mature", value: "Mature" },
                    { type_name: "SelectOption", name: "Mecha", value: "Mecha" },
                    { type_name: "SelectOption", name: "Military", value: "Military" },
                    { type_name: "SelectOption", name: "Mystery", value: "Mystery" },
                    { type_name: "SelectOption", name: "One Shot", value: "One_Shot" },
                    { type_name: "SelectOption", name: "Psychological", value: "Psychological" },
                    { type_name: "SelectOption", name: "Reincarnation", value: "Reincarnation" },
                    { type_name: "SelectOption", name: "Romance", value: "Romance" },
                    { type_name: "SelectOption", name: "School", value: "School" },
                    { type_name: "SelectOption", name: "School Life", value: "School_Life" },
                    { type_name: "SelectOption", name: "Sci-Fi", value: "Sci_Fi" },
                    { type_name: "SelectOption", name: "Seinen", value: "Seinen" },
                    { type_name: "SelectOption", name: "Shotacon", value: "Shotacon" },
                    { type_name: "SelectOption", name: "Shoujo", value: "Shoujo" },
                    { type_name: "SelectOption", name: "Shoujo Ai", value: "Shoujo_Ai" },
                    { type_name: "SelectOption", name: "Shounen", value: "Shounen" },
                    { type_name: "SelectOption", name: "Shounen Ai", value: "Shounen_Ai" },
                    { type_name: "SelectOption", name: "Slice Of Life", value: "Slice_Of_Life" },
                    { type_name: "SelectOption", name: "Smut", value: "Smut" },
                    { type_name: "SelectOption", name: "Sports", value: "Sports" },
                    { type_name: "SelectOption", name: "Superhero", value: "Superhero" },
                    { type_name: "SelectOption", name: "Supernatural", value: "Supernatural" },
                    { type_name: "SelectOption", name: "Super Power", value: "Super_Power" },
                    { type_name: "SelectOption", name: "Tragedy", value: "Tragedy" },
                    { type_name: "SelectOption", name: "Vampire", value: "Vampire" },
                    { type_name: "SelectOption", name: "Villainess", value: "Villainess" },
                    { type_name: "SelectOption", name: "Web Comic", value: "Web_Comic" },
                    { type_name: "SelectOption", name: "Webtoon", value: "Webtoon" },
                    { type_name: "SelectOption", name: "Yaoi", value: "Yaoi" },
                    { type_name: "SelectOption", name: "Yuri", value: "Yuri" }
                ]
            },
            {
                type_name: "SelectFilter",
                name: "Status",
                state: 0,
                values: [
                    { type_name: "SelectOption", name: "All", value: "All" },
                    { type_name: "SelectOption", name: "Completed", value: "Completed" },
                    { type_name: "SelectOption", name: "Ongoing", value: "Ongoing" }
                ]
            },
            {
                type_name: "SelectFilter",
                name: "SortBy",
                state: 0,
                values: [
                    { type_name: "SelectOption", name: "Popularity", value: "Popularity" },
                    { type_name: "SelectOption", name: "Latest", value: "Latest" },
                    { type_name: "SelectOption", name: "A-Z", value: "A-Z" }
                ]
            },
            {
                type_name: "SelectFilter",
                name: "Type",
                state: 0,
                values: [
                    { type_name: "SelectOption", name: "All", value: "All" },
                    { type_name: "SelectOption", name: "Manga", value: "Manga" },
                    { type_name: "SelectOption", name: "Manhwa", value: "Manhwa" },
                    { type_name: "SelectOption", name: "Manhua", value: "Manhua" }
                ]
            }
        ];
    }

    async search(query, page, filters) {
        // When no query is provided but filters are active, use the genre browse URL
        // with query params (ww3.mangafreak.me supports ?Status=X&SortBy=Y)
        if (!query || query.trim() === '') {
            let statusParam = '';
            let sortParam = '';
            let typeParam = '';
            let genre = 'All';
            if (filters && Array.isArray(filters)) {
                for (const f of filters) {
                    if (f.type_name === 'SelectFilter' && f.values && f.values.length > f.state) {
                        const val = f.values[f.state].value;
                        if (f.name === 'Genre' && val !== 'All') genre = val;
                        if (f.name === 'Status' && val !== 'All') statusParam = val;
                        if (f.name === 'SortBy' && val !== 'Popularity') sortParam = val;
                        if (f.name === 'Type' && val !== 'All') typeParam = val;
                    }
                }
            }
            let qs = '';
            if (statusParam) qs += `Status=${encodeURIComponent(statusParam)}&`;
            if (sortParam) qs += `SortBy=${encodeURIComponent(sortParam)}&`;
            if (typeParam) qs += `Type=${encodeURIComponent(typeParam)}&`;
            
            if (qs.endsWith('&')) {
                qs = qs.slice(0, -1);
            }
            let url = `${this.source.baseUrl}/Genre/${genre}/${page}`;
            if (qs !== '') url += `?${qs}`;
            
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
                            imageUrl: this._cleanImageUrl(imageUrl),
                            link: link.startsWith('http') ? link : `${this.source.baseUrl}${link}`
                        });
                    }
                }
            }
            return { list: list, hasNextPage: list.length > 0 };
        }

        // Normal text search
        const url = `${this.source.baseUrl}/Find/${encodeURIComponent(query)}`;
        const res = await this.client.get(url, this.getHeaders());
        const doc = new Document(res.body);
        const list = [];
        const items = doc.querySelectorAll(".manga_search_item, .manga_series_item, .ranking_item");

        for (const item of items) {
            // The first <a> in each .manga_search_item wraps only the thumbnail <img>
            // (no text/title), so prefer the title link inside <h3> when present.
            const titleA = item.querySelector("h3 a") || item.querySelector(".ranking_item_info a") || item.querySelector("a");
            const img = item.querySelector("img");
            if (titleA) {
                const strong = titleA.querySelector("strong");
                const title = (strong ? strong.text : null) || titleA.attr("title") || titleA.text || (img ? img.attr("alt") : "");
                const link = titleA.attr("href");
                const imageUrl = img ? (img.attr("src") || img.attr("data-src")) : "";
                if (title && title.trim() && link) {
                    list.push({
                        name: title.trim(),
                        imageUrl: this._cleanImageUrl(imageUrl),
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
        const chapItems = doc.querySelectorAll(".chapter-link, a[href*='/Read1_'], .manga_series_list td a");
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
            name: title.trim(),
            title: title.trim(),
            description: description.trim(),
            imageUrl: this._cleanImageUrl(imageUrl),
            chapters: chapters
        };
    }

    async getPageList(url) {
        const fullUrl = url.startsWith('http') ? url : `${this.source.baseUrl}${url}`;
        const res = await this.client.get(fullUrl, this.getHeaders());
        const html = res.body || "";
        const doc = new Document(html);
        const pages = [];
        const seen = new Set();
        const imgTags = doc.select(".mySlides img, #gauto img, .my-slides img, div.slides_control img, img[src*='manga']");
        for (const img of imgTags) {
            const src = img.attr("src") || img.attr("data-src") || img.getSrc || "";
            if (src && !src.includes("banner") && !src.includes("logo") && !seen.has(src)) {
                seen.add(src);
                pages.push({
                    url: src.startsWith('http') ? src : `${this.source.baseUrl}${src.startsWith('/') ? '' : '/'}${src}`,
                    headers: {
                        "Referer": "https://ww3.mangafreak.me/",
                        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"
                    }
                });
            }
        }
        return pages;
    }
}

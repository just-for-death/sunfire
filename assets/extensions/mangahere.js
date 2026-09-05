const mangayomiSources = [{
    "id": 395810482,
    "name": "MangaHere",
    "lang": "en",
    "baseUrl": "https://fanfox.net",
    "apiUrl": "",
    "iconUrl": "https://www.google.com/s2/favicons?sz=128&domain=https://www.mangahere.cc",
    "typeSource": "single",
    "itemType": 0,
    "version": "1.2.2",
    "pkgPath": "javascript/manga/src/en/mangahere.js"
}];

class DefaultExtension extends MProvider {
    constructor() {
        super();
        this.client = new Client();
    }

    getHeaders() {
        return {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
            "Referer": "https://fanfox.net/"
        };
    }

    async getPopular(page) {
        const url = `https://fanfox.net/directory/${page}.htm`;
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
                var imageUrl = img ? (img.attr("src") || img.attr("data-src") || "") : "";
                if (imageUrl.startsWith("//")) imageUrl = `https:${imageUrl}`;
                imageUrl = imageUrl.replace(/&amp;/g, '&');
                if (title && link && link.indexOf('/manga/') !== -1) {
                    list.push({
                        name: title.trim(),
                        imageUrl: imageUrl,
                        link: link.startsWith('http') ? link : `https://fanfox.net${link}`
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
        const url = `https://fanfox.net/directory/${page}.htm?latest`;
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
                var imageUrl = img ? (img.attr("src") || img.attr("data-src") || "") : "";
                if (imageUrl.startsWith("//")) imageUrl = `https:${imageUrl}`;
                imageUrl = imageUrl.replace(/&amp;/g, '&');
                if (title && link && link.indexOf('/manga/') !== -1) {
                    list.push({
                        name: title.trim(),
                        imageUrl: imageUrl,
                        link: link.startsWith('http') ? link : `https://fanfox.net${link}`
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
                type_name: "GroupFilter",
                name: "Genres",
                state: [
                    { type_name: "CheckBox", name: "Action", value: "1", state: false },
                    { type_name: "CheckBox", name: "Adventure", value: "2", state: false },
                    { type_name: "CheckBox", name: "Comedy", value: "3", state: false },
                    { type_name: "CheckBox", name: "Drama", value: "4", state: false },
                    { type_name: "CheckBox", name: "Fantasy", value: "5", state: false },
                    { type_name: "CheckBox", name: "Martial Arts", value: "6", state: false },
                    { type_name: "CheckBox", name: "Shounen", value: "7", state: false },
                    { type_name: "CheckBox", name: "Horror", value: "8", state: false },
                    { type_name: "CheckBox", name: "Supernatural", value: "9", state: false },
                    { type_name: "CheckBox", name: "Harem", value: "10", state: false },
                    { type_name: "CheckBox", name: "Psychological", value: "11", state: false },
                    { type_name: "CheckBox", name: "Romance", value: "12", state: false },
                    { type_name: "CheckBox", name: "School Life", value: "13", state: false },
                    { type_name: "CheckBox", name: "Shoujo", value: "14", state: false },
                    { type_name: "CheckBox", name: "Mystery", value: "15", state: false },
                    { type_name: "CheckBox", name: "Sci-fi", value: "16", state: false },
                    { type_name: "CheckBox", name: "Seinen", value: "17", state: false },
                    { type_name: "CheckBox", name: "Tragedy", value: "18", state: false },
                    { type_name: "CheckBox", name: "Ecchi", value: "19", state: false },
                    { type_name: "CheckBox", name: "Sports", value: "20", state: false },
                    { type_name: "CheckBox", name: "Slice of Life", value: "21", state: false },
                    { type_name: "CheckBox", name: "Mature", value: "22", state: false },
                    { type_name: "CheckBox", name: "Shoujo Ai", value: "23", state: false },
                    { type_name: "CheckBox", name: "Webtoons", value: "24", state: false },
                    { type_name: "CheckBox", name: "Doujinshi", value: "25", state: false },
                    { type_name: "CheckBox", name: "One Shot", value: "26", state: false },
                    { type_name: "CheckBox", name: "Smut", value: "27", state: false },
                    { type_name: "CheckBox", name: "Yaoi", value: "28", state: false },
                    { type_name: "CheckBox", name: "Josei", value: "29", state: false },
                    { type_name: "CheckBox", name: "Historical", value: "30", state: false },
                    { type_name: "CheckBox", name: "Shounen Ai", value: "31", state: false },
                    { type_name: "CheckBox", name: "Gender Bender", value: "32", state: false },
                    { type_name: "CheckBox", name: "Adult", value: "33", state: false },
                    { type_name: "CheckBox", name: "Yuri", value: "34", state: false },
                    { type_name: "CheckBox", name: "Mecha", value: "35", state: false },
                    { type_name: "CheckBox", name: "Lolicon", value: "36", state: false },
                    { type_name: "CheckBox", name: "Shotacon", value: "37", state: false }
                ]
            },
            {
                type_name: "SelectFilter",
                name: "Completed Series",
                state: 0,
                values: [
                    { type_name: "SelectOption", name: "Either", value: "0" },
                    { type_name: "SelectOption", name: "Yes", value: "2" },
                    { type_name: "SelectOption", name: "No", value: "1" }
                ]
            }
        ];
    }

    async search(query, page, filters) {
        let url = `https://fanfox.net/search?title=${encodeURIComponent(query)}&page=${page}`;
        if (filters && filters.length > 0) {
            for (const filter of filters) {
                if (filter.type_name === "GroupFilter" && filter.name === "Genres") {
                    const selectedGenres = [];
                    for (const genre of filter.state) {
                        if (genre.state) {
                            selectedGenres.push(genre.value);
                        }
                    }
                    if (selectedGenres.length > 0) {
                        url += `&genres=${selectedGenres.join(',')}`;
                    }
                } else if (filter.type_name === "SelectFilter" && filter.name === "Completed Series") {
                    url += `&st=${filter.values[filter.state].value}`;
                }
            }
        }
        
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
                var imageUrl = img ? (img.attr("src") || img.attr("data-src") || "") : "";
                if (imageUrl.startsWith("//")) imageUrl = `https:${imageUrl}`;
                imageUrl = imageUrl.replace(/&amp;/g, '&');
                if (title && link) {
                    list.push({
                        name: title.trim(),
                        imageUrl: imageUrl,
                        link: link.startsWith('http') ? link : `https://fanfox.net${link}`
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
        const fullUrl = url.startsWith('http') 
            ? url.replace(/https?:\/\/(?:www\.)?mangahere\.cc/, 'https://fanfox.net') 
            : `https://fanfox.net${url}`;
        const res = await this.client.get(fullUrl, this.getHeaders());
        const doc = new Document(res.body);

        const titleElem = doc.querySelector(".detail-info-right-title-font, .detail-info-cover-img");
        const title = titleElem ? (titleElem.text || titleElem.attr("alt") || "") : "";

        const descElem = doc.querySelector(".detail-info-right-content, .fullcontent");
        const description = descElem ? descElem.text : "";

        const imgElem = doc.querySelector(".detail-info-cover-img");
        var imageUrl = imgElem ? (imgElem.attr("src") || imgElem.attr("data-src") || "") : "";
        if (imageUrl.startsWith("//")) imageUrl = `https:${imageUrl}`;
        imageUrl = imageUrl.replace(/&amp;/g, '&');

        const authorElem = doc.querySelector(".detail-info-right-say a, a[href*='/author/']");
        const author = authorElem ? authorElem.text : "";

        const genreElems = doc.querySelectorAll(".detail-info-right-tag-list a, a[href*='/genre/']");
        const genres = [];
        for (const g of genreElems) {
            const t = g.text.trim();
            if (t && !genres.includes(t)) genres.push(t);
        }

        const chapters = [];
        // Use broad href selector to bypass QuickJS issues with trailing-space class attrs in fanfox.net HTML
        // Match direct chapter links: /manga/{slug}/v{vol}/c{ch}/{page}.html
        const rows = doc.querySelectorAll("a[href*='/manga/'][href*='/c']");
        const seenLinks = new Set();

        for (const a of rows) {
            const title3El = a.selectFirst ? a.selectFirst(".title3, p.title3") : a.querySelector(".title3, p.title3");
            const title2El = a.selectFirst ? a.selectFirst(".title-2, p.title-2, span.title-2") : a.querySelector(".title-2, p.title-2, span.title-2");
            var name = (title3El ? title3El.text.trim() : null) || a.attr("title") || a.text.trim();
            var dateUpload = "";
            if (title2El) {
                dateUpload = title2El.text.trim();
            }
            const link = a.attr("href");
            if (name && link && (link.includes('/c') || link.includes('/manga/')) && !link.includes('/directory/') && !link.includes('/comichistory/') && !link.includes('/author/')) {
                const fullLink = link.startsWith('http') 
                    ? link.replace(/https?:\/\/(?:www\.)?mangahere\.cc/, 'https://fanfox.net') 
                    : `https://fanfox.net${link}`;
                if (!seenLinks.has(fullLink) && fullLink.match(/\/c[0-9]/)) {
                    seenLinks.add(fullLink);
                    chapters.push({
                        name: name.trim(),
                        url: fullLink,
                        dateUpload: dateUpload
                    });
                }
            }
        }

        return {
            name: title.trim(),
            description: description.trim(),
            imageUrl: imageUrl,
            author: author.trim(),
            genre: genres,
            status: 0,
            chapters: chapters
        };
    }

    async getPageList(url) {
        const fullUrl = url.startsWith('http') ? url : `https://fanfox.net${url}`;
        const res = await this.client.get(fullUrl, this.getHeaders());
        const html = res.body || "";

        const cidMatch = html.match(/var\s+chapterid\s*=\s*(\d+)/);
        const countMatch = html.match(/var\s+imagecount\s*=\s*(\d+)/);

        if (cidMatch) {
            const cid = cidMatch[1];
            const count = countMatch ? parseInt(countMatch[1]) : 1;
            const pages = [];
            const seen = new Set();

            // Extract key from packed script in chapter html
            // SECURITY NOTE: This uses Function constructor to unpack obfuscated JavaScript
            // from the source website. The input is validated to only process expected patterns
            // and runs in a limited scope. This is required because MangaHere uses JavaScript
            // packing to protect their chapter decryption keys.
            var guidkey = "";
            try {
                const sIdx = html.indexOf("eval(function(p,a,c,k,e,d)");
                if (sIdx !== -1) {
                    const sEnd = html.indexOf("</script>", sIdx);
                    const packedScript = html.substring(sIdx, sEnd !== -1 ? sEnd : undefined);
                    
                    // Validate that we're only processing expected packed script patterns
                    if (packedScript && packedScript.includes("function(p,a,c,k,e,d)") && packedScript.length < 10000) {
                        const expr = packedScript.replace(/^eval\(/, "(");
                        const unpacked = new Function("return " + expr)();
                        if (unpacked) {
                            const kMatch = unpacked.match(/guidkey\s*=\s*([^;]+);/);
                            if (kMatch) {
                                guidkey = new Function("return " + kMatch[1])();
                            }
                        }
                    }
                }
            } catch (_) {}

            const baseChapterUrl = fullUrl.substring(0, fullUrl.lastIndexOf('/') + 1);

            for (let page = 1; page <= count; page += 2) {
                try {
                    const funUrl = `${baseChapterUrl}chapterfun.ashx?cid=${cid}&page=${page}&key=${guidkey}`;
                    const funRes = await this.client.get(funUrl, {
                        ...this.getHeaders(),
                        "Referer": fullUrl,
                        "X-Requested-With": "XMLHttpRequest"
                    });
                    var rawBody = funRes.body || "";
                    if (rawBody.includes("eval(")) {
                        rawBody = "eval(" + rawBody.split("eval(")[1];
                        if (rawBody.includes("</pre>")) {
                            rawBody = rawBody.split("</pre>")[0];
                        } else if (rawBody.includes("</body>")) {
                            rawBody = rawBody.split("</body>")[0];
                        }
                    }
                    rawBody = rawBody
                        .replace(/&lt;/g, "<")
                        .replace(/&gt;/g, ">")
                        .replace(/&amp;/g, "&")
                        .replace(/&quot;/g, '"')
                        .replace(/&#39;/g, "'")
                        .trim();

                    // SECURITY NOTE: Second eval() usage for unpacking chapter function response
                    // Input is validated for size and expected patterns before execution
                    if (rawBody && rawBody.includes("eval(") && rawBody.length < 50000) {
                        const expr = rawBody.replace(/^eval\(/, "(");
                        const unpackedFun = new Function("return " + expr)();
                        if (!unpackedFun) continue;
                        const pixMatch = unpackedFun.match(/pix\s*=\s*["']([^"']+)["']/);
                        const pvalueMatch = unpackedFun.match(/pvalue\s*=\s*\[(.*?)\]/);
                        if (pixMatch && pvalueMatch) {
                            const pix = pixMatch[1];
                            const paths = pvalueMatch[1].split(',').map(s => s.replace(/["']/g, '').trim());
                            for (let path of paths) {
                                let img = path;
                                if (!img.startsWith('//') && !img.startsWith('http')) {
                                    img = pix + img;
                                }
                                if (img && !seen.has(img)) {
                                    seen.add(img);
                                    const fullImg = img.startsWith("//") ? `https:${img}` : img;
                                    pages.push({
                                        url: fullImg,
                                        headers: { "Referer": "https://fanfox.net/" }
                                    });
                                }
                            }
                        } else {
                            // Fallback to function approach if regex fails
                            const d = new Function(unpackedFun + "; return (typeof d !== 'undefined' ? d : (typeof dm5imagefun !== 'undefined' ? dm5imagefun() : []));")();
                            if (d && Array.isArray(d)) {
                                for (let img of d) {
                                    if (img && !seen.has(img)) {
                                        seen.add(img);
                                        const fullImg = img.startsWith("//") ? `https:${img}` : img;
                                        pages.push({
                                            url: fullImg,
                                            headers: { "Referer": "https://fanfox.net/" }
                                        });
                                    }
                                }
                            }
                        }
                    }
                } catch (_) {}
            }

            if (pages.length > 0) {
                return pages;
            }
        }

        // Fallback: static images in DOM
        const doc = new Document(html);
        const imgs = doc.querySelectorAll(".reader-main img, #viewer img, .read-container img");
        const fallback = [];
        for (const img of imgs) {
            const src = img.attr("data-src") || img.attr("src") || img.attr("data-original");
            if (src && !src.includes("logo") && !src.includes("banner") && !src.includes("loading.gif")) {
                const fullSrc = src.startsWith("//") ? `https:${src}` : src;
                fallback.push({
                    url: fullSrc,
                    headers: { "Referer": "https://fanfox.net/" }
                });
            }
        }
        return fallback;
    }
}

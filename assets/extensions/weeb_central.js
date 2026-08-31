const mangayomiSources = [{
    "id": 693275080,
    "name": "Weeb Central",
    "lang": "en",
    "baseUrl": "https://weebcentral.com",
    "apiUrl": "",
    "iconUrl": "https://www.google.com/s2/favicons?sz=128&domain=https://weebcentral.com",
    "typeSource": "single",
    "itemType": 0,
    "version": "1.1.0",
    "pkgPath": "javascript/manga/src/en/weeb_central.js"
}];

class DefaultExtension extends MProvider {
    constructor() {
        super();
        this.client = new Client();
    }
    getHeaders(url) {
        return { "Referer": `${this.source.baseUrl}/` };
    }

    async request(slug) {
        var clean = slug.startsWith('http') ? slug : `${this.source.baseUrl}${slug.startsWith('/') ? slug : '/' + slug}`;
        var res = await this.client.get(clean);
        return new Document(res.body);
    }

    async getPopular(page) {
        const filters = this.getFilterList();
        filters[0].state = 2;
        return await this.search("", page, filters);
    }

    async getLatestUpdates(page) {
        const filters = this.getFilterList();
        filters[0].state = 5;
        return await this.search("", page, filters);
    }

    getImageUrl(id) { return `https://temp.compsci88.com/cover/normal/${id}.webp`; }

    async search(query, page, filters) {
        var offset = 32 * (parseInt(page) - 1);
        var sort = filters && filters[0] && filters[0].values ? filters[0].values[filters[0].state].value : "Best Match";
        var order = filters && filters[1] && filters[1].values ? filters[1].values[filters[1].state].value : "Ascending";
        var translation = filters && filters[2] && filters[2].values ? filters[2].values[filters[2].state].value : "Any";
        var status = "";
        if (filters && filters[3] && filters[3].state) {
            for (var filter of filters[3].state) {
                if (filter.state == true) status += `&included_status=${filter.value}`;
            }
        }
        var type = "";
        if (filters && filters[4] && filters[4].state) {
            for (var filter of filters[4].state) {
                if (filter.state == true) type += `&included_type=${filter.value}`;
            }
        }
        var tags = "";
        if (filters && filters.length > 5 && filters[5].state) {
            for (var filter of filters[5].state) {
                if (filter.state == true) tags += `&included_tag=${filter.value}`;
            }
        }
        var slug = `/search/data?limit=32&offset=${offset}&author=&text=${encodeURIComponent(query)}&sort=${sort}&order=${order}&official=${translation}${status}${type}${tags}&display_mode=Full%20Display`;
        var doc = await this.request(slug);
        var list = [];
        var mangaElements = doc.select("article:has(section)");
        for (var manga of mangaElements) {
            var imgEl = manga.selectFirst("img");
            var imageUrl = imgEl ? (imgEl.attr("src") || imgEl.getSrc || "") : "";
            var details = manga.selectFirst("section > a");
            var rawLink = details ? (details.attr("href") || details.getHref || "") : "";
            var link = rawLink.startsWith("http") ? rawLink : `${this.source.baseUrl}${rawLink.startsWith('/') ? rawLink : '/' + rawLink}`;
            var nameEl = manga.selectFirst("article > div > div > div, a.link");
            var name = nameEl ? nameEl.text.trim() : (details ? details.text.trim() : "");
            if (name && rawLink) {
                list.push({ name, imageUrl, link });
            }
        }

        var nextBtn = doc.selectFirst("a[href*='page=']:contains('Next'), button:contains('Next'), a[rel='next']");
        var hasNextPage = !!nextBtn;
        return { list, hasNextPage };
    }

    statusCode(status) {
        return {
            "Ongoing": 0,
            "Complete": 1,
            "Hiatus": 2,
            "Canceled": 3,
        }[status] ?? 5;
    }

    async getDetail(url) {
        var cleanPath = url.replace(/^https?:\/\/[^\/]+/, '');
        if (!cleanPath.startsWith('/')) cleanPath = '/' + cleanPath;
        var slug = cleanPath.startsWith('/series/') ? cleanPath : '/series' + cleanPath;
        var linkMatch = slug.match(/\/series\/([^\/]+)/);
        var link = linkMatch ? linkMatch[1] : slug.replace('/series/', '');

        var doc = await this.request(slug);
        var imageUrl = this.getImageUrl(link);
        var titleEl = doc.selectFirst("h1, .link.text-2xl, section h1");
        var seriesTitle = titleEl ? titleEl.text.trim() : "";
        var descEl = doc.selectFirst("p.whitespace-pre-wrap.break-words");
        var description = descEl ? descEl.text.trim() : "";

        var chapters = [];
        var ul = doc.select("ul.flex.flex-col.gap-4 > li");
        var author = "";
        var genre = [];
        var status = 5;
        for (var li of ul) {
            var strong = li.selectFirst("strong");
            if (!strong) continue;
            var strongTxt = strong.text;
            if (strongTxt.indexOf("Author(s):") != -1) {
                var aEl = li.selectFirst("a");
                author = aEl ? aEl.text.trim() : "";
            } else if (strongTxt.indexOf("Tags(s):") != -1) {
                li.select("a").forEach(a => genre.push(a.text.trim()));
            } else if (strongTxt.indexOf("Status:") != -1) {
                var sEl = li.selectFirst("a");
                status = this.statusCode(sEl ? sEl.text.trim() : "");
            }
        }

        var chapSlug = `/series/${link}/full-chapter-list`;
        var chapDoc = await this.request(chapSlug);
        var chapList = chapDoc.select("div.flex.items-center");
        for (var chap of chapList) {
            var spanEl = chap.selectFirst("span.grow.flex.items-center.gap-2");
            var innerSpan = spanEl ? spanEl.selectFirst("span") : null;
            var timeEl = chap.selectFirst("time.text-datetime") || chap.selectFirst("time");
            var dateUpload = "";
            if (timeEl) {
                var dt = timeEl.attr("datetime") || (timeEl.text || "").trim();
                if (dt) {
                    var parsed = Date.parse(dt);
                    if (!isNaN(parsed) && parsed > 0) {
                        dateUpload = parsed.toString();
                    } else {
                        var now = Date.now();
                        var numMatch = dt.match(/(\d+)\s+(second|minute|hour|day|week|month|year)/i);
                        if (numMatch) {
                            var n = parseInt(numMatch[1]);
                            var unit = numMatch[2].toLowerCase();
                            var mult = 1000;
                            if (unit.startsWith("second")) mult = 1000;
                            else if (unit.startsWith("minute")) mult = 60 * 1000;
                            else if (unit.startsWith("hour")) mult = 3600 * 1000;
                            else if (unit.startsWith("day")) mult = 86400 * 1000;
                            else if (unit.startsWith("week")) mult = 7 * 86400 * 1000;
                            else if (unit.startsWith("month")) mult = 30 * 86400 * 1000;
                            else if (unit.startsWith("year")) mult = 365 * 86400 * 1000;
                            dateUpload = (now - (n * mult)).toString();
                        }
                    }
                }
            }
            var aEl = chap.selectFirst("a");
            var inputEl = chap.selectFirst("input");
            
            var chapUrl = "";
            if (aEl) {
                chapUrl = aEl.attr("href") || aEl.getHref || "";
            } else if (inputEl) {
                chapUrl = inputEl.attr("value") || "";
            }
            // Fallback: extract ULID from any attribute containing /chapters/
            if (!chapUrl) {
                var raw = chap.attr("hx-get") || chap.attr("data-url") || "";
                var m = raw.match(/\/chapters\/([a-zA-Z0-9]{26})/i);
                if (m) chapUrl = m[0];
            }
            // Ensure absolute URL
            if (chapUrl && !chapUrl.startsWith("http")) {
                chapUrl = `${this.source.baseUrl}${chapUrl.startsWith("/") ? "" : "/"}${chapUrl}`;
            }
            var name = innerSpan ? innerSpan.text.trim() : (spanEl ? spanEl.text.trim() : "");
            if (!name && aEl) name = aEl.text.trim();
            if (!name) name = "Chapter";
            if (chapUrl) {
                chapters.push({ name, url: chapUrl, dateUpload });
            }
        }
        return { name: seriesTitle, title: "", description, imageUrl, author, genre, status, chapters };
    }

    async getPageList(url) {
        var clean = url.replace(/^https?:\/\/[^\/]+/, '');
        // Extract ULID chapter ID robustly (case-insensitive)
        var chapMatch = clean.match(/\/chapters\/([a-zA-Z0-9]{26})/i);
        var chapId = chapMatch ? chapMatch[1] : clean.replace(/.*chapters\//, '').replace(/\/.*$/, '').trim();
        if (!chapId) return [];

        var slug = `/chapters/${chapId}/images?is_prev=False&current_page=1&reading_style=long_strip`;
        var doc = await this.request(slug);

        var urls = [];
        
        var images = doc.select("section[id*='chapter'] img, #chapter-images img, section#chapter-images img, img[src*='lastation'], img[src*='scans'], img[src*='compsci88'], img[src*='lowee'], img[src*='weebcentral'], img[src*='/manga/'], chapter-page img, img");
        for (var page of images) {
            var src = page.attr("src") || page.attr("data-src") || page.getSrc || "";
            src = src.trim();
            if (src && src.startsWith("http") && !src.includes("brand.png") && !src.includes("logo") && !src.includes("404.png") && !urls.includes(src)) urls.push(src);
        }

        return urls.map(x => ({ url: x, headers: { Referer: `${this.source.baseUrl}/` } }));
    }

    getFilterList() {
        return [
            {
                type_name: "SelectFilter",
                name: "Order By",
                state: 0,
                values: [
                    { type_name: "SelectOption", name: "Best Match", value: "Best Match" },
                    { type_name: "SelectOption", name: "Alphabet", value: "Alphabet" },
                    { type_name: "SelectOption", name: "Popularity", value: "Popularity" },
                    { type_name: "SelectOption", name: "Subscribers", value: "Subscribers" },
                    { type_name: "SelectOption", name: "Recently Added", value: "Recently Added" },
                    { type_name: "SelectOption", name: "Latest Updates", value: "Latest Updates" }
                ]
            },
            {
                type_name: "SelectFilter",
                name: "Sort",
                state: 1,
                values: [
                    { type_name: "SelectOption", name: "Ascending", value: "Ascending" },
                    { type_name: "SelectOption", name: "Descending", value: "Descending" }
                ]
            },
            {
                type_name: "SelectFilter",
                name: "Translation",
                state: 0,
                values: [
                    { type_name: "SelectOption", name: "Any", value: "Any" },
                    { type_name: "SelectOption", name: "Official Only", value: "Official Only" },
                    { type_name: "SelectOption", name: "Non-Official Only", value: "Non-Official Only" }
                ]
            },
            {
                type_name: "GroupFilter",
                name: "Status",
                state: [
                    { type_name: "CheckBox", name: "Complete", value: "Complete" },
                    { type_name: "CheckBox", name: "Ongoing", value: "Ongoing" },
                    { type_name: "CheckBox", name: "Canceled", value: "Canceled" },
                    { type_name: "CheckBox", name: "Hiatus", value: "Hiatus" }
                ]
            },
            {
                type_name: "GroupFilter",
                name: "Type",
                state: [
                    { type_name: "CheckBox", name: "Manga", value: "Manga" },
                    { type_name: "CheckBox", name: "Manhwa", value: "Manhwa" },
                    { type_name: "CheckBox", name: "Manhua", value: "Manhua" }
                ]
            }
        ];
    }
}

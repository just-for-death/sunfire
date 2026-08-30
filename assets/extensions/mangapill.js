const mangayomiSources = [
  {
    "name": "Mangapill",
    "id": 960321322,
    "lang": "en",
    "baseUrl": "https://mangapill.com",
    "apiUrl": "",
    "iconUrl":
      "https://www.google.com/s2/favicons?sz=64&domain=https://mangapill.com/",
    "typeSource": "single",
    "isManga": true,
    "version": "1.3.1",
    "dateFormat": "",
    "dateFormatLocale": "",
    "pkgPath": "javascript/manga/src/en/mangapill.js",
  },
];

class DefaultExtension extends MProvider {
  getHeaders(url) {
    return {
      "Referer": this.source.baseUrl,
    };
  }

  statusCode(status) {
    return (
      {
        "publishing": 0,
        "finished": 1,
        "on hiatus": 2,
        "discontinued": 3,
        "not yet published": 4,
      }[status] ?? 5
    );
  }

  async getPreference(key) {
    const preferences = new SharedPreferences();
    return parseInt(preferences.get(key));
  }

      async getMangaList(slug) {
    var cleanSlug = slug || "mangas";
    var url = cleanSlug.startsWith('http') ? cleanSlug : `${this.source.baseUrl}/${cleanSlug.replace(/^\//, '')}`;
    var res = await new Client().get(url, this.getHeaders());
    var doc = new Document(res.body);
    var list = [];
    var seen = new Set();

    // 1. Try structured card container parsing (covers Homepage /?page=1, /mangas/new, /search)
    var cards = doc.select("div[class*='grid'] > div, div.grid > div");
    for (var card of cards) {
      var mangaA = card.selectFirst("a[href*='/manga/']");
      var img = card.selectFirst("img");
      if (mangaA) {
        var link = mangaA.getHref || mangaA.attr("href") || "";
        if (!link || seen.has(link) || link.includes("/chapters/")) continue;

        var name = mangaA.text ? mangaA.text.trim() : "";
        if (!name && img) {
          var alt = img.attr("alt") || "";
          name = alt.includes("  ") ? alt.split("  ")[0].trim() : alt.trim();
        }

        var imageUrl = "";
        if (img) {
          var src = img.getSrc || img.attr("data-src") || img.attr("src") || "";
          if (src) imageUrl = src.startsWith("//") ? `https:${src}` : src;
        }

        if (name && link) {
          seen.add(link);
          list.push({
            name: name,
            imageUrl: imageUrl,
            link: link.startsWith("http") ? link : `${this.source.baseUrl}${link.startsWith('/') ? link : '/' + link}`
          });
        }
      }
    }

    // 2. Fallback to anchor iteration if no cards found
    if (list.length === 0) {
      var anchors = doc.select("a[href*='/manga/']");
      for (var a of anchors) {
        var link = a.getHref || a.attr("href") || "";
        if (!link || seen.has(link) || link.includes("/chapters/")) continue;

        var img = a.selectFirst("img");
        var imageUrl = "";
        var name = a.text ? a.text.trim() : "";

        if (img) {
          var src = img.getSrc || img.attr("data-src") || img.attr("src") || "";
          if (src) imageUrl = src.startsWith("//") ? `https:${src}` : src;
          var alt = img.attr("alt") || "";
          if (alt && !name) {
            name = alt.includes("  ") ? alt.split("  ")[0].trim() : alt.trim();
          }
        }

        if (name && link) {
          seen.add(link);
          list.push({
            name: name,
            imageUrl: imageUrl,
            link: link.startsWith("http") ? link : `${this.source.baseUrl}${link.startsWith('/') ? link : '/' + link}`
          });
        }
      }
    }

    return { list, hasNextPage: list.length >= 10 };
  }

  async getPopular(page) {
    // mangapill.com homepage shows popular/trending manga
    return await this.getMangaList(`?page=${page}`);
  }
  get supportsLatest() {
    throw new Error("supportsLatest not implemented");
  }

  async getLatestUpdates(page) {
    return await this.getMangaList(`mangas/new?page=${page}`);
  }

  async searchManga(query, status, type, genre, page) {
    var slug = `search?q=${encodeURIComponent(query)}&status=${status}&type=${type}${genre}&page=${page}`;
    return await this.getMangaList(slug);
  }

  async search(query, page, filters) {
    var type = "";
    var status = "";
    var genre = "";

    if (filters && filters.length > 0) {
      for (var filter of filters) {
        if (filter.type_name === "SelectFilter") {
          if (filter.name === "Type" && filter.state != null) {
            type = filter.values[filter.state]?.value ?? "";
          } else if (filter.name === "Status" && filter.state != null) {
            status = filter.values[filter.state]?.value ?? "";
          }
        } else if (filter.type_name === "GroupFilter" && filter.name === "Genre") {
          if (Array.isArray(filter.state)) {
            for (var state of filter.state) {
              if (state.state === true) {
                genre += `&genre=${encodeURIComponent(state.value)}`;
              }
            }
          }
        }
      }
    }
    return await this.searchManga(query || "", status, type, genre, page);
  }

  async getMangaDetail(slug) {
    var lang = await this.getPreference("pref_title_lang");
    var baseUrl = this.source.baseUrl;
    if (slug.includes(baseUrl)) slug = slug.replace(baseUrl, "");

    var link = `${baseUrl}${slug.startsWith('/') ? slug : '/' + slug}`;
    var res = await new Client().get(link, this.getHeaders());
    var doc = new Document(res.body);

    // Safe title extraction
    var nameEl = doc.selectFirst(".mb-3 .font-bold.text-lg");
    var mangaName = nameEl ? nameEl.text : "";
    var altEl = doc.selectFirst(".mb-3 .text-sm.text-secondary");
    if (altEl && lang == 2) mangaName = altEl.text;

    // Safe description extraction
    var metaEl = doc.selectFirst("meta[name='description']");
    var description = metaEl ? metaEl.attr("content") : "";

    // Safe image extraction
    var imgEl = doc.selectFirst(".w-full.h-full, img.object-cover");
    var imageUrl = imgEl ? (imgEl.getSrc || imgEl.attr("src") || imgEl.attr("data-src") || "") : "";
    if (imageUrl.startsWith("//")) imageUrl = `https:${imageUrl}`;

    // Status - safe access
    var statusText = "";
    try {
      var gridDivs = doc.select(".grid.grid-cols-1 > div");
      if (gridDivs && gridDivs.length > 1) {
        var statusDiv = gridDivs[1].selectFirst("div");
        if (statusDiv) statusText = statusDiv.text;
      }
    } catch (_) {}
    var status = this.statusCode(statusText.toLowerCase());

    var genre = [];
    var genreList = doc.select("a.mr-1");
    for (var gen of genreList) {
      genre.push(gen.text);
    }

    var chapters = [];
    var chapList = doc.select("div.my-3.grid > a");
    for (var chap of chapList) {
      var name = chap.text;
      var chapUrl = chap.getHref || chap.attr("href") || "";
      if (chapUrl && !chapUrl.startsWith("http")) {
        chapUrl = `${baseUrl}${chapUrl.startsWith('/') ? chapUrl : '/' + chapUrl}`;
      }
      chapters.push({ name, url: chapUrl });
    }
    return {
      name: mangaName,
      title: mangaName,
      description,
      link,
      imageUrl,
      status,
      genre,
      chapters,
    };
  }

  async getDetail(url) {
    return await this.getMangaDetail(url);
  }

  async getVideoList(url) {
    throw new Error("getVideoList not implemented");
  }

  async getPageList(url) {
    var link = url.startsWith('http') ? url : `${this.source.baseUrl}${url.startsWith('/') ? url : '/' + url}`;

    var res = await new Client().get(link, this.getHeaders());
    var doc = new Document(res.body);

    var pages = [];
    var seen = new Set();
    var imgElements = doc.select("chapter-page img, picture img, img[data-src]");
    for (var img of imgElements) {
      var src = img.attr("data-src") || img.attr("src") || img.getSrc || "";
      if (src && !seen.has(src) && !src.includes("logo") && !src.includes("banner")) {
        seen.add(src);
        pages.push({ url: src, headers: { "Referer": "https://mangapill.com/" } });
      }
    }
    if (pages.length === 0) {
      var allImgs = doc.select("img");
      for (var fImg of allImgs) {
        var src = fImg.attr("data-src") || fImg.attr("src") || fImg.getSrc || "";
        if (src && !seen.has(src) && !src.includes("logo") && !src.includes("banner") && src.startsWith("http")) {
          seen.add(src);
          pages.push({ url: src, headers: { "Referer": "https://mangapill.com/" } });
        }
      }
    }

    return pages;
  }

  getFilterList() {
    return [
      {
        type_name: "SelectFilter",
        name: "Type",
        state: 0,
        values: [
          ["All", ""],
          ["Manga", "manga"],
          ["Novel", "novel"],
          ["One-Shot", "one-shot"],
          ["Doujinshi", "doujinshi"],
          ["Manhwa", "manhwa"],
          ["Manhua", "manhua"],
          ["Oel", "oel"],
        ].map((x) => ({ type_name: "SelectOption", name: x[0], value: x[1] })),
      },
      {
        type_name: "SelectFilter",
        name: "Status",
        state: 0,
        values: [
          ["All", ""],
          ["Publishing", "publishing"],
          ["Finished", "finished"],
          ["On hiatus", "on hiatus"],
          ["Discontinued", "discontinued"],
          ["Not yet published", "not yet published"],
        ].map((x) => ({ type_name: "SelectOption", name: x[0], value: x[1] })),
      },
      {
        type_name: "GroupFilter",
        name: "Genre",
        state: [
          ["Action", "Action"],
          ["Adventure", "Adventure"],
          ["Cars", "Cars"],
          ["Comedy", "Comedy"],
          ["Dementia", "Dementia"],
          ["Demons", "Demons"],
          ["Doujinshi", "Doujinshi"],
          ["Drama", "Drama"],
          ["Ecchi", "Ecchi"],
          ["Fantasy", "Fantasy"],
          ["Game", "Game"],
          ["Gender Bender", "Gender Bender"],
          ["Harem", "Harem"],
          ["Historical", "Historical"],
          ["Horror", "Horror"],
          ["Isekai", "Isekai"],
          ["Josei", "Josei"],
          ["Kids", "Kids"],
          ["Magic", "Magic"],
          ["Martial Arts", "Martial Arts"],
          ["Mecha", "Mecha"],
          ["Military", "Military"],
          ["Music", "Music"],
          ["Mystery", "Mystery"],
          ["Parody", "Parody"],
          ["Police", "Police"],
          ["Psychological", "Psychological"],
          ["Romance", "Romance"],
          ["Samurai", "Samurai"],
          ["School", "School"],
          ["Sci-Fi", "Sci-Fi"],
          ["Seinen", "Seinen"],
          ["Shoujo", "Shoujo"],
          ["Shoujo Ai", "Shoujo Ai"],
          ["Shounen", "Shounen"],
          ["Shounen Ai", "Shounen Ai"],
          ["Slice of Life", "Slice of Life"],
          ["Space", "Space"],
          ["Sports", "Sports"],
          ["Super Power", "Super Power"],
          ["Supernatural", "Supernatural"],
          ["Thriller", "Thriller"],
          ["Tragedy", "Tragedy"],
          ["Vampire", "Vampire"],
          ["Yaoi", "Yaoi"],
          ["Yuri", "Yuri"],
        ].map((x) => ({ type_name: "CheckBox", name: x[0], value: x[1], state: false })),
      },
    ];
  }

  getSourcePreferences() {
    return [
      {
        key: "pref_popular_content",
        listPreference: {
          title: "Preferred popular content",
          summary: "",
          valueIndex: 0,
          entries: ["New Mangas", "Recent Chapters"],
          entryValues: ["1", "2"],
        },
      },
      {
        key: "pref_latest_content",
        listPreference: {
          title: "Preferred latest content",
          summary: "",
          valueIndex: 1,
          entries: ["New Mangas", "Recent Chapters"],
          entryValues: ["1", "2"],
        },
      },
      {
        key: "pref_title_lang",
        listPreference: {
          title: "Preferred title language",
          summary: "",
          valueIndex: 0,
          entries: ["Romaji", "English"],
          entryValues: ["1", "2"],
        },
      },
    ];
  }
}

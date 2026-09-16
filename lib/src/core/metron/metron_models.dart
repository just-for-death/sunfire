/// Representation of a Publisher from Metron.cloud.
class MetronPublisher {
  final int id;
  final String name;

  const MetronPublisher({
    required this.id,
    required this.name,
  });

  factory MetronPublisher.fromJson(Map<String, dynamic> json) {
    return MetronPublisher(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? 'Unknown Publisher',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

/// Representation of a Comic Series from Metron.cloud.
class MetronSeries {
  final int id;
  final String name;
  final String? sortName;
  final int? volume;
  final int? yearBegan;
  final int? yearEnd;
  final int issueCount;
  final MetronPublisher? publisher;
  final String? status;
  final String? seriesType;
  final String? description;
  final List<String> genres;
  final String? image;

  const MetronSeries({
    required this.id,
    required this.name,
    this.sortName,
    this.volume,
    this.yearBegan,
    this.yearEnd,
    this.issueCount = 0,
    this.publisher,
    this.status,
    this.seriesType,
    this.description,
    this.genres = const [],
    this.image,
  });

  String get displayName {
    if (yearBegan != null && yearBegan! > 0) {
      return '$name ($yearBegan)';
    }
    return name;
  }

  factory MetronSeries.fromJson(Map<String, dynamic> json) {
    MetronPublisher? pub;
    if (json['publisher'] is Map<String, dynamic>) {
      pub = MetronPublisher.fromJson(json['publisher'] as Map<String, dynamic>);
    } else if (json['publisher'] is String) {
      pub = MetronPublisher(id: 0, name: json['publisher'] as String);
    }

    String? statusStr;
    if (json['status'] is Map<String, dynamic>) {
      statusStr = json['status']['name'] as String?;
    } else if (json['status'] is String) {
      statusStr = json['status'] as String;
    }

    String? typeStr;
    if (json['series_type'] is Map<String, dynamic>) {
      typeStr = json['series_type']['name'] as String?;
    } else if (json['series_type'] is String) {
      typeStr = json['series_type'] as String;
    }

    final genresList = <String>[];
    if (json['genres'] is List) {
      for (final g in json['genres'] as List) {
        if (g is Map<String, dynamic> && g['name'] != null) {
          genresList.add(g['name'].toString());
        } else if (g is String) {
          genresList.add(g);
        }
      }
    }

    return MetronSeries(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] as String? ?? json['series'] as String? ?? 'Untitled Series',
      sortName: json['sort_name'] as String?,
      volume: json['volume'] is int ? json['volume'] as int : int.tryParse(json['volume']?.toString() ?? ''),
      yearBegan: json['year_began'] is int ? json['year_began'] as int : int.tryParse(json['year_began']?.toString() ?? ''),
      yearEnd: json['year_end'] is int ? json['year_end'] as int : int.tryParse(json['year_end']?.toString() ?? ''),
      issueCount: json['issue_count'] is int ? json['issue_count'] as int : int.tryParse(json['issue_count']?.toString() ?? '') ?? 0,
      publisher: pub,
      status: statusStr,
      seriesType: typeStr,
      description: json['desc'] as String? ?? json['description'] as String?,
      genres: genresList,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'sort_name': sortName,
    'volume': volume,
    'year_began': yearBegan,
    'year_end': yearEnd,
    'issue_count': issueCount,
    'publisher': publisher?.toJson(),
    'status': status,
    'series_type': seriesType,
    'description': description,
    'genres': genres,
    'image': image,
  };
}

/// Lightweight issue summary returned in series issue list.
class MetronIssueSummary {
  final int id;
  final String number;
  final String? issueName;
  final String? coverDate;
  final String? storeDate;
  final String? image;

  const MetronIssueSummary({
    required this.id,
    required this.number,
    this.issueName,
    this.coverDate,
    this.storeDate,
    this.image,
  });

  factory MetronIssueSummary.fromJson(Map<String, dynamic> json) {
    return MetronIssueSummary(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      number: json['number']?.toString() ?? '',
      issueName: json['issue'] as String? ?? json['name'] as String?,
      coverDate: json['cover_date'] as String?,
      storeDate: json['store_date'] as String?,
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'number': number,
    'issue': issueName,
    'cover_date': coverDate,
    'store_date': storeDate,
    'image': image,
  };
}

/// Rate limit snapshot parsed from Metron response headers.
class MetronRateLimitState {
  final int burstLimit;
  final int burstRemaining;
  final int burstResetSeconds;
  final int sustainedLimit;
  final int sustainedRemaining;
  final int sustainedResetSeconds;
  final DateTime lastUpdated;

  const MetronRateLimitState({
    this.burstLimit = 20,
    this.burstRemaining = 20,
    this.burstResetSeconds = 60,
    this.sustainedLimit = 5000,
    this.sustainedRemaining = 5000,
    this.sustainedResetSeconds = 86400,
    required this.lastUpdated,
  });

  bool get isBurstNearExhausted => burstRemaining <= 2;
  bool get isSustainedNearExhausted => sustainedRemaining <= 50;

  factory MetronRateLimitState.fromHeaders(Map<String, List<String>> headers) {
    int parseHeader(String name, int fallback) {
      final key = headers.keys.firstWhere(
        (k) => k.toLowerCase() == name.toLowerCase(),
        orElse: () => '',
      );
      if (key.isEmpty) return fallback;
      final val = headers[key]?.firstOrNull;
      if (val == null) return fallback;
      return int.tryParse(val) ?? fallback;
    }

    return MetronRateLimitState(
      burstLimit: parseHeader('x-ratelimit-burst-limit', 20),
      burstRemaining: parseHeader('x-ratelimit-burst-remaining', 20),
      burstResetSeconds: parseHeader('x-ratelimit-burst-reset', 60),
      sustainedLimit: parseHeader('x-ratelimit-sustained-limit', 5000),
      sustainedRemaining: parseHeader('x-ratelimit-sustained-remaining', 5000),
      sustainedResetSeconds: parseHeader('x-ratelimit-sustained-reset', 86400),
      lastUpdated: DateTime.now(),
    );
  }
}

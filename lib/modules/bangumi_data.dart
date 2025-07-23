// Bangumi 动漫详情数据模型
class BangumiDetailData {
  final int id;
  final String name;
  final String nameCn;
  final String summary;
  final String date;
  final String platform;
  final BangumiImages images;
  final BangumiRating? rating;
  final BangumiCollection? collection;
  final List<BangumiTag> tags;
  final List<BangumiInfobox> infobox;
  final List<String> metaTags;
  final int totalEpisodes;
  final int eps;
  final int volumes;
  final int type;
  final bool series;
  final bool locked;
  final bool nsfw;

  BangumiDetailData({
    required this.id,
    required this.name,
    required this.nameCn,
    required this.summary,
    required this.date,
    required this.platform,
    required this.images,
    this.rating,
    this.collection,
    required this.tags,
    required this.infobox,
    required this.metaTags,
    required this.totalEpisodes,
    required this.eps,
    required this.volumes,
    required this.type,
    required this.series,
    required this.locked,
    required this.nsfw,
  });

  // 从API数据解析
  factory BangumiDetailData.fromJson(Map<String, dynamic> json) {
    return BangumiDetailData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      nameCn: json['name_cn'] ?? '',
      summary: json['summary'] ?? '',
      date: json['date'] ?? '',
      platform: json['platform'] ?? '',
      images: BangumiImages.fromJson(json['images'] ?? {}),
      rating: json['rating'] != null ? BangumiRating.fromJson(json['rating']) : null,
      collection: json['collection'] != null ? BangumiCollection.fromJson(json['collection']) : null,
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((tag) => BangumiTag.fromJson(tag))
          .toList(),
      infobox: (json['infobox'] as List<dynamic>? ?? [])
          .map((info) => BangumiInfobox.fromJson(info))
          .toList(),
      metaTags: (json['meta_tags'] as List<dynamic>? ?? [])
          .map((tag) => tag.toString())
          .toList(),
      totalEpisodes: json['total_episodes'] ?? 0,
      eps: json['eps'] ?? 0,
      volumes: json['volumes'] ?? 0,
      type: json['type'] ?? 0,
      series: json['series'] ?? false,
      locked: json['locked'] ?? false,
      nsfw: json['nsfw'] ?? false,
    );
  }

  // 获取显示用的名称
  String get displayName => nameCn.isNotEmpty ? nameCn : name;

  // 获取评分文本
  String get scoreText => rating?.score != null ? rating!.score.toStringAsFixed(1) : '暂无评分';

  // 获取总评价人数
  int get totalRatingCount => rating?.total ?? 0;

  // 获取收藏总数
  int get totalCollectionCount => collection?.total ?? 0;

  // 获取类型文本
  String get typeText {
    switch (type) {
      case 1: return '书籍';
      case 2: return 'TV动画';
      case 3: return '音乐';
      case 4: return '游戏';
      case 6: return '真人';
      default: return '未知';
    }
  }

  // 获取主要标签
  List<String> get mainTags => metaTags.take(5).toList();
}

// 图片信息模型
class BangumiImages {
  final String small;
  final String grid;
  final String large;
  final String medium;
  final String common;

  BangumiImages({
    required this.small,
    required this.grid,
    required this.large,
    required this.medium,
    required this.common,
  });

  factory BangumiImages.fromJson(Map<String, dynamic> json) {
    return BangumiImages(
      small: json['small'] ?? '',
      grid: json['grid'] ?? '',
      large: json['large'] ?? '',
      medium: json['medium'] ?? '',
      common: json['common'] ?? '',
    );
  }

  // 获取最适合的图片URL
  String get bestUrl => large.isNotEmpty ? large : (medium.isNotEmpty ? medium : common);
}

// 评分信息模型
class BangumiRating {
  final int rank;
  final int total;
  final double score;
  final Map<String, int> count;

  BangumiRating({
    required this.rank,
    required this.total,
    required this.score,
    required this.count,
  });

  factory BangumiRating.fromJson(Map<String, dynamic> json) {
    final countData = json['count'] as Map<String, dynamic>? ?? {};
    final countMap = <String, int>{};
    countData.forEach((key, value) {
      countMap[key] = value is int ? value : 0;
    });

    return BangumiRating(
      rank: json['rank'] ?? 0,
      total: json['total'] ?? 0,
      score: (json['score'] ?? 0.0).toDouble(),
      count: countMap,
    );
  }
}

// 收藏信息模型
class BangumiCollection {
  final int onHold;
  final int dropped;
  final int wish;
  final int collect;
  final int doing;

  BangumiCollection({
    required this.onHold,
    required this.dropped,
    required this.wish,
    required this.collect,
    required this.doing,
  });

  factory BangumiCollection.fromJson(Map<String, dynamic> json) {
    return BangumiCollection(
      onHold: json['on_hold'] ?? 0,
      dropped: json['dropped'] ?? 0,
      wish: json['wish'] ?? 0,
      collect: json['collect'] ?? 0,
      doing: json['doing'] ?? 0,
    );
  }

  // 计算总收藏数
  int get total => onHold + dropped + wish + collect + doing;
}

// 标签信息模型
class BangumiTag {
  final String name;
  final int count;
  final int totalCont;

  BangumiTag({
    required this.name,
    required this.count,
    required this.totalCont,
  });

  factory BangumiTag.fromJson(Map<String, dynamic> json) {
    return BangumiTag(
      name: json['name'] ?? '',
      count: json['count'] ?? 0,
      totalCont: json['total_cont'] ?? 0,
    );
  }
}

// 信息框模型
class BangumiInfobox {
  final String key;
  final dynamic value;

  BangumiInfobox({
    required this.key,
    required this.value,
  });

  factory BangumiInfobox.fromJson(Map<String, dynamic> json) {
    return BangumiInfobox(
      key: json['key'] ?? '',
      value: json['value'],
    );
  }

  // 获取格式化的值
  String get displayValue {
    if (value is String) {
      return value;
    } else if (value is List) {
      return (value as List).map((v) => v is Map ? v['v'] ?? v.toString() : v.toString()).join(', ');
    } else {
      return value?.toString() ?? '';
    }
  }
}

// 数据解析工具类
class BangumiDataParser {
  // 解析动漫详情数据
  static BangumiDetailData? parseDetailData(Map<String, dynamic>? jsonData) {
    if (jsonData == null) return null;
    
    try {
      return BangumiDetailData.fromJson(jsonData);
    } catch (e) {
      return null;
    }
  }
}

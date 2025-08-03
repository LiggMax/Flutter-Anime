import 'dart:convert';

/// 相关条目数据模型
class RelatedData {
  final List<RelatedItem> data;

  RelatedData({required this.data});

  /// 从API响应数据解析相关条目数据
  factory RelatedData.fromJson(List<dynamic> json) {
    final items = json
        .map((item) => RelatedItem.fromJson(item))
        .where((item) => item.type == 2) // 过滤掉 type != 2 的数据
        .toList();
    return RelatedData(data: items);
  }

  /// 从JSON字符串解析
  factory RelatedData.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString);
    return RelatedData.fromJson(json);
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {'data': data.map((item) => item.toJson()).toList()};
  }
}

/// 相关条目模型
class RelatedItem {
  final RelatedImages images;
  final String name;
  final String nameCn;
  final String relation;
  final int type;
  final int id;

  RelatedItem({
    required this.images,
    required this.name,
    required this.nameCn,
    required this.relation,
    required this.type,
    required this.id,
  });

  /// 从JSON解析相关条目
  factory RelatedItem.fromJson(Map<String, dynamic> json) {
    return RelatedItem(
      images: RelatedImages.fromJson(json['images'] ?? {}),
      name: json['name'] ?? '',
      nameCn: json['name_cn'] ?? '',
      relation: json['relation'] ?? '',
      type: json['type'] ?? 0,
      id: json['id'] ?? 0,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'images': images.toJson(),
      'name': name,
      'name_cn': nameCn,
      'relation': relation,
      'type': type,
      'id': id,
    };
  }

  /// 获取显示名称（优先中文名）
  String get displayName => nameCn.isNotEmpty ? nameCn : name;

  /// 获取条目类型文本
  String get typeText {
    switch (type) {
      case 1:
        return '书籍';
      case 2:
        return '动画';
      case 3:
        return '音乐';
      case 4:
        return '游戏';
      case 6:
        return '三次元';
      default:
        return '未知';
    }
  }
}

/// 相关条目图片模型
class RelatedImages {
  final String small;
  final String grid;
  final String large;
  final String medium;
  final String common;

  RelatedImages({
    required this.small,
    required this.grid,
    required this.large,
    required this.medium,
    required this.common,
  });

  /// 从JSON解析图片信息
  factory RelatedImages.fromJson(Map<String, dynamic> json) {
    return RelatedImages(
      small: json['small'] ?? '',
      grid: json['grid'] ?? '',
      large: json['large'] ?? '',
      medium: json['medium'] ?? '',
      common: json['common'] ?? '',
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'small': small,
      'grid': grid,
      'large': large,
      'medium': medium,
      'common': common,
    };
  }

  /// 获取默认图片URL（优先使用medium，其次common）
  String get defaultImage {
    if (medium.isNotEmpty) return medium;
    if (common.isNotEmpty) return common;
    if (large.isNotEmpty) return large;
    if (small.isNotEmpty) return small;
    if (grid.isNotEmpty) return grid;
    return '';
  }

  /// 获取小图URL
  String get smallImage => small.isNotEmpty ? small : defaultImage;

  /// 获取大图URL
  String get largeImage => large.isNotEmpty ? large : defaultImage;
}

/// 相关条目数据解析工具类
class RelatedDataParser {
  /// 解析相关条目响应数据
  static RelatedData parseRelatedResponse(List<dynamic> response) {
    return RelatedData.fromJson(response);
  }

  /// 解析相关条目响应数据（从JSON字符串）
  static RelatedData parseRelatedResponseFromString(String jsonString) {
    return RelatedData.fromJsonString(jsonString);
  }

  /// 按关系类型分组相关条目
  static Map<String, List<RelatedItem>> groupByRelation(List<RelatedItem> items) {
    final grouped = <String, List<RelatedItem>>{};
    
    for (final item in items) {
      final relation = item.relation;
      if (!grouped.containsKey(relation)) {
        grouped[relation] = [];
      }
      grouped[relation]!.add(item);
    }
    
    return grouped;
  }

  /// 获取特定关系类型的条目
  static List<RelatedItem> getItemsByRelation(
    List<RelatedItem> items,
    String relation,
  ) {
    return items.where((item) => item.relation == relation).toList();
  }

  /// 获取前传条目
  static List<RelatedItem> getPrequels(List<RelatedItem> items) {
    return getItemsByRelation(items, '前传');
  }

  /// 获取续作条目
  static List<RelatedItem> getSequels(List<RelatedItem> items) {
    return getItemsByRelation(items, '续作');
  }

  /// 获取外传条目
  static List<RelatedItem> getSpinOffs(List<RelatedItem> items) {
    return getItemsByRelation(items, '外传');
  }

  /// 获取总集篇条目
  static List<RelatedItem> getCompilations(List<RelatedItem> items) {
    return getItemsByRelation(items, '总集篇');
  }

  /// 获取片头曲条目
  static List<RelatedItem> getOpeningSongs(List<RelatedItem> items) {
    return getItemsByRelation(items, '片头曲');
  }

  /// 获取片尾曲条目
  static List<RelatedItem> getEndingSongs(List<RelatedItem> items) {
    return getItemsByRelation(items, '片尾曲');
  }

  /// 获取原声集条目
  static List<RelatedItem> getSoundtracks(List<RelatedItem> items) {
    return getItemsByRelation(items, '原声集');
  }
}

/*
  @Author Ligg
  @Time 2025/8/8
 */
/*
  @Author Ligg
  @Time 2025/8/8
 */

class UserCollection {
  final List<CollectionItem> data;
  final int total;

  UserCollection({
    required this.data,
    required this.total,
  });

  factory UserCollection.fromJson(Map<String, dynamic> json) {
    var dataList = json['data'] as List;
    List<CollectionItem> items = dataList.map((i) => CollectionItem.fromJson(i)).toList();

    return UserCollection(
      data: items,
      total: json['total'],
    );
  }
}

class CollectionItem {
  final int id;
  final String name;
  final String nameCN;
  final int type;
  final String info;
  final Rating rating;
  final bool locked;
  final bool nsfw;
  final Images images;
  final Interest interest;

  CollectionItem({
    required this.id,
    required this.name,
    required this.nameCN,
    required this.type,
    required this.info,
    required this.rating,
    required this.locked,
    required this.nsfw,
    required this.images,
    required this.interest,
  });

  factory CollectionItem.fromJson(Map<String, dynamic> json) {
    return CollectionItem(
      id: json['id'],
      name: json['name'],
      nameCN: json['nameCN'],
      type: json['type'],
      info: json['info'],
      rating: Rating.fromJson(json['rating']),
      locked: json['locked'],
      nsfw: json['nsfw'],
      images: Images.fromJson(json['images']),
      interest: Interest.fromJson(json['interest']),
    );
  }
}

class Rating {
  final int rank;
  final List<int> count;
  final double score;
  final int total;

  Rating({
    required this.rank,
    required this.count,
    required this.score,
    required this.total,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    var countList = json['count'] as List;
    List<int> counts = countList.cast<int>();

    return Rating(
      rank: json['rank'],
      count: counts,
      score: json['score'].toDouble(),
      total: json['total'],
    );
  }
}

class Images {
  final String large;
  final String common;
  final String medium;
  final String small;
  final String grid;

  Images({
    required this.large,
    required this.common,
    required this.medium,
    required this.small,
    required this.grid,
  });

  factory Images.fromJson(Map<String, dynamic> json) {
    return Images(
      large: json['large'],
      common: json['common'],
      medium: json['medium'],
      small: json['small'],
      grid: json['grid'],
    );
  }
}

class Interest {
  final int id;
  final int rate;
  final int type;
  final String comment;
  final List<dynamic> tags;
  final int updatedAt;

  Interest({
    required this.id,
    required this.rate,
    required this.type,
    required this.comment,
    required this.tags,
    required this.updatedAt,
  });

  factory Interest.fromJson(Map<String, dynamic> json) {
    return Interest(
      id: json['id'],
      rate: json['rate'],
      type: json['type'],
      comment: json['comment'],
      tags: json['tags'],
      updatedAt: json['updatedAt'],
    );
  }
}

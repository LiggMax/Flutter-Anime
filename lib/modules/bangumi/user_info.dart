class UserInfo {
  final int id;
  final String username;
  final String nickname;
  final Avatar avatar;
  final int group;
  final int joinedAt;
  final String sign;
  final String site;
  final String location;
  final String bio;
  final List<dynamic> networkServices;
  final Homepage homepage;
  final Stats stats;

  UserInfo({
    required this.id,
    required this.username,
    required this.nickname,
    required this.avatar,
    required this.group,
    required this.joinedAt,
    required this.sign,
    required this.site,
    required this.location,
    required this.bio,
    required this.networkServices,
    required this.homepage,
    required this.stats,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'],
      username: json['username'],
      nickname: json['nickname'],
      avatar: Avatar.fromJson(json['avatar']),
      group: json['group'],
      joinedAt: json['joinedAt'],
      sign: json['sign'],
      site: json['site'],
      location: json['location'],
      bio: json['bio'],
      networkServices: json['networkServices'],
      homepage: Homepage.fromJson(json['homepage']),
      stats: Stats.fromJson(json['stats']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nickname': nickname,
      'avatar': avatar.toJson(),
      'group': group,
      'joinedAt': joinedAt,
      'sign': sign,
      'site': site,
      'location': location,
      'bio': bio,
      'networkServices': networkServices,
      'homepage': homepage.toJson(),
      'stats': stats.toJson(),
    };
  }

  // 便于 UI 使用的收藏统计条目（动漫类：subject['2']）
  // 返回顺序：想看、再看、看过、搁置、抛弃
  List<Map<String, dynamic>> get collectionItems {
    final Map<String, int> s = stats.subject['2'] ?? {};
    return [
      {'label': '想看', 'id': 1, 'count': s['1'] ?? 0},
      {'label': '再看', 'id': 3, 'count': s['3'] ?? 0},
      {'label': '看过', 'id': 2, 'count': s['2'] ?? 0},
      {'label': '搁置', 'id': 4, 'count': s['4'] ?? 0},
      {'label': '抛弃', 'id': 5, 'count': s['5'] ?? 0},
    ];
  }
}

class Avatar {
  final String small;
  final String medium;
  final String large;

  Avatar({required this.small, required this.medium, required this.large});

  factory Avatar.fromJson(Map<String, dynamic> json) {
    return Avatar(
      small: json['small'],
      medium: json['medium'],
      large: json['large'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'small': small, 'medium': medium, 'large': large};
  }
}

class Homepage {
  final List<String> left;
  final List<String> right;

  Homepage({required this.left, required this.right});

  factory Homepage.fromJson(Map<String, dynamic> json) {
    return Homepage(
      left: List<String>.from(json['left']),
      right: List<String>.from(json['right']),
    );
  }

  Map<String, dynamic> toJson() {
    return {'left': left, 'right': right};
  }
}

class Stats {
  final Map<String, Map<String, int>> subject;
  final Map<String, int> mono;
  final int blog;
  final int friend;
  final int group;
  final IndexStats index;

  Stats({
    required this.subject,
    required this.mono,
    required this.blog,
    required this.friend,
    required this.group,
    required this.index,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    Map<String, Map<String, int>> subjectMap = {};
    json['subject'].forEach((key, value) {
      Map<String, int> innerMap = {};
      (value as Map).forEach((k, v) {
        innerMap[k.toString()] = v as int;
      });
      subjectMap[key.toString()] = innerMap;
    });

    Map<String, int> monoMap = {};
    json['mono'].forEach((key, value) {
      monoMap[key.toString()] = value as int;
    });

    return Stats(
      subject: subjectMap,
      mono: monoMap,
      blog: json['blog'],
      friend: json['friend'],
      group: json['group'],
      index: IndexStats.fromJson(json['index']),
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> subjectJson = {};
    subject.forEach((key, value) {
      subjectJson[key] = value;
    });

    return {
      'subject': subjectJson,
      'mono': mono,
      'blog': blog,
      'friend': friend,
      'group': group,
      'index': index.toJson(),
    };
  }
}

class IndexStats {
  final int create;
  final int collect;

  IndexStats({required this.create, required this.collect});

  factory IndexStats.fromJson(Map<String, dynamic> json) {
    return IndexStats(create: json['create'], collect: json['collect']);
  }

  Map<String, dynamic> toJson() {
    return {'create': create, 'collect': collect};
  }
}

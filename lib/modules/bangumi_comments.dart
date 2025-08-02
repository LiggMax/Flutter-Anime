/*
  @Author Ligg
  @Time 2025/1/27
 */

import 'dart:convert';

/// 评论数据解析模块
class BangumiCommentsData {
  final int total;
  final List<BangumiComment> data;

  BangumiCommentsData({
    required this.total,
    required this.data,
  });

  /// 从API响应数据解析评论数据
  factory BangumiCommentsData.fromJson(Map<String, dynamic> json) {
    return BangumiCommentsData(
      total: json['total'] ?? 0,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => BangumiComment.fromJson(item))
              .toList() ??
          [],
    );
  }

  /// 从JSON字符串解析
  factory BangumiCommentsData.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString);
    return BangumiCommentsData.fromJson(json);
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

/// 评论模型
class BangumiComment {
  final int id;
  final BangumiUser user;
  final int type;
  final int rate;
  final String comment;
  final int updatedAt;

  BangumiComment({
    required this.id,
    required this.user,
    required this.type,
    required this.rate,
    required this.comment,
    required this.updatedAt,
  });

  /// 从JSON解析评论
  factory BangumiComment.fromJson(Map<String, dynamic> json) {
    return BangumiComment(
      id: json['id'] ?? 0,
      user: BangumiUser.fromJson(json['user'] ?? {}),
      type: json['type'] ?? 0,
      rate: json['rate'] ?? 0,
      comment: json['comment'] ?? '',
      updatedAt: json['updatedAt'] ?? 0,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'type': type,
      'rate': rate,
      'comment': comment,
      'updatedAt': updatedAt,
    };
  }

  /// 获取评论类型文本
  String get typeText {
    switch (type) {
      case 1: return '想看';
      case 2: return '看过';
      case 3: return '在看';
      case 4: return '搁置';
      case 5: return '抛弃';
      default: return '未知';
    }
  }

  /// 获取评分文本
  String get rateText => rate > 0 ? '$rate分' : '未评分';

  /// 获取更新时间文本
  String get updateTimeText {
    final now = DateTime.now();
    final updateTime = DateTime.fromMillisecondsSinceEpoch(updatedAt * 1000);
    final difference = now.difference(updateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}

/// 用户模型
class BangumiUser {
  final int id;
  final String username;
  final String nickname;
  final BangumiUserAvatar avatar;
  final int group;
  final String sign;
  final int joinedAt;

  BangumiUser({
    required this.id,
    required this.username,
    required this.nickname,
    required this.avatar,
    required this.group,
    required this.sign,
    required this.joinedAt,
  });

  /// 从JSON解析用户信息
  factory BangumiUser.fromJson(Map<String, dynamic> json) {
    return BangumiUser(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      nickname: json['nickname'] ?? '',
      avatar: BangumiUserAvatar.fromJson(json['avatar'] ?? {}),
      group: json['group'] ?? 0,
      sign: json['sign'] ?? '',
      joinedAt: json['joinedAt'] ?? 0,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nickname': nickname,
      'avatar': avatar.toJson(),
      'group': group,
      'sign': sign,
      'joinedAt': joinedAt,
    };
  }

  /// 获取显示名称（优先昵称）
  String get displayName => nickname.isNotEmpty ? nickname : username;

  /// 获取用户组文本
  String get groupText {
    switch (group) {
      case 1: return '管理员';
      case 2: return '版主';
      case 3: return '用户';
      case 10: return '用户';
      default: return '未知';
    }
  }

  /// 获取加入时间文本
  String get joinTimeText {
    final joinTime = DateTime.fromMillisecondsSinceEpoch(joinedAt * 1000);
    return '${joinTime.year}-${joinTime.month.toString().padLeft(2, '0')}-${joinTime.day.toString().padLeft(2, '0')}';
  }
}

/// 用户头像模型
class BangumiUserAvatar {
  final String small;
  final String medium;
  final String large;

  BangumiUserAvatar({
    required this.small,
    required this.medium,
    required this.large,
  });

  /// 从JSON解析头像信息
  factory BangumiUserAvatar.fromJson(Map<String, dynamic> json) {
    return BangumiUserAvatar(
      small: json['small'] ?? '',
      medium: json['medium'] ?? '',
      large: json['large'] ?? '',
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'small': small,
      'medium': medium,
      'large': large,
    };
  }

  /// 获取默认头像URL
  String get defaultAvatar => small.isNotEmpty ? small : 'https://lain.bgm.tv/pic/user/s/icon.jpg';
}

/// 评论数据解析工具类
class BangumiCommentsParser {
  /// 解析评论响应数据
  static BangumiCommentsData parseCommentsResponse(Map<String, dynamic> response) {
    return BangumiCommentsData.fromJson(response);
  }

  /// 解析评论响应数据（从JSON字符串）
  static BangumiCommentsData parseCommentsResponseFromString(String jsonString) {
    return BangumiCommentsData.fromJsonString(jsonString);
  }

  /// 按评分排序评论
  static List<BangumiComment> sortByRate(List<BangumiComment> comments) {
    final sorted = List<BangumiComment>.from(comments);
    sorted.sort((a, b) => b.rate.compareTo(a.rate));
    return sorted;
  }

  /// 按时间排序评论
  static List<BangumiComment> sortByTime(List<BangumiComment> comments) {
    final sorted = List<BangumiComment>.from(comments);
    sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  }

  /// 获取高评分评论（8分以上）
  static List<BangumiComment> getHighRateComments(List<BangumiComment> comments) {
    return comments.where((comment) => comment.rate >= 8).toList();
  }

  /// 获取低评分评论（3分以下）
  static List<BangumiComment> getLowRateComments(List<BangumiComment> comments) {
    return comments.where((comment) => comment.rate <= 3 && comment.rate > 0).toList();
  }

  /// 获取平均评分
  static double getAverageRate(List<BangumiComment> comments) {
    final ratedComments = comments.where((comment) => comment.rate > 0).toList();
    if (ratedComments.isEmpty) return 0.0;
    
    final totalRate = ratedComments.fold<int>(0, (sum, comment) => sum + comment.rate);
    return totalRate / ratedComments.length;
  }

  /// 获取评论统计信息
  static Map<String, int> getCommentStats(List<BangumiComment> comments) {
    final stats = <String, int>{};
    
    for (final comment in comments) {
      final type = comment.typeText;
      stats[type] = (stats[type] ?? 0) + 1;
    }
    
    return stats;
  }
}

/*
  @Author Ligg
  @Time 2025/8/7
 */

class BangumiToken {
  final int code;
  final String message;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final int createdAt;

  BangumiToken({
    required this.code,
    required this.message,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.createdAt,
  });

  /// 从JSON解析Token
  factory BangumiToken.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return BangumiToken(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      accessToken: data['access_token'] as String? ?? '',
      refreshToken: data['refresh_token'] as String? ?? '',
      expiresIn: data['expires_in'] as int? ?? 0,
      createdAt: data['created_at'] as int? ?? 0,
    );
  }
}

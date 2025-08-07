/*
  @Author Ligg
  @Time 2025/8/5
 */
import 'dart:async';
import 'package:AnimeFlow/modules/bangumi/token.dart';
import '../api/bangumi/oauth.dart';
import '../request.dart';
import 'package:hive_flutter/hive_flutter.dart';

class OAuthCallbackHandler {
  static StreamSubscription? _subscription;
  static StreamController<String>? _codeController;
  static const String _tokenBoxName = 'bangumi_token';

  /// 处理OAuth回调URL
  static Future<String?> handleCallback(String url) async {
    try {
      print('处理OAuth回调URL: $url');

      final uri = Uri.parse(url);
      final code = uri.queryParameters['code'];
      if (code != null) {
        print('成功获取到授权码: $code');
        return code;
      } else {
        print('URL中没有找到code参数');
      }
    } catch (e) {
      print('处理OAuth回调时出错: $e');
    }
    return null;
  }

  /// 获取Token
  static Future<BangumiToken?> getToken(String code) async {
    try {
      final response = await httpRequest.get(
        BangumiOAuthApi.tokenUrl,
        queryParameters: {'code': code},
      );
      BangumiToken bangumiToken = BangumiToken.fromJson(response.data);
      if (bangumiToken.code == 200) {
        return bangumiToken;
      }
      return null;
    } catch (e) {
      print('获取Token请求失败: $e');
      return null;
    }
  }

  /// 持久化Token到Hive
  static Future<void> persistToken(BangumiToken token) async {
    try {
      final box = await Hive.openBox(_tokenBoxName);
      await box.put('token', {
        'code': token.code,
        'message': token.message,
        'accessToken': token.accessToken,
        'refreshToken': token.refreshToken,
        'expiresIn': token.expiresIn,
        'createdAt': token.createdAt,
      });
      print('Token已持久化到Hive: ${token.accessToken}');
    } catch (e) {
      print('持久化Token失败: $e');
    }
  }

  /// 从Hive获取Token
  static Future<BangumiToken?> getPersistedToken() async {
    try {
      final box = await Hive.openBox(_tokenBoxName);
      final tokenData = box.get('token') as Map<String, dynamic>?;
      if (tokenData != null) {
        return BangumiToken(
          code: tokenData['code'] as int,
          message: tokenData['message'] as String,
          accessToken: tokenData['accessToken'] as String,
          refreshToken: tokenData['refreshToken'] as String,
          expiresIn: tokenData['expiresIn'] as int,
          createdAt: tokenData['createdAt'] as int,
        );
      }
    } catch (e) {
      print('获取持久化Token失败: $e');
    }
    return null;
  }

  /// 清除持久化的Token
  static Future<void> clearPersistedToken() async {
    try {
      final box = await Hive.openBox(_tokenBoxName);
      await box.delete('token');
      print('已清除持久化的Token');
    } catch (e) {
      print('清除Token失败: $e');
    }
  }

  /// 释放资源
  static void dispose() {
    _subscription?.cancel();
    _codeController?.close();
    _codeController = null;
  }
}

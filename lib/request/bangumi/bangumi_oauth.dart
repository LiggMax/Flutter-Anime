/*
  @Author Ligg
  @Time 2025/8/5
 */
import 'dart:async';
import 'package:AnimeFlow/modules/bangumi/token.dart';
import '../api/bangumi/bgm_oauth.dart';
import '../request.dart';

class OAuthCallbackHandler {
  static StreamSubscription? _subscription;
  static StreamController<String>? _codeController;
  static Stream<String>? _codeStream;

  /// 获取授权码的Stream
  static Stream<String> get codeStream {
    _codeStream ??= _codeController?.stream ?? Stream.empty();
    return _codeStream!;
  }

  /// 处理OAuth回调URL
  static Future<void> handleCallback(String url) async {
    try {
      print('处理OAuth回调URL: $url');

      final uri = Uri.parse(url);
      final code = uri.queryParameters['code'];
      if (code != null) {
        print('成功获取到授权码: $code');

        // 通过Stream发送code
        _codeController?.add(code);
      } else {
        return;
      }
    } catch (e) {
      print('处理OAuth回调时出错: $e');
    }
  }

  ///获取Token
  static Future<BangumiToken?> getToken(String code) async {
    final response = await httpRequest.post(
      BangumiOAuthApi.tokenUrl,
      data: {code: code},
    );
    return BangumiToken.fromJson(response.data);
  }

  /// 释放资源
  static void dispose() {
    _subscription?.cancel();
    _codeController?.close();
    _codeController = null;
    _codeStream = null;
  }
}

/*
  @Author Ligg
  @Time 2025/8/5
 */
import 'dart:async';

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
      if (uri.path == '/callback') {
        final code = uri.queryParameters['code'];
        if (code != null) {
          print('成功获取到授权码: $code');
          _processAuthorizationCode(code);

          // 通过Stream发送code
          _codeController?.add(code);
        } else {
          print('URL中没有找到code参数');
        }
      } else {
        print('URL格式不匹配，期望: /callback');
      }
    } catch (e) {
      print('处理OAuth回调时出错: $e');
    }
  }

  /// 处理授权码
  static void _processAuthorizationCode(String code) {
    print('处理授权码: $code');
    // 在这里可以添加获取访问令牌的逻辑
    // 例如调用Bangumi API获取access_token
  }

  /// 释放资源
  static void dispose() {
    _subscription?.cancel();
    _codeController?.close();
    _codeController = null;
    _codeStream = null;
  }
}

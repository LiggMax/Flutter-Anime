/*
  @Author Ligg
  @Time 2025/8/5
 */
import 'package:app_links/app_links.dart';
import 'dart:async';

class OAuthCallbackHandler {
  static StreamSubscription? _subscription;
  static StreamController<String>? _codeController;
  static Stream<String>? _codeStream;
  static final AppLinks _appLinks = AppLinks();

  /// 获取授权码的Stream
  static Stream<String> get codeStream {
    _codeStream ??= _codeController?.stream ?? Stream.empty();
    return _codeStream!;
  }

  /// 初始化OAuth回调处理
  static Future<void> initialize() async {
    _codeController = StreamController<String>.broadcast();
    _codeStream = _codeController!.stream;

    // 监听深度链接
    _subscription = _appLinks.uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _handleDeepLink(uri.toString());
        }
      },
      onError: (err) {
        print('深度链接监听错误: $err');
      },
    );

    // 处理应用启动时的深度链接
    try {
      final initialUri = await _appLinks.getInitialAppLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri.toString());
      }
    } catch (e) {
      print('获取初始URI时出错: $e');
    }
  }

  /// 处理深度链接
  static void _handleDeepLink(String url) {
    print('收到深度链接: $url');
    handleCallback(url);
  }

  /// 处理OAuth回调URL
  static Future<void> handleCallback(String url) async {
    try {
      print('处理OAuth回调URL: $url');

      final uri = Uri.parse(url);
      if (uri.scheme == 'animeflow' &&
          uri.host == 'auth' &&
          uri.path == '/callback') {
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
        print('URL格式不匹配，期望: animeflow://auth/callback');
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

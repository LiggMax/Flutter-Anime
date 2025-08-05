import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../../../request/bangumi/bangumi_oauth.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Bangumi授权登录URL，这里使用占位符，您可以替换为实际的URL
  final String _authUrl =
      'https://bgm.tv/oauth/authorize?response_type=code&client_id=bgm42366890dd59f2baf&redirect_uri=animeflow://auth/callback';

  StreamSubscription<String>? _codeSubscription;
  String? _lastReceivedCode;

  @override
  void initState() {
    super.initState();
    _initializeOAuth();
  }

  @override
  void dispose() {
    _codeSubscription?.cancel();
    super.dispose();
  }

  /// 初始化OAuth处理
  Future<void> _initializeOAuth() async {
    await OAuthCallbackHandler.initialize();

    // 监听授权码
    _codeSubscription = OAuthCallbackHandler.codeStream.listen((code) {
      setState(() {
        _lastReceivedCode = code;
      });

      // 显示获取到的授权码
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('成功获取授权码: $code'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    });
  }

  // 打开授权登录网页
  Future<void> _launchAuthUrl() async {
    final Uri url = Uri.parse(_authUrl);
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('无法打开授权页面')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人中心')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Bangumi 授权登录',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                '点击下方按钮进行 Bangumi 账号授权登录',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _launchAuthUrl,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('授权登录'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // 测试OAuth回调功能
                  OAuthCallbackHandler.handleCallback(
                    'animeflow://auth/callback?code=test123456',
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                  backgroundColor: Colors.orange,
                ),
                child: const Text('测试OAuth回调'),
              ),
              const SizedBox(height: 40),
              if (_lastReceivedCode != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '最新获取的授权码:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _lastReceivedCode!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

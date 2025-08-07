import 'package:AnimeFlow/request/api/bangumi/oauth.dart';
import 'package:AnimeFlow/request/bangumi/bangumi_oauth.dart';
import 'package:AnimeFlow/modules/bangumi/token.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Bangumi授权登录URL
  final String _authUrl = BangumiOAuthApi.oauthUrl;
  BangumiToken? _persistedToken;

  @override
  void initState() {
    super.initState();
    _loadPersistedToken();
  }

  /// 加载持久化的Token
  Future<void> _loadPersistedToken() async {
    final token = await OAuthCallbackHandler.getPersistedToken();
    if (mounted) {
      setState(() {
        _persistedToken = token;
      });
    }
  }

  /// 清除Token
  // Future<void> _clearToken() async {
  //   await OAuthCallbackHandler.clearPersistedToken();
  //   if (mounted) {
  //     setState(() {
  //       _persistedToken = null;
  //     });
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text('已清除Token')));
  //   }
  // }

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_persistedToken == null) ...[
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
              ],
              const SizedBox(height: 40),
              if (_persistedToken != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '已保存的Token:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Access Token: ${_persistedToken!.accessToken}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Refresh Token: ${_persistedToken!.refreshToken}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Expires In: ${_persistedToken!.expiresIn}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Token Type: ${_persistedToken!.tokenType}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'User Id: ${_persistedToken!.userId}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // ElevatedButton(
                      //   onPressed: _clearToken,
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: Colors.red,
                      //     foregroundColor: Colors.white,
                      //   ),
                      //   child: const Text('清除Token'),
                      // ),
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

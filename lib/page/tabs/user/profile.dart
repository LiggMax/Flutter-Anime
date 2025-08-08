import 'package:AnimeFlow/request/api/bangumi/oauth.dart';
import 'package:AnimeFlow/request/bangumi/bangumi_oauth.dart';
import 'package:AnimeFlow/request/bangumi/bangumi_user.dart';
import 'package:AnimeFlow/modules/bangumi/token.dart';
import 'package:AnimeFlow/modules/bangumi/user_info.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:AnimeFlow/page/tabs/user/header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Bangumi授权登录URL
  final String _authUrl = BangumiOAuthApi.oauthUrl;
  BangumiToken? _persistedToken;
  UserInfo? _userInfo;

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

      // 如果有Token，获取用户信息
      if (_persistedToken != null) {
        _loadUserInfo();
      }
    }
  }

  /// 获取用户信息
  Future<void> _loadUserInfo() async {
    if (_persistedToken == null) return;

    try {
      // 使用Token中的userId或username获取用户信息
      final userInfo = await BangumiUser.getUserinfo(
        _persistedToken!.userId.toString(),
        token: _persistedToken!.accessToken,
      );

      if (mounted) {
        setState(() {
          _userInfo = userInfo;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('获取用户信息失败: $e')));
      }
    }
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_persistedToken == null) ...[
              const SizedBox(height: 80),
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
              const SizedBox(height: 24),
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
              const SizedBox(height: 80),
            ],

            if (_persistedToken != null && _userInfo != null) ...[
              UserHeader(userInfo: _userInfo!),
              _buildDevPlaceholder(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDevPlaceholder() {
    return Container(
      alignment: Alignment.center,
      height: 400,
      width: double.infinity,
      child: Text(
        '开发中…',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 16,
        ),
      ),
    );
  }
}

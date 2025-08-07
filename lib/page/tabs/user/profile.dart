import 'package:AnimeFlow/request/api/bangumi/oauth.dart';
import 'package:AnimeFlow/request/bangumi/bangumi_oauth.dart';
import 'package:AnimeFlow/request/bangumi/bangumi_user.dart';
import 'package:AnimeFlow/modules/bangumi/token.dart';
import 'package:AnimeFlow/modules/bangumi/user_info.dart';
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
  UserInfo? _userInfo;
  bool _isLoadingUserInfo = false;

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
    
    setState(() {
      _isLoadingUserInfo = true;
    });

    try {
      // 使用Token中的userId或username获取用户信息
      final userInfo = await BangumiUser.getUserinfo(
        _persistedToken!.userId.toString(),
        token: _persistedToken!.accessToken,
      );
      
      if (mounted) {
        setState(() {
          _userInfo = userInfo;
          _isLoadingUserInfo = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUserInfo = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取用户信息失败: $e')),
        );
      }
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
                // 用户信息显示
                if (_isLoadingUserInfo)
                  const CircularProgressIndicator()
                else if (_userInfo != null)
                  _buildUserInfoCard()
                else
                  _buildTokenInfoCard(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 构建用户信息卡片
  Widget _buildUserInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
      ),
      child: Column(
        children: [
          // 头像
          if (_userInfo!.avatar.large.isNotEmpty)
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(_userInfo!.avatar.large),
            ),
          const SizedBox(height: 16),
          
          // 用户基本信息
          Text(
            _userInfo!.nickname,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '@${_userInfo!.username}',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          
          // 签名
          if (_userInfo!.sign.isNotEmpty) ...[
            Text(
              _userInfo!.sign,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
          
          // 统计信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('在看', _userInfo!.stats.subject['watching']?['1'] ?? 0),
              _buildStatItem('看过', _userInfo!.stats.subject['collect']?['2'] ?? 0),
              _buildStatItem('想看', _userInfo!.stats.subject['wish']?['1'] ?? 0),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// 构建Token信息卡片
  Widget _buildTokenInfoCard() {
    return Container(
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
    );
  }
}

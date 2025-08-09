import 'package:AnimeFlow/request/bangumi/bangumi_oauth.dart';
import 'package:AnimeFlow/request/bangumi/bangumi_user.dart';
import 'package:AnimeFlow/modules/bangumi/token.dart';
import 'package:AnimeFlow/modules/bangumi/user_info.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:AnimeFlow/pages/tabs/user/header.dart';
import 'package:AnimeFlow/pages/tabs/user/no_login.dart';

import 'collection.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
      // 使用Token中的userId获取用户信息
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

  /// 接收子组件授权完成后的 Token
  Future<void> _onAuthorized(BangumiToken token) async {
    if (!mounted) return;
    setState(() {
      _persistedToken = token;
    });
    await _loadUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_persistedToken == null) ...[
              NoLogin(onAuthorized: _onAuthorized),
            ],

            if (_persistedToken != null && _userInfo != null) ...[
              //头部信息组件
              UserHeader(userInfo: _userInfo!),
              //收藏信息组件
              Collection(userInfo: _userInfo!, token: _persistedToken!),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:AnimeFlow/request/api/bangumi/oauth.dart';
import 'package:AnimeFlow/request/bangumi/bangumi_oauth.dart';
import 'package:AnimeFlow/request/bangumi/bangumi_user.dart';
import 'package:AnimeFlow/modules/bangumi/token.dart';
import 'package:AnimeFlow/modules/bangumi/user_info.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  // Bangumi授权登录URL
  final String _authUrl = BangumiOAuthApi.oauthUrl;
  BangumiToken? _persistedToken;
  UserInfo? _userInfo;
  bool _isLoadingUserInfo = false;

  late final AnimationController _statsController;
  late final Animation<double> _statsAnimation;
  late final AnimationController _orbitController;
  late final Animation<double> _orbitAnimation;

  @override
  void initState() {
    super.initState();
    _statsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _statsAnimation = CurvedAnimation(
      parent: _statsController,
      curve: Curves.easeOutBack,
    );
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100),
    );
    _orbitAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _orbitController, curve: Curves.linear));
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
          _isLoadingUserInfo = false;
        });
        // 用户信息就绪后播放统计动画与环绕轻微动态
        _statsController.forward(from: 0);
        _orbitController
          ..reset()
          ..repeat();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUserInfo = false;
        });
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

            if (_persistedToken != null) ...[
              _buildProfileHeader(),
              _buildDevPlaceholder(),
            ],
          ],
        ),
      ),
    );
  }

  /// 顶部信息头
  Widget _buildProfileHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double centerX = constraints.maxWidth / 2;
          final double centerY = 150;

          return Stack(
            children: [
              // 背景图
              Positioned.fill(
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Image.network(
                    _userInfo!.avatar.large,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // 中心头像
              Positioned(
                left: centerX - 44,
                top: centerY - 44,
                child: CircleAvatar(
                  radius: 44,
                  backgroundImage: NetworkImage(_userInfo!.avatar.large),
                ),
              ),

              // 昵称与用户名
              Positioned(
                left: 0,
                right: 0,
                top: centerY + 120,
                child: Column(
                  children: [
                    Text(
                      '${_userInfo!.nickname}@${_userInfo!.username}',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // 环绕统计
              ..._buildOrbitTextStats(
                center: Offset(centerX, centerY),
                radius: 80,
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildOrbitTextStats({
    required Offset center,
    required double radius,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final Map<String, int> s = _userInfo!.stats.subject['2'] ?? {};
    final List<Map<String, dynamic>> items = [
      {'label': '想看', 'count': s['1'] ?? 0},
      {'label': '再看', 'count': s['3'] ?? 0},
      {'label': '看过', 'count': s['2'] ?? 0},
      {'label': '抛弃', 'count': s['5'] ?? 0},
      {'label': '搁置', 'count': s['4'] ?? 0},
    ];

    final List<Widget> widgets = [];
    for (int i = 0; i < items.length; i++) {
      final double baseAngle = -math.pi / 2 + i * (2 * math.pi / 5);
      widgets.add(
        AnimatedBuilder(
          animation: _orbitAnimation,
          builder: (context, child) {
            return AnimatedBuilder(
              animation: _statsAnimation,
              builder: (context, child) {
                final double r = (radius * _statsAnimation.value).clamp(
                  0.0,
                  double.infinity,
                );
                final double angle = baseAngle + _orbitAnimation.value;
                final double x = center.dx + r * math.cos(angle);
                final double y = center.dy + r * math.sin(angle);
                return Positioned(
                  left: x,
                  top: y,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, -0.5),
                    child: _InlineStat(
                      label: items[i]['label'] as String,
                      count: items[i]['count'] as int,
                      color: colorScheme.onSurface,
                      subColor: colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            );
          },
        ),
      );
    }
    return widgets;
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

  @override
  void dispose() {
    _statsController.dispose();
    _orbitController.dispose();
    super.dispose();
  }
}

class _InlineStat extends StatelessWidget {
  const _InlineStat({
    required this.label,
    required this.count,
    required this.color,
    required this.subColor,
  });

  final String label;
  final int count;
  final Color color;
  final Color subColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: subColor, fontSize: 12)),
      ],
    );
  }
}

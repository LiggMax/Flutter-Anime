import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:AnimeFlow/modules/bangumi/user_info.dart';

class UserHeader extends StatefulWidget {
  const UserHeader({super.key, required this.userInfo});

  final UserInfo userInfo;

  @override
  State<UserHeader> createState() => _UserHeaderState();
}

class _UserHeaderState extends State<UserHeader> with TickerProviderStateMixin {
  late final AnimationController _orbitController;
  late final Animation<double> _orbitAnimation;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 100),
    );
    _orbitAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _orbitController, curve: Curves.linear));
    _orbitController.repeat();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const double headerHeight = 300;
    const double centerY = 150;
    const double avatarRadius = 44;
    const double orbitRadius = 80;

    return SizedBox(
      height: headerHeight,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double centerX = constraints.maxWidth / 2;

          return Stack(
            children: [
              // 背景：用户头像高斯模糊
              Positioned.fill(
                child: ImageFiltered(
                  imageFilter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Image.network(
                    widget.userInfo.avatar.large,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              // 中心头像
              Positioned(
                left: centerX - avatarRadius,
                top: centerY - avatarRadius,
                child: CircleAvatar(
                  radius: avatarRadius,
                  backgroundImage: NetworkImage(widget.userInfo.avatar.large),
                ),
              ),

              // 名称
              Positioned(
                left: 0,
                right: 0,
                top: centerY + avatarRadius + 32,
                child: Text(
                  '${widget.userInfo.nickname}@${widget.userInfo.username}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // 环绕统计
              ..._buildOrbitTextStats(
                colorScheme: colorScheme,
                center: Offset(centerX, centerY),
                radius: orbitRadius,
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildOrbitTextStats({
    required ColorScheme colorScheme,
    required Offset center,
    required double radius,
  }) {
    final Map<String, int> s = widget.userInfo.stats.subject['2'] ?? {};
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
            final double angle = baseAngle + _orbitAnimation.value;
            final double x = center.dx + radius * math.cos(angle);
            final double y = center.dy + radius * math.sin(angle);
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
        ),
      );
    }
    return widgets;
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

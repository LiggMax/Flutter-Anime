import 'package:flutter/material.dart';

extension ThemeExtensions on BuildContext {
  // 获取当前主题
  ThemeData get theme => Theme.of(this);

  // 获取颜色方案
  ColorScheme get colorScheme => theme.colorScheme;

  // 是否为深色模式
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // 导航栏相关颜色
  Color get navigationBarColor =>
      isDarkMode ? colorScheme.surfaceContainerHighest : Colors.cyanAccent;

  Color get navigationIconColor => colorScheme.onSurfaceVariant;

  Color get navigationSelectedColor => colorScheme.primary;

  // AppBar相关颜色
  Color get appBarForegroundColor => colorScheme.onSurface;

  // 常用文本颜色
  Color get primaryTextColor => colorScheme.onSurface;

  Color get secondaryTextColor => colorScheme.onSurfaceVariant;
}

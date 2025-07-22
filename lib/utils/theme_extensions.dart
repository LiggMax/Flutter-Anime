import 'package:flutter/material.dart';

extension ThemeExtensions on BuildContext {
  // 获取当前主题
  ThemeData get theme => Theme.of(this);

  // 获取颜色方案
  ColorScheme get colorScheme => theme.colorScheme;

  // 是否为深色模式
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // 导航栏相关颜色
  Color get navigationBarColor => isDarkMode
    ? const Color(0xFF2D2D2D)  // 深色模式使用深灰色
    : const Color(0xFFE0E0E0); // 浅色模式使用更深的青色

  Color get navigationIconColor => isDarkMode
    ? Colors.white70  // 深色模式图标使用白色
    : Colors.white;   // 浅色模式图标使用白色

  Color get navigationSelectedColor => isDarkMode
    ? const Color(0xFF64B5F6)  // 深色模式选中按钮使用亮蓝色
    : const Color(0xFF1976D2); // 浅色模式选中按钮使用深蓝色

  // 选中按钮上的图标颜色
  Color get navigationSelectedIconColor => isDarkMode
    ? Colors.black87  // 深色模式选中图标使用深色
    : Colors.white;   // 浅色模式选中图标使用白色

  // AppBar相关颜色
  Color get appBarForegroundColor => colorScheme.onSurface;

  // 常用文本颜色
  Color get primaryTextColor => colorScheme.onSurface;
  Color get secondaryTextColor => colorScheme.onSurfaceVariant;
}

import 'package:flutter/material.dart';
import 'app_routes.dart';
import 'route_arguments.dart';

class RouteHelper {
  // 跳转到动漫详情页
  static Future<void> goToAnimeData(
    BuildContext context, {
    required int animeId,
    String? animeName,
    String? imageUrl,
  }) {
    return Navigator.pushNamed(
      context,
      AppRoutes.animeData,
      arguments: AnimeDataArguments(
        animeId: animeId,
        animeName: animeName,
        imageUrl: imageUrl,
      ),
    );
  }

  // 回到主页
  static Future<void> goToTabs(BuildContext context) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.tabs,
      (route) => false,
    );
  }

  // 返回上一页
  static void goBack(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }

  // 替换当前页面
  static Future<void> replaceTo(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  // 清空堆栈并跳转
  static Future<void> clearAndGoTo(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
} 
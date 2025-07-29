import 'package:flutter/material.dart';
import 'app_routes.dart';
import 'route_arguments.dart';
import '../page/tabs.dart';
import '../page/search/search_page.dart';
import 'package:AnimeFlow/page/animeinfos/anime_info.dart';

class RouteGenerator {
  // 路由生成器
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.tabs:
        return MaterialPageRoute(
          builder: (_) => const Tabs(),
          settings: settings,
        );

      case AppRoutes.search:
        return MaterialPageRoute(
          builder: (_) => const SearchPage(),
          settings: settings,
        );

      case AppRoutes.animeData:
        final args = settings.arguments;

        // 支持两种参数格式：AnimeDataArguments 或直接传递 int
        if (args is AnimeDataArguments) {
          return MaterialPageRoute(
            builder: (_) => AnimeDataPage(
              animeId: args.animeId,
              animeName: args.animeName,
              imageUrl: args.imageUrl,
            ),
            settings: settings,
          );
        } else if (args is int) {
          // 向后兼容，直接传递 int
          return MaterialPageRoute(
            builder: (_) => AnimeDataPage(animeId: args),
            settings: settings,
          );
        } else {
          return _errorRoute(settings.name);
        }

      default:
        return _errorRoute(settings.name);
    }
  }

  // 404 错误页面
  static Route<dynamic> _errorRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('页面不存在')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 20),
              Text('找不到页面: $routeName', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

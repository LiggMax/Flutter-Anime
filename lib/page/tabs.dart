import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'tabs/home/home.dart';
import './tabs/profile.dart';
import './tabs/time.dart';
import '../controllers/theme_controller.dart';
import '../utils/theme_extensions.dart';
import '../routes/routes.dart';

class Tabs extends StatefulWidget {
  const Tabs({super.key});

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  int _currentIndex = 0;

  // 用于存储已创建的页面
  final Map<int, Widget> _createdPages = {};

  @override
  void initState() {
    super.initState();
    // 预创建首页，确保应用启动时能正常显示
    _createdPages[0] = const HomePage();
  }

  // 页面标题列表
  final List<String> _pageTitles = ["首页", "时间表", "个人中心"];

  // 页面创建工厂方法
  Widget _createPage(int index) {
    switch (index) {
      case 0:
        return const HomePage();
      case 1:
        return const TimePage();
      case 2:
        return const ProfilePage();
      default:
        return const HomePage();
    }
  }

  // 获取页面，如果没有创建则创建
  Widget _getPage(int index) {
    if (!_createdPages.containsKey(index)) {
      _createdPages[index] = _createPage(index);
    }
    return _createdPages[index]!;
  }

  void _navigateTo(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateToSearch() {
    Navigator.pushNamed(context, Routes.search);
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(_pageTitles[_currentIndex]),
        centerTitle: false,
        automaticallyImplyLeading: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // 状态栏透明
          statusBarIconBrightness: context.isDarkMode
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: context.isDarkMode
              ? Brightness.dark
              : Brightness.light,
        ),
        actions: [
          IconButton(
            onPressed: _navigateToSearch,
            icon: const Icon(Icons.search_outlined),
            tooltip: '搜索',
          ),
          IconButton(
            icon: Icon(context.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () async {
              await themeController.toggleTheme();
            },
            tooltip: context.isDarkMode ? '切换到浅色模式' : '切换到深色模式',
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(3, (index) {
          // 如果是当前页面或者已经创建过的页面，返回真实页面
          if (index == _currentIndex) {
            return _getPage(index);
          } else if (_createdPages.containsKey(index)) {
            return _createdPages[index]!;
          } else {
            // 返回空占位符，避免不必要的页面创建
            return const SizedBox.shrink();
          }
        }),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        onTap: _navigateTo,
        height: 70,
        color: Theme.of(context).colorScheme.secondaryFixed,
        backgroundColor: Colors.transparent,
        animationDuration: const Duration(milliseconds: 200),
        items: [
          Icon(
            Icons.home,
            size: 30,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          Icon(
            Icons.timeline_sharp,
            size: 30,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          Icon(
            Icons.person,
            size: 30,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ],
        buttonBackgroundColor: Theme.of(context).colorScheme.primary,
        animationCurve: Curves.linear,
      ),
    );
  }
}

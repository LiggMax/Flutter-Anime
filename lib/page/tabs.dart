import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'tabs/home/home.dart';
import './tabs/profile.dart';
import './tabs/time.dart';
import '../controllers/theme_controller.dart';
import '../utils/theme_extensions.dart';

class Tabs extends StatefulWidget {
  const Tabs({super.key});

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const TimePage(),
    const ProfilePage(),
  ];

  // 页面标题列表
  final List<String> _pageTitles = [
    "首页",
    "时间表",
    "个人中心",
  ];

  void _navigateTo(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_currentIndex]),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // 状态栏透明
          statusBarIconBrightness: context.isDarkMode ? Brightness.light : Brightness.dark,
          statusBarBrightness: context.isDarkMode ? Brightness.dark : Brightness.light,
        ),
        actions: [
          IconButton(
            icon: Icon(context.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () async {
              await themeController.toggleTheme();
            },
            tooltip: context.isDarkMode ? '切换到浅色模式' : '切换到深色模式',
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        onTap: _navigateTo,
        height: 70,
        color: context.navigationBarColor,
        backgroundColor: Colors.transparent,
        animationDuration: const Duration(milliseconds: 200),
        items: [
          Icon(
            Icons.home,
            size: 30,
            color: context.navigationIconColor,
          ),
          Icon(
            Icons.timeline_sharp,
            size: 30,
            color: context.navigationIconColor,
          ),
          Icon(
            Icons.person,
            size: 30,
            color: context.navigationIconColor,
          ),
        ],
        buttonBackgroundColor: context.navigationSelectedColor,
        animationCurve: Curves.easeInOut,
      ),
    );
  }
}

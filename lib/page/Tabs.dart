import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';
import './tabs/Home.dart';
import './tabs/Profile.dart';
import './tabs/Search.dart';
import '../controllers/theme_controller.dart';

class Tabs extends StatefulWidget {
  const Tabs({super.key});

  @override
  State<Tabs> createState() => _TabsState();
}

class _TabsState extends State<Tabs> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const SearchPage(),
    const ProfilePage(),
  ];

  void _navigateTo(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Anime"),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode
                ? Icons.light_mode
                : Icons.dark_mode,
            ),
            onPressed: () {
              themeController.toggleTheme();
            },
            tooltip: isDarkMode
              ? '切换到浅色模式'
              : '切换到深色模式',
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
        height: 70, // 导航栏高度
        color: isDarkMode
          ? Colors.grey[800]!
          : Colors.cyanAccent,
        backgroundColor: Colors.transparent,
        animationDuration: const Duration(milliseconds: 200),
        items: [
          Icon(
            Icons.home,
            size: 30,
            color: isDarkMode
              ? Colors.white
              : Colors.black,
          ),
          Icon(
            Icons.search,
            size: 30,
            color: isDarkMode
              ? Colors.white
              : Colors.black,
          ),
          Icon(
            Icons.person,
            size: 30,
            color: isDarkMode
              ? Colors.white
              : Colors.black,
          ),
        ],
        buttonBackgroundColor: isDarkMode
          ? Colors.blue[400]!
          : Colors.amber, // 选中按钮的背景颜色
        animationCurve: Curves.easeInOut, // 动画曲线
      ),
    );
  }
}

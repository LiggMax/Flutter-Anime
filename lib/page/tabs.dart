import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'tabs/home/home.dart';
import 'tabs/user/profile.dart';
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

  // 页面标题列表
  final List<String> _pageTitles = ["首页", "时间表", "个人中心"];

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
      backgroundColor: Theme.of(context).colorScheme.surface,
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
          systemNavigationBarColor: Theme.of(
            context,
          ).colorScheme.surface,
          systemNavigationBarIconBrightness: context.isDarkMode
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent, // 底部导航栏分割线透明
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
        children: const [HomePage(), TimePage(), ProfilePage()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _navigateTo,
        backgroundColor: Theme.of(context).colorScheme.surface,
        indicatorColor: Theme.of(context).colorScheme.primaryContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: _currentIndex == 0
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            selectedIcon: Icon(
              Icons.home,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: _pageTitles[0],
          ),
          NavigationDestination(
            icon: Icon(
              Icons.timeline_outlined,
              color: _currentIndex == 1
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            selectedIcon: Icon(
              Icons.timeline,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: _pageTitles[1],
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
              color: _currentIndex == 2
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            selectedIcon: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: _pageTitles[2],
          ),
        ],
      ),
    );
  }
}

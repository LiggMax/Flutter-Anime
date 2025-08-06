import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:media_kit/media_kit.dart';
import 'dart:async';
import './controllers/theme_controller.dart';
import './page/tabs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeController themeController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    themeController = ThemeController();
    _initializeTheme();
  }

  Future<void> _initializeTheme() async {
    await themeController.initTheme();
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
        debugShowCheckedModeBanner: false,
      );
    }

    return ChangeNotifierProvider.value(
      value: themeController,
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) {
          return AnimatedTheme(
            duration: const Duration(milliseconds: 300),
            data: themeController.currentTheme,
            child: MaterialApp(
              theme: ThemeController.lightTheme,
              darkTheme: ThemeController.darkTheme,
              themeMode: themeController.isDarkMode
                  ? ThemeMode.dark
                  : ThemeMode.light,
              home: const Tabs(),
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }
}

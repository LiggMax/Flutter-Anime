import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './page/Tabs.dart';
import './controllers/theme_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeController(),
      child: Consumer<ThemeController>(
        builder: (context, themeController, child) {
          return AnimatedTheme(
            duration: const Duration(milliseconds: 300),
            data: themeController.currentTheme,
            child: MaterialApp(
              theme: ThemeController.lightTheme,
              darkTheme: ThemeController.darkTheme,
              themeMode: themeController.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              home: const Tabs(),
              debugShowCheckedModeBanner: false,
            ),
          );
        },
      ),
    );
  }
}





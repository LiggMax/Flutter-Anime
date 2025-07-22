import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './page/Tabs.dart';
import './controllers/theme_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 初始化主题控制器
    final ThemeController themeController = Get.put(ThemeController());
    
    return GetMaterialApp(
      title: 'Flutter Anime',
      theme: themeController.lightTheme,
      darkTheme: themeController.darkTheme,
      themeMode: ThemeMode.system,
      home: const Tabs(),
      debugShowCheckedModeBanner: false,
    );
  }
}





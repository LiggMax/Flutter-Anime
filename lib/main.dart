import 'package:flutter/material.dart';
import './page/Tabs.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? ket}) : super(key: ket);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const Tabs()
    );
  }
}





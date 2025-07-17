import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(appBar: AppBar(title: const Text("hello flutter")),
      body: const MaApp()
      ),
    ),
  );
}

class MaApp extends StatelessWidget {
  const MaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("hello word"),
    );
  }
}

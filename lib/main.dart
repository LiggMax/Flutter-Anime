import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("hello flutter")),
        body: const MaApp(),
      ),
    ),
  );
}

class MaApp extends StatelessWidget {
  const MaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          //横向布局
          children: const [
            Icon(Icons.account_circle,size: 100,color: Colors.amber),
            Icon(Icons.apps_sharp),
            Icon(Icons.add)
          ],
        ),
        const Text("hello world")
      ],
    );
  }
}

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
    return Center(
      child: Container(
        alignment: Alignment.center,
        width: 200,
        height: 200,
        decoration: const BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: const Text(
          "hello flutter",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

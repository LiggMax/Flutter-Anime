import 'package:flutter/material.dart';

class TimePage extends StatefulWidget {
  const TimePage({super.key});

  @override
  State<TimePage> createState() => _TimePageState();
}

class _TimePageState extends State<TimePage> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return const Center(
      child: Text("时间表"),
    );
  }
}

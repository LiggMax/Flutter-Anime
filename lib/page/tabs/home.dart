import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/request/bangumi.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late CalendarProvider _calendarProvider;

  @override
  void initState() {
    super.initState();
    _calendarProvider = CalendarProvider();
    _calendarProvider.loadCalendar();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("首页"),
          const SizedBox(height: 20),
          StreamBuilder<CalendarState>(
            stream: _calendarProvider.stateStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final state = snapshot.data!;
                if (state.isLoading) {
                  return const CircularProgressIndicator();
                } else if (state.data != null) {
                  return const Text("已加载每日放送数据，详见控制台日志");
                } else {
                  return const Text("加载数据失败");
                }
              }
              return const CircularProgressIndicator();
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _calendarProvider.dispose();
    super.dispose();
  }
}

class CalendarProvider {
  final _stateController = StreamController<CalendarState>();
  Stream<CalendarState> get stateStream => _stateController.stream;

  CalendarProvider() {
    _stateController.add(CalendarState(isLoading: true));
  }

  Future<void> loadCalendar() async {
    _stateController.add(CalendarState(isLoading: true));

    try {
      final data = await BangumiService.getCalendar();

      _stateController.add(CalendarState(data: data, isLoading: false));
    } catch (e) {
      _stateController.add(CalendarState(isLoading: false));
    }
  }

  void dispose() {
    _stateController.close();
  }
}

class CalendarState {
  final Map<String, dynamic>? data;
  final bool isLoading;

  CalendarState({this.data, this.isLoading = false});
}

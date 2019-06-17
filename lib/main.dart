import 'package:flutter/material.dart';
import './presentation/home.dart';

void main() => runApp(SleepDestroyer());

class SleepDestroyer extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sleep Destroyer',
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: HomePage(),
    );
  }
}
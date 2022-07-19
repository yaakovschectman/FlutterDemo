import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:desktop_window/desktop_window.dart';
import 'package:first_ever_flutter_test/game_over.dart';
import 'package:first_ever_flutter_test/snake_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> setupWindow() async {
  await DesktopWindow.setMinWindowSize(const Size(300, 450));
  await DesktopWindow.setMaxWindowSize(const Size(800, 1200));
  await DesktopWindow.setWindowSize(const Size(400, 600));
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    setupWindow();
    return MaterialApp(
      title: 'Snek',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/play': (context) => const SnakeGame(title: 'Snek', w: 10, h: 10),
        '/dead': (context) => const GameOver()
      },
      initialRoute: '/play',
    );
  }
}


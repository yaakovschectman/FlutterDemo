import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'datatypes.dart';

class SnakeGame extends StatefulWidget {
  final int w, h;
  const SnakeGame({Key? key, required this.title, required this.w, required this.h}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  static const Color snakeColor = Colors.pink;

  late List<bool> occupied;
  Queue<Pair<int>> queue = Queue();
  Map<Pair<int>, Icon> board = {};
  Pair<int> head = Pair(0, 0);
  Pair<int> fruit = Pair(0, 0);
  int dx = 1, dy = 0;
  int length = 1;
  Random rng = Random();
  Timer? timer;
  bool dead = false;
  AudioPlayer player = AudioPlayer();
  AudioCache cache = AudioCache();

  @override
  void initState() {
    super.initState();
    occupied = List.filled(widget.w * widget.h, false);
    queue.addLast(head);
    occupied[head.first + head.second * widget.w] = true;
    placeFruit();
    board[head] = const Icon(Icons.chevron_left, color: snakeColor);
    // Wait to start moving until the first motion is indicated
    //timer = Timer.periodic(const Duration(milliseconds: 250), (t){stepSnake();});
  }

  void stepSnake({move = true}) {
    if (!mounted) {
      timer?.cancel();
      timer = null;
      return;
    }
    setState(() {
      Pair<int> nHead = Pair(head.first + dx, head.second + dy);
      if (nHead.first < 0 || nHead.first >= widget.w || nHead.second < 0 || nHead.second >= widget.h) {
        return;
      }
      queue.addLast(nHead);
      if (move && queue.length > length) {
        Pair<int> tail = queue.removeFirst();
        occupied[tail.first + tail.second * widget.w] = false;
      }
      if (occupied[nHead.first + nHead.second * widget.w]) {
        die();
        timer?.cancel();
        Navigator.popAndPushNamed(context, '/dead');
      }
      occupied[nHead.first + nHead.second * widget.w] = true;
      board[nHead] = board[head] ?? const Icon(Icons.chevron_left);
      head = nHead;
      if (head == fruit) {
        length++;
        player.play(AssetSource('eat.wav'));
        placeFruit();
      }
    });
  }

  void setDirection(nDx, nDy) {
    dx = nDx;
    dy = nDy;
    if (dx == -1) {
      board[head] = const Icon(Icons.chevron_left, color: snakeColor);
    }
    else if (dx == 1) {
      board[head] = const Icon(Icons.chevron_right, color: snakeColor);
    }
    else if (dy == -1) {
      board[head] = const Icon(Icons.arrow_upward, color: snakeColor);
    }
    else if (dy == 1) {
      board[head] = const Icon(Icons.arrow_downward, color: snakeColor);
    }
    timer?.cancel();
    stepSnake();
    if (!dead) {
      timer = Timer.periodic(const Duration(milliseconds: 250), (t){stepSnake();});
    }
  }

  void placeFruit() {
    List<Pair<int>> open = List
        .generate(widget.w * widget.h, (int i) => Pair(i % widget.w, i ~/ widget.w))
        .where((p) => !occupied[p.first + p.second * widget.w])
        .toList();
    if (open.isEmpty) {
      die();
      return;
    }
    int index = rng.nextInt(open.length);
    fruit = open[index];
  }

  void die() async {
    player.play(AssetSource('die.wav'));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int prev = prefs.getInt("highscore") ?? 0;
    prefs.setInt("highscore", max(prev, length));
    dead = true;
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKey: (event){
        if (event is RawKeyDownEvent) {
          LogicalKeyboardKey key = event.logicalKey;
          if (key == LogicalKeyboardKey.arrowLeft) {
            setDirection(-1, 0);
          }
          else if (key == LogicalKeyboardKey.arrowRight) {
            setDirection(1, 0);
          }
          else if (key == LogicalKeyboardKey.arrowUp) {
            setDirection(0, -1);
          }
          else if (key == LogicalKeyboardKey.arrowDown) {
            setDirection(0, 1);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("Score: $length"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  flex: 2,
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      color: Colors.grey,
                      child: Column(
                        children: [
                          for(int y = 0; y < widget.h; y++)
                            Expanded(child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  for(int x = 0; x < widget.w; x++)
                                        (){
                                      // Is there a better way to inject multiline
                                      // logic into these sorts of for-loops?
                                      Pair<int> pos = Pair(x, y);
                                      int index = x + y * widget.h;
                                      Color color = pos == head ? Colors.white
                                          : pos == fruit ? Colors.red
                                          : occupied[index] ? Colors.grey
                                          : Colors.black;
                                      Widget? child = occupied[index] ? board[pos] : null;
                                      child = Container(color: color, child: child);
                                      return Expanded(
                                        child: child,
                                      );
                                    }()
                                ]
                            ))
                        ],
                      ),
                    ),
                  )
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(onPressed: () {setDirection(-1, 0);}, icon: const Icon(
                        Icons.arrow_left
                    )),
                    IconButton(onPressed: () {setDirection(0, -1);}, icon: const Icon(
                        Icons.arrow_upward
                    )),
                    IconButton(onPressed: () {setDirection(0, 1);}, icon: const Icon(
                        Icons.arrow_downward
                    )),
                    IconButton(onPressed: () {setDirection(1, 0);}, icon: const Icon(
                        Icons.arrow_right
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),// This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}

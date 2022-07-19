import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameOver extends StatefulWidget {
  const GameOver({Key? key}) : super(key: key);

  @override
  State<GameOver> createState() => _GameOverState();
}

class _GameOverState extends State<GameOver> {
  String score = "...";

  Future<void> readScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int highscore = prefs.getInt("highscore") ?? 0;
    setState((){
      score = "$highscore";
    });
  }

  @override
  void initState() {
    super.initState();
    readScore();
  }

  Future<void> reset() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("highscore", 0);
    setState(() {
      score = "0";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Over')
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Highest Score Yet'),
            Text(
              score,
              style: const TextStyle(fontSize: 50)
            ),
            ElevatedButton(
                onPressed: (){Navigator.popAndPushNamed(context, '/play');},
                child: const Text('Play Again')
            ),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: reset,
                child: const Text('Reset')
            )
          ],
        )
      )
    );
  }
}


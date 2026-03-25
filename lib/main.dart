import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(GameApp());
}

class GameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(home: StartScreen());
  }
}

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Welcome to the game!", style: TextStyle(fontSize: 48)),
            Padding(padding: EdgeInsets.all(16)),
            ElevatedButton(
              child: Text("Start", style: TextStyle(fontSize: 24)),
              onPressed: () => Get.to(() => GameScreen()),
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GameWidget(game: TapGame());
  }
}

class ResultScreen extends StatelessWidget {
  final int score;
  const ResultScreen({required this.score});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Great work, you got $score points!",
              style: TextStyle(fontSize: 48),
            ),
            Padding(padding: EdgeInsets.all(16)),
            ElevatedButton(
              child: Text("Back to start", style: TextStyle(fontSize: 24)),
              onPressed: () => Get.to(() => StartScreen()),
            ),
          ],
        ),
      ),
    );
  }
}

class TapGame extends FlameGame {
  var score = 0;

  TapGame() {
    add(TapBox());
  }

  incrementScore() {
    score++;

    if (score >= 10) {
      Get.offAll(() => ResultScreen(score: score));
    }
  }
}

class TapBox extends RectangleComponent with HasGameRef<TapGame>, TapCallbacks {
  TapBox() : super(position: Vector2(100, 300), size: Vector2(50, 50));

  @override
  void onTapDown(TapDownEvent event) {
    gameRef.incrementScore();
    position.x = position.x + 10;
  }
}

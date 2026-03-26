import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';

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
  final gravity = Vector2(0, 100);

  var gameFinished = false;
  var timeLeft = 30.0;
  var score = 0;
  var tapNumber = 0;

  TapGame() {
    add(TapBox());
    add(TapCircle());
    add(TapPolygon());
  }

  @override
  void update(double dt) {
    super.update(dt);
    timeLeft -= dt;

    if (timeLeft <= 0 && !gameFinished) {
      gameFinished = true;
      Get.offAll(() => ResultScreen(score: score));
    }
  }

  incrementScore() {
    score++;
    tapNumber++;
  }
}

class TapBox extends RectangleComponent with HasGameRef<TapGame>, TapCallbacks {
  final random = Random();
  var timeSinceLastMove = 0.0;
  var velocity = Vector2(0, 0);

  TapBox()
    : super(
        position: Vector2(100, 300),
        size: Vector2(50, 50),
        anchor: Anchor.center,
      );

  @override
  void onTapDown(TapDownEvent event) {
    gameRef.incrementScore();
    changeLocation();
  }

  @override
  void update(double dt) {
    super.update(dt);
    transform.angle += dt;

    velocity += gameRef.gravity * dt;
    position += velocity * dt;

    timeSinceLastMove += dt;
    if (timeSinceLastMove > 1.0) {
      changeLocation();
    }

    if (position.y > gameRef.size.y - size.y) {
      position.y = gameRef.size.y - size.y;
      velocity = Vector2(0, 0);
    }
  }

  void changeLocation() {
    position.x = random.nextDouble() * (gameRef.size.x - size.x);
    position.y = random.nextDouble() * (gameRef.size.y - size.y);

    timeSinceLastMove = 0.0;
  }
}

class TapCircle extends CircleComponent with HasGameRef<TapGame>, TapCallbacks {
  final random = Random();
  var timeSinceLastMove = 0.0;
  var velocity = Vector2(0, 0);

  TapCircle() : super(position: Vector2(100, 400), radius: 50);

  @override
  void onTapDown(TapDownEvent event) {
    gameRef.incrementScore();
    changeLocation();
  }

  @override
  void update(double dt) {
    super.update(dt);
    transform.angle += dt;

    velocity += gameRef.gravity * dt;
    position += velocity * dt;

    timeSinceLastMove += dt;
    if (timeSinceLastMove > 1.0) {
      changeLocation();
    }

    if (position.y > gameRef.size.y - size.y) {
      position.y = gameRef.size.y - size.y;
      velocity = Vector2(0, 0);
    }
  }

  void changeLocation() {
    position.x = random.nextDouble() * (gameRef.size.x - size.x);
    position.y = random.nextDouble() * (gameRef.size.y - size.y);

    timeSinceLastMove = 0.0;
  }
}

class TapPolygon extends PolygonComponent
    with TapCallbacks, HasGameRef<TapGame> {
  final random = Random();
  var timeSinceLastMove = 0.0;
  var velocity = Vector2(0, 0);

  TapPolygon()
    : super(
        [Vector2(0, 0), Vector2(100, 0), Vector2(50, 100)],
        position: Vector2(100, 200),
        paint: Paint()..color = Colors.orange,
      );

  @override
  void onTapDown(TapDownEvent event) {
    gameRef.incrementScore();
    changeLocation();
  }

  @override
  void update(double dt) {
    super.update(dt);
    transform.angle += dt;

    velocity += gameRef.gravity * dt;
    position += velocity * dt;

    timeSinceLastMove += dt;
    if (timeSinceLastMove > 1.0) {
      changeLocation();
    }

    if (position.y > gameRef.size.y - size.y) {
      position.y = gameRef.size.y - size.y;
      velocity = Vector2(0, 0);
    }
  }

  void changeLocation() {
    position.x = random.nextDouble() * (gameRef.size.x - size.x);
    position.y = random.nextDouble() * (gameRef.size.y - size.y);

    timeSinceLastMove = 0.0;
  }
}

import 'dart:async' as dart_async;
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame/game.dart' show GameWidget;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// APP
void main() {
  runApp(const GameApp());
}

class GameApp extends StatelessWidget {
  const GameApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(home: StartScreen());
  }
}

// SCREENS
class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome to the game!', style: TextStyle(fontSize: 48)),
            const Padding(padding: EdgeInsets.all(16)),
            ElevatedButton(
              child: const Text('Start', style: TextStyle(fontSize: 24)),
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
  const ResultScreen({required this.score, super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Great work, you got $score points!',
              style: const TextStyle(fontSize: 48),
            ),
            const Padding(padding: EdgeInsets.all(16)),
            ElevatedButton(
              child: const Text(
                'Back to start',
                style: TextStyle(fontSize: 24),
              ),
              onPressed: () => Get.to(() => StartScreen()),
            ),
          ],
        ),
      ),
    );
  }
}

// THE GAME
class TapGame extends Forge2DGame with TapDetector {
  var gameFinished = false;
  var score = 0;

  TapGame()
    : super(
        camera: CameraComponent.withFixedResolution(width: 800, height: 600),
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    world.add(TapBox());
    world.add(TapCircle());
    world.add(TapPolygon());
    world.add(GameBounds());
    world.add(MovingObstacle());

    dart_async.Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (gameFinished) {
        timer.cancel();
        return;
      }
      world.add(MovingObstacle());
      _removeOutOfBoundsObstacles();
    });
  }

  void incrementScore() => score++;

  void finishGame() {
    if (gameFinished) return;
    gameFinished = true;
    Get.offAll(() => ResultScreen(score: score));
  }

  void _removeOutOfBoundsObstacles() {
    world.children.whereType<MovingObstacle>().forEach((o) {
      if (o.body.position.x < camera.visibleWorldRect.left) {
        world.remove(o);
      }
    });
  }
}

class GameBounds extends BodyComponent {
  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.static,
      position: Vector2.zero(),
      userData: this,
    );

    final boundsBody = world.createBody(bodyDef);
    final r = game.camera.visibleWorldRect;

    // Four corners, inset by 1 unit top/bottom so the walls are visible
    final corners = [
      Vector2(r.left, r.top + 1),
      Vector2(r.right, r.top + 1),
      Vector2(r.right, r.bottom - 1),
      Vector2(r.left, r.bottom - 1),
    ];

    for (int i = 0; i < corners.length; i++) {
      boundsBody.createFixture(
        FixtureDef(
          EdgeShape()..set(corners[i], corners[(i + 1) % corners.length]),
        ),
      );
    }

    return boundsBody;
  }
}

class MovingObstacle extends BodyComponent {
  final _rng = Random();
  static const _obstacleHeight = 25.0;
  static const _edgeBuffer = 2.0;

  @override
  Body createBody() {
    final halfH = _obstacleHeight / 2;
    final r = game.camera.visibleWorldRect;

    final posY = _rng.nextBool()
        ? r.top + _edgeBuffer + halfH
        : r.bottom - _edgeBuffer - halfH;

    final bodyDef = BodyDef(
      position: Vector2(r.right + _edgeBuffer, posY),
      gravityOverride: Vector2.zero(),
      linearVelocity: Vector2(-10, 0),
      type: BodyType.dynamic,
      userData: this,
    );

    final shape = PolygonShape()..setAsBoxXY(2, halfH);
    return world.createBody(bodyDef)..createFixture(FixtureDef(shape));
  }
}

// GAME OBJECTS
class TapBox extends BodyComponent<TapGame>
    with TapCallbacks, ContactCallbacks {
  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: Vector2.zero(),
      type: BodyType.dynamic,
      angularVelocity: 1.5,
      userData: this,
    );

    final shape = PolygonShape()..setAsBoxXY(2.5, 2.5);
    final fixtureDef = FixtureDef(shape)..restitution = 0.25;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.incrementScore();
    body.setAwake(true);
    body.applyLinearImpulse(Vector2(0, -500));
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is MovingObstacle) {
      game.finishGame();
    }
  }
}

class TapCircle extends BodyComponent<TapGame>
    with TapCallbacks, ContactCallbacks {
  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: Vector2(5, 10),
      type: BodyType.dynamic,
      angularVelocity: 1.0,
      userData: this,
    );

    final shape = CircleShape()..radius = 2.5;

    final fixtureDef = FixtureDef(shape)
      ..restitution =
          0.8 // more bouncy than box
      ..density = 1.0;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.incrementScore();

    body.setAwake(true);
    body.applyLinearImpulse(Vector2(0, -400));
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is MovingObstacle) {
      game.finishGame();
    }
  }
}

class TapPolygon extends BodyComponent<TapGame>
    with TapCallbacks, ContactCallbacks {
  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: Vector2(10, 10),
      type: BodyType.dynamic,
      angularVelocity: 1.2,
      userData: this,
    );

    final shape = PolygonShape()
      ..set([Vector2(0, 0), Vector2(3, 0), Vector2(1.5, 3)]);

    final fixtureDef = FixtureDef(shape)
      ..restitution = 0.4
      ..density = 1.0;

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.incrementScore();

    body.setAwake(true);
    body.applyLinearImpulse(Vector2(0, -450));
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is MovingObstacle) {
      game.finishGame();
    }
  }
}

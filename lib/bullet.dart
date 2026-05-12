import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class Bullet extends CircleComponent with HasGameRef<VampireGame> {
  final Vector2 velocity;

  Bullet({required Vector2 position, required this.velocity})
      : super(radius: 4, position: position, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    paint = Paint()..color = Colors.yellow;
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.add(velocity * dt);
    if (position.x < 0 || position.x > gameRef.size.x || position.y < 0 || position.y > gameRef.size.y) {
      removeFromParent();
    }
  }
}
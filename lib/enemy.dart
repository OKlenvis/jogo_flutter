import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'bullet.dart';

class Enemy extends PositionComponent with HasGameRef<VampireGame>, CollisionCallbacks {
  double speed = 100;

  Enemy({required Vector2 position}) 
    : super(size: Vector2(30, 30), position: position, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
    if (gameRef.dificuldade == 'DIFÍCIL') speed = 160;
    else if (gameRef.dificuldade == 'FÁCIL') speed = 60;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Desenho do Vampirinho
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 15, Paint()..color = const Color(0xFF212121)); // Capa
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 10, Paint()..color = const Color(0xFFF5F5F5)); // Rosto
    canvas.drawCircle(Offset(size.x / 2 - 4, size.y / 2 - 2), 2, Paint()..color = Colors.red); // Olho E
    canvas.drawCircle(Offset(size.x / 2 + 4, size.y / 2 - 2), 2, Paint()..color = Colors.red); // Olho D
  }

  @override
  void update(double dt) {
    super.update(dt);
    Vector2 dir = gameRef.player.position - position;
    position.add(dir.normalized() * speed * dt);
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (other is Bullet) {
      gameRef.score += 10;
      removeFromParent();
      other.removeFromParent();
    }
  }
}
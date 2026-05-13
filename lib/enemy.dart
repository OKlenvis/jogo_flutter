import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'gun_drop.dart';

class Enemy extends PositionComponent with HasGameRef<VampireGame>, CollisionCallbacks {
  double speed = 150;

  Enemy({required Vector2 position}) : super(size: Vector2(30, 30), position: position, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(CircleHitbox());
    if (gameRef.dificuldade == 'FÁCIL') speed = 120;
    else if (gameRef.dificuldade == 'MÉDIO') speed = 190;
    else speed = 280;
  }

  @override
  void onRemove() {
    super.onRemove();
    // Lógica do Drop: Score > 200 e 20% de chance e o player ainda não tem arma
    if (gameRef.score >= 200 && !gameRef.player.temArma) {
      if (Random().nextDouble() < 0.2) {
        gameRef.add(GunDrop(position: position.clone()));
      }
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 15, Paint()..color = const Color(0xFF212121)); 
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 10, Paint()..color = const Color(0xFFF5F5F5)); 
  }

  @override
  void update(double dt) {
    super.update(dt);
    Vector2 dir = gameRef.player.position - position;
    position.add(dir.normalized() * speed * dt);
  }
}
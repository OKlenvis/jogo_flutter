import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'enemy.dart';
import 'main.dart';

class Sword extends PositionComponent with HasGameRef<VampireGame>, CollisionCallbacks {
  double timer = 0;
  final double duration = 0.06; // Aumentei levemente para o rastro maior ser visível

  Sword({required Vector2 position, required double angle}) 
    : super(
        size: Vector2(120, 120), // Aumentado de 80 para 120 (Área bem maior)
        position: position, 
        angle: angle, 
        anchor: Anchor.center 
      );

  @override
  Future<void> onLoad() async {
    // Hitbox ampliada: agora cobre uma área maior à frente do jogador
    add(PolygonHitbox([
      Vector2(60, 60),   // Centro
      Vector2(120, 0),   // Ponta superior
      Vector2(140, 60),  // Extensão frontal (alcance extra)
      Vector2(120, 120), // Ponta inferior
    ]));
  }

  @override
  void update(double dt) {
    super.update(dt);
    timer += dt;
    if (timer >= duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    // Efeito visual de "Slash" (Corte) ampliado
    final paint = Paint()
      ..shader = const RadialGradient(
        colors: [Colors.white, Colors.cyanAccent, Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.x, size.y));

    // Desenha o arco de corte
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.x, size.y),
      -math.pi / 1.8, // Um pouco mais aberto que 180 graus
      math.pi * 1.1,  
      true,
      paint,
    );
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (other is Enemy) {
      gameRef.score += 10;
      other.removeFromParent();
    }
  }
}
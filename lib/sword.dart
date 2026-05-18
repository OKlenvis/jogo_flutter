import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'enemy.dart';
import 'main.dart';

class Sword extends PositionComponent with HasGameRef<VampireGame>, CollisionCallbacks {
  double timer = 0;
  final double duration = 0.15; // Duração total do golpe (bem rápido)
  final double swingAngle = math.pi; // O arco do golpe (180 graus)
  late double baseAngle;

  Sword({required Vector2 position, required double angle}) 
    : super(size: Vector2(60, 20), position: position, anchor: Anchor.centerLeft) {
    baseAngle = angle;
    this.angle = angle - (swingAngle / 2); // Começa o arco atrás da direção
  }

  @override
  Future<void> onLoad() async {
    // Adiciona a hitbox para detectar os inimigos
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    timer += dt;

    // Animação de rotação: vai do ângulo inicial até o final do arco
    double progress = timer / duration;
    angle = baseAngle - (swingAngle / 2) + (swingAngle * progress);

    // Remove a espada quando a animação termina
    if (timer >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    // Cálculo de opacidade para sumir suavemente no final
    double opacity = (1.0 - (timer / duration)).clamp(0.0, 1.0);
    
    // Desenho da lâmina (um degradê ou rastro branco/azul)
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity * 0.8)
      ..style = PaintingStyle.fill;

    // Desenho de um trapézio para parecer uma lâmina estilizada
    final path = Path();
    path.moveTo(0, size.y / 2); // Cabo
    path.lineTo(size.x, 0); // Ponta superior
    path.lineTo(size.x, size.y); // Ponta inferior
    path.close();

    canvas.drawPath(path, paint);

    // Adiciona um brilho na borda para parecer mais afiada
    final glowPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, glowPaint);
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);

    if (other is Enemy) {
      gameRef.score += 10;
      other.removeFromParent();
      // Nota: A espada NÃO se remove ao tocar no inimigo (para matar vários de uma vez)
    }
  }
}
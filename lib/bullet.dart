import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'enemy.dart'; // Importante para reconhecer o inimigo
import 'main.dart';

class Bullet extends PositionComponent with HasGameRef<VampireGame>, CollisionCallbacks {
  final Vector2 velocity;

  Bullet({required Vector2 position, required this.velocity}) 
    : super(size: Vector2(10, 10), position: position, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Adiciona a hitbox para a bala conseguir colidir
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Move a bala
    position += velocity * dt;

    // Remove a bala se ela sair da tela para não pesar o jogo
    if (position.x < 0 || position.x > gameRef.size.x || 
        position.y < 0 || position.y > gameRef.size.y) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    // Desenha a bala (um pequeno círculo amarelo brilhante)
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2), 
      5, 
      Paint()..color = Colors.yellowAccent
    );
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);

    // LÓGICA DE MORTE: Se a bala encostar no inimigo
    if (other is Enemy) {
      gameRef.score += 10; // Aumenta o score
      other.removeFromParent(); // Remove o inimigo
      removeFromParent(); // Remove a bala após o impacto
    }
  }
}
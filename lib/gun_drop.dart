import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'player.dart';

class GunDrop extends PositionComponent with HasGameRef, CollisionCallbacks {
  GunDrop({required Vector2 position}) 
    : super(size: Vector2(24, 24), position: position, anchor: Anchor.center);

  @override // Adicione isso para remover o aviso amarelo
  Future<void> onLoad() async {
    add(CircleHitbox());
  }

  @override // Adicione isso para remover o aviso amarelo
  void render(Canvas canvas) {
    // Desenha um ícone de arminha amarela brilhando no chão
    // Fundo amarelo brilhante
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y), 
      Paint()..color = Colors.yellow
    );
    
    // Detalhe preto para parecer uma arma (um "L" invertido)
    canvas.drawRect(
      Rect.fromLTWH(4, 8, 16, 6), 
      Paint()..color = Colors.black
    );
    canvas.drawRect(
      Rect.fromLTWH(14, 14, 6, 6), 
      Paint()..color = Colors.black
    );
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (other is Player) {
      other.coletarArma;
      removeFromParent(); // Remove o item do chão após coletar
    }
  }
}
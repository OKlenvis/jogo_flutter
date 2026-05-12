import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'enemy.dart';
import 'bullet.dart';

class Player extends PositionComponent with HasGameRef<VampireGame>, CollisionCallbacks, KeyboardHandler {
  double speed = 250;
  Vector2 direction = Vector2.zero();
  late Timer bulletTimer;

  Player() : super(size: Vector2(40, 40), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    priority = 10;
    add(CircleHitbox());
    position = gameRef.size / 2;
    bulletTimer = Timer(0.6, onTick: _atirarNoMaisProximo, repeat: true);
  }

  void _atirarNoMaisProximo() {
    final inimigos = gameRef.children.query<Enemy>();
    if (inimigos.isNotEmpty) {
      Enemy? alvoProximo;
      double menorDistancia = double.infinity;

      for (var inimigo in inimigos) {
        double dist = position.distanceTo(inimigo.position);
        if (dist < menorDistancia) {
          menorDistancia = dist;
          alvoProximo = inimigo;
        }
      }

      if (alvoProximo != null) {
        Vector2 direcaoTiro = (alvoProximo.position - position).normalized();
        gameRef.add(Bullet(position: position.clone(), velocity: direcaoTiro * 450));
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    bulletTimer.update(dt);
    position.add(direction * speed * dt);
    position.clamp(Vector2.zero() + size / 2, gameRef.size - size / 2);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Desenho do Caçador
    canvas.drawRect(Rect.fromLTWH(5, 15, 30, 25), Paint()..color = const Color(0xFF5D4037)); // Capa
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 15, Paint()..color = Colors.grey[800]!); // Corpo
    canvas.drawRect(Rect.fromLTWH(0, 5, 40, 5), Paint()..color = Colors.black); // Chapéu
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    direction.x = 0; direction.y = 0;
    if (keysPressed.contains(LogicalKeyboardKey.keyW)) direction.y = -1;
    if (keysPressed.contains(LogicalKeyboardKey.keyS)) direction.y = 1;
    if (keysPressed.contains(LogicalKeyboardKey.keyA)) direction.x = -1;
    if (keysPressed.contains(LogicalKeyboardKey.keyD)) direction.x = 1;
    return true;
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (other is Enemy) gameRef.finalizarJogo();
  }
}
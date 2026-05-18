import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

import 'main.dart';
import 'enemy.dart';
import 'bullet.dart';
import 'sword.dart';

class Player extends PositionComponent with HasGameRef<VampireGame>, CollisionCallbacks, KeyboardHandler {
  double speed = 250;
  Vector2 direction = Vector2.zero();
  Vector2 lastDirection = Vector2(1, 0); 
  
  bool temArma = false; // Se já coletou o item da arma
  bool usandoArma = false; // Qual arma está na mão no momento
  bool podeAtacar = true;
  double timerAux = 0;

  Player() : super(size: Vector2(45, 55), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    priority = 10;
    add(RectangleHitbox(size: Vector2(30, 45), position: Vector2(7.5, 5)));
    position = gameRef.size / 2;
  }

  // Chamado quando o jogador coleta o item de arma no chão
  void coletarArma() {
    temArma = true;
    usandoArma = true; // Muda automaticamente para a arma ao coletar
  }

  void _atacar() {
    if (!podeAtacar) return;

    double cooldown;

    if (temArma && usandoArma) {
      // --- ATAQUE COM ARMA (FOGO) ---
      cooldown = 0.18;
      final inimigos = gameRef.children.query<Enemy>();
      
      if (inimigos.isNotEmpty) {
        Enemy alvo = inimigos.first;
        double menorDistancia = position.distanceTo(alvo.position);

        for (var inimigo in inimigos) {
          double dist = position.distanceTo(inimigo.position);
          if (dist < menorDistancia) {
            menorDistancia = dist;
            alvo = inimigo;
          }
        }
        Vector2 direcaoTiro = (alvo.position - position).normalized();
        gameRef.add(Bullet(position: position.clone(), velocity: direcaoTiro * 450));
      } else {
        gameRef.add(Bullet(position: position.clone(), velocity: lastDirection * 450));
      }
    } else {
      // --- ATAQUE COM ESPADA (CORTE) ---
      cooldown = 0.25;
      double angulo = math.atan2(lastDirection.y, lastDirection.x);
      gameRef.add(Sword(position: position.clone(), angle: angulo));
    }

    podeAtacar = false;
    timerAux = 0;
    _setCooldown(cooldown);
  }

  double _currentCooldown = 0.25;
  void _setCooldown(double val) => _currentCooldown = val;

  @override
  void update(double dt) {
    super.update(dt);
    if (!podeAtacar) {
      timerAux += dt;
      if (timerAux >= _currentCooldown) podeAtacar = true;
    }

    if (!direction.isZero()) {
      lastDirection = direction.normalized();
    }

    position.add(direction * speed * dt);
    position.clamp(Vector2.zero() + size / 2, gameRef.size - size / 2);
  }

  @override
  void render(Canvas canvas) {
    final bool lookingLeft = lastDirection.x < 0;
    
    if (lookingLeft) {
      canvas.save();
      canvas.translate(size.x, 0);
      canvas.scale(-1, 1);
    }

    final brownDark = Paint()..color = const Color(0xFF3E2723);
    final brownLight = Paint()..color = const Color(0xFF5D4037);
    final skin = Paint()..color = const Color(0xFFFFCCBC);
    final hatColor = Paint()..color = const Color(0xFF212121);
    final detailRed = Paint()..color = const Color(0xFFD32F2F);

    // Corpo e Capa
    canvas.drawRect(const Rect.fromLTWH(10, 20, 25, 30), brownLight);
    canvas.drawRect(const Rect.fromLTWH(8, 22, 29, 25), brownDark);

    // Rosto
    canvas.drawRect(const Rect.fromLTWH(15, 10, 15, 15), skin);
    canvas.drawRect(const Rect.fromLTWH(24, 15, 3, 3), Paint()..color = Colors.black);

    // Chapéu
    canvas.drawRect(const Rect.fromLTWH(5, 10, 35, 4), hatColor);
    canvas.drawRect(const Rect.fromLTWH(13, 2, 19, 8), hatColor);
    canvas.drawRect(const Rect.fromLTWH(13, 8, 19, 2), detailRed);

    // INDICADOR DE ARMA NA MÃO
    if (temArma && usandoArma) {
      // Desenha a pistola na mão do caçador
      canvas.drawRect(const Rect.fromLTWH(25, 25, 15, 8), Paint()..color = Colors.grey[700]!);
      canvas.drawRect(const Rect.fromLTWH(35, 25, 3, 12), Paint()..color = Colors.grey[800]!);
    } else {
      // Desenha o cabo da espada aparecendo no ombro/costas
      canvas.drawRect(const Rect.fromLTWH(5, 15, 6, 12), Paint()..color = Colors.blueGrey[800]!);
      canvas.drawRect(const Rect.fromLTWH(2, 18, 12, 3), Paint()..color = Colors.amber);
    }

    if (lookingLeft) canvas.restore();
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    direction.x = (keysPressed.contains(LogicalKeyboardKey.keyA) ? -1 : 0) + (keysPressed.contains(LogicalKeyboardKey.keyD) ? 1 : 0);
    direction.y = (keysPressed.contains(LogicalKeyboardKey.keyW) ? -1 : 0) + (keysPressed.contains(LogicalKeyboardKey.keyS) ? 1 : 0);

    if (event is KeyDownEvent) {
      // ATACAR COM P
      if (event.logicalKey == LogicalKeyboardKey.keyP) {
        _atacar();
      }
      
      // ALTERNAR ARMA COM Q
      if (event.logicalKey == LogicalKeyboardKey.keyQ && temArma) {
        usandoArma = !usandoArma;
      }
    }
    return true;
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    if (other is Enemy) gameRef.finalizarJogo();
  }
}
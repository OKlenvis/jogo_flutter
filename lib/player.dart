import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

// Importações dos outros arquivos do seu projeto
import 'main.dart';
import 'enemy.dart';
import 'bullet.dart';
import 'sword.dart';

class Player extends PositionComponent with HasGameRef<VampireGame>, CollisionCallbacks, KeyboardHandler {
  double speed = 250;
  Vector2 direction = Vector2.zero();
  Vector2 lastNonZeroDirection = Vector2(1, 0); // Direção padrão inicial (Direita)
  
  bool temArma = false;
  bool podeAtacar = true;
  double cooldownTime = 0.25; // Tempo entre um golpe e outro
  double timerAux = 0;

  Player() : super(size: Vector2(40, 40), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    priority = 10;
    add(CircleHitbox());
    position = gameRef.size / 2; // Começa no centro da tela
  }

  // Chamado quando o jogador encosta no GunDrop
  void coletarArma() {
    temArma = true;
    cooldownTime = 0.2; // A arma atira um pouco mais rápido que a espada
  }

  void _atacar() {
    if (!podeAtacar) return;

    if (temArma) {
      // --- LÓGICA DA ARMA: Mira Automática ---
      final inimigos = gameRef.children.query<Enemy>();
      
      if (inimigos.isNotEmpty) {
        // Encontra o inimigo mais próximo para atirar
        Enemy maisProximo = inimigos.first;
        double menorDist = position.distanceTo(maisProximo.position);
        
        for (var i in inimigos) {
          double d = position.distanceTo(i.position);
          if (d < menorDist) {
            menorDist = d;
            maisProximo = i;
          }
        }
        
        Vector2 direcaoTiro = (maisProximo.position - position).normalized();
        gameRef.add(Bullet(position: position.clone(), velocity: direcaoTiro * 450));
      } else {
        // Se não houver ninguém na tela, atira para onde o jogador está virado
        gameRef.add(Bullet(position: position.clone(), velocity: lastNonZeroDirection * 450));
      }
    } else {
      // --- LÓGICA DA ESPADA: Segue o Movimento ---
      // math.atan2 calcula o ângulo exato baseado no X e Y do movimento
      double angulo = math.atan2(lastNonZeroDirection.y, lastNonZeroDirection.x);
      gameRef.add(Sword(position: position.clone(), angle: angulo));
    }

    // Inicia o cooldown (recarga)
    podeAtacar = false;
    timerAux = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Gerenciador de tempo de recarga
    if (!podeAtacar) {
      timerAux += dt;
      if (timerAux >= cooldownTime) {
        podeAtacar = true;
      }
    }

    // Registra a última direção que o jogador se moveu (para saber para onde atacar parado)
    if (!direction.isZero()) {
      lastNonZeroDirection = direction.normalized();
    }

    // Movimentação física
    position.add(direction * speed * dt);
    
    // Impede o jogador de sair das bordas da tela
    position.clamp(Vector2.zero() + size / 2, gameRef.size - size / 2);
  }

  @override
  void render(Canvas canvas) {
    // Desenho do corpo (Capa)
    canvas.drawRect(Rect.fromLTWH(5, 15, 30, 25), Paint()..color = const Color(0xFF5D4037));
    
    // Cabeça/Corpo principal
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 15, Paint()..color = Colors.grey[800]!);
    
    // Se tiver a arma, mostra um brilho amarelo no centro do personagem
    if (temArma) {
      canvas.drawCircle(Offset(size.x / 2, size.y / 2), 5, Paint()..color = Colors.yellow);
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Captura teclas de movimento
    direction.x = (keysPressed.contains(LogicalKeyboardKey.keyA) ? -1 : 0) + 
                  (keysPressed.contains(LogicalKeyboardKey.keyD) ? 1 : 0);
    direction.y = (keysPressed.contains(LogicalKeyboardKey.keyW) ? -1 : 0) + 
                  (keysPressed.contains(LogicalKeyboardKey.keyS) ? 1 : 0);

    // Captura o clique na tecla P (KeyDown para não disparar mil vezes em um clique)
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyP) {
      _atacar();
    }

    return true;
  }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    // Se encostar em qualquer inimigo, fim de jogo
    if (other is Enemy) {
      gameRef.finalizarJogo();
    }
  }
}
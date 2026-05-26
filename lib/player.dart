import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/collisions.dart'; // Importante para detectar quando o inimigo encosta
import 'package:flutter/services.dart';
import 'main.dart'; 
import 'attack_area.dart'; 
import 'enemy.dart'; // Importa o arquivo do inimigo para fazer a verificação

class Player extends SpriteAnimationComponent with HasGameRef<VampireGame>, KeyboardHandler, CollisionCallbacks {
  
  Vector2 direcao = Vector2.zero();
  final double velocidade = 150.0; 
  
  // Animações de Movimento
  late final SpriteAnimation _animacaoCima;
  late final SpriteAnimation _animacaoBaixo;
  late final SpriteAnimation _animacaoEsquerda;
  late final SpriteAnimation _animacaoDireita;

  // Animações de Ataque (1 frame cada)
  late final SpriteAnimation _ataqueCima;
  late final SpriteAnimation _ataqueBaixo;
  late final SpriteAnimation _ataqueEsquerda;
  late final SpriteAnimation _ataqueDireita;

  // Controle de estado do ataque
  bool estaAtacando = false;
  double tempoAtaque = 0.0;
  final double duracaoAtaque = 0.1; 
  
  AttackArea? areaAtaqueAtual;
  String ultimaDirecao = 'baixo';

  dynamic arma; 
  bool temArma = false; 

  Player() : super(size: Vector2(64, 64)); 

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final imgCima = await Flame.images.load('player_up.png');
    final imgBaixo = await Flame.images.load('player_down.png');
    final imgEsquerda = await Flame.images.load('player_left.png');
    final imgDireita = await Flame.images.load('player_right.png');

    final imgAtqCima = await Flame.images.load('player_attack_up.png');
    final imgAtqBaixo = await Flame.images.load('player_attack_down.png');
    final imgAtqEsquerda = await Flame.images.load('player_attack_left.png');
    final imgAtqDireita = await Flame.images.load('player_attack_right.png');

    SpriteAnimation criarAnimacaoMovimento(dynamic imagem) {
      return SpriteAnimation.fromFrameData(
        imagem,
        SpriteAnimationData([
          SpriteAnimationFrameData(srcPosition: Vector2(4, 0), srcSize: Vector2(287, 287), stepTime: 0.12),
          SpriteAnimationFrameData(srcPosition: Vector2(291, 0), srcSize: Vector2(287, 287), stepTime: 0.12),
          SpriteAnimationFrameData(srcPosition: Vector2(578, 0), srcSize: Vector2(287, 287), stepTime: 0.12),
        ]),
      );
    }

    SpriteAnimation criarAnimacaoAtaque(dynamic imagem) {
      return SpriteAnimation.spriteList(
        [Sprite(imagem)],
        stepTime: duracaoAtaque,
      );
    }

    _animacaoCima = criarAnimacaoMovimento(imgCima);
    _animacaoBaixo = criarAnimacaoMovimento(imgBaixo);
    _animacaoEsquerda = criarAnimacaoMovimento(imgEsquerda);
    _animacaoDireita = criarAnimacaoMovimento(imgDireita);

    _ataqueCima = criarAnimacaoAtaque(imgAtqCima);
    _ataqueBaixo = criarAnimacaoAtaque(imgAtqBaixo);
    _ataqueEsquerda = criarAnimacaoAtaque(imgAtqEsquerda);
    _ataqueDireita = criarAnimacaoAtaque(imgAtqDireita);

    animation = _animacaoBaixo;
    position = gameRef.size / 2; 
    anchor = Anchor.center; 

    // Caixa de colisão do corpo do jogador
    add(RectangleHitbox());
  }

  // CONFIGURAÇÃO DE MORTE: Detecta quando um inimigo encosta no corpo do jogador
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    // Se o que encostou na gente for um Inimigo
    if (other is Enemy) {
      // Remove o jogador da tela
      removeFromParent();
      
      // CHAMA A SUA TELA DE GAME OVER QUE JÁ EXISTE NO MAIN
      // Nota: Mude "gameOver()" para o nome exato da função ou overlay que você usa no seu VampireGame
      gameRef.overlays.add('GameOver'); 
      // Se o seu jogo usa uma função direta ao invés de overlay, seria: gameRef.gameOver();
    }
  }

  void coletarArma(dynamic novaArma) {
    arma = novaArma;
    temArma = true;
    add(arma); 
  }

  void atacar() {
    if (areaAtaqueAtual != null) {
      areaAtaqueAtual?.removeFromParent();
      areaAtaqueAtual = null;
    }

    estaAtacando = true;
    tempoAtaque = 0.0;

    Vector2 posicaoAtaque = Vector2.zero();
    Vector2 tamanhoAtaque = Vector2.zero();

    if (ultimaDirecao == 'cima') {
      animation = _ataqueCima;
      posicaoAtaque = Vector2(0, -20); 
      tamanhoAtaque = Vector2(64, 20); 
    } else if (ultimaDirecao == 'baixo') {
      animation = _ataqueBaixo;
      posicaoAtaque = Vector2(0, 44);  
      tamanhoAtaque = Vector2(64, 20); 
    } else if (ultimaDirecao == 'esquerda') {
      animation = _ataqueEsquerda;
      posicaoAtaque = Vector2(-20, 0); 
      tamanhoAtaque = Vector2(20, 64); 
    } else if (ultimaDirecao == 'direita') {
      animation = _ataqueDireita;
      posicaoAtaque = Vector2(44, 0);  
      tamanhoAtaque = Vector2(20, 64); 
    }
    
    areaAtaqueAtual = AttackArea(position: posicaoAtaque, size: tamanhoAtaque);
    add(areaAtaqueAtual!);

    animationTicker?.reset();
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (direcao.length > 0) {
      position += direcao.normalized() * velocidade * dt;
    }

    if (estaAtacando) {
      tempoAtaque += dt;
      if (tempoAtaque >= duracaoAtaque) {
        estaAtacando = false; 
        areaAtaqueAtual?.removeFromParent();
        areaAtaqueAtual = null;
      }
      return; 
    }

    if (direcao.length > 0) {
      animationTicker?.paused = false; 

      if (direcao.y < 0) {
        animation = _animacaoCima;
        ultimaDirecao = 'cima';
      } else if (direcao.y > 0) {
        animation = _animacaoBaixo;
        ultimaDirecao = 'baixo';
      } else if (direcao.x < 0) {
        animation = _animacaoEsquerda;
        ultimaDirecao = 'esquerda';
      } else if (direcao.x > 0) {
        animation = _animacaoDireita;
        ultimaDirecao = 'direita';
      }
    } else {
      animationTicker?.paused = true;  
      animationTicker?.currentIndex = 0; 
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    direcao = Vector2.zero();

    if (keysPressed.contains(LogicalKeyboardKey.keyW) || keysPressed.contains(LogicalKeyboardKey.arrowUp)) direcao.y -= 1;
    if (keysPressed.contains(LogicalKeyboardKey.keyS) || keysPressed.contains(LogicalKeyboardKey.arrowDown)) direcao.y += 1;
    if (keysPressed.contains(LogicalKeyboardKey.keyA) || keysPressed.contains(LogicalKeyboardKey.arrowLeft)) direcao.x -= 1;
    if (keysPressed.contains(LogicalKeyboardKey.keyD) || keysPressed.contains(LogicalKeyboardKey.arrowRight)) direcao.x += 1;

    if (keysPressed.contains(LogicalKeyboardKey.keyP)) {
      atacar();
    }

    return true; 
  }
}
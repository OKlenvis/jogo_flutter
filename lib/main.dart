import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 

// Seus componentes e arquivos do jogo
import 'player.dart';
import 'enemy_manager.dart';
import 'city_map.dart';

// Seus arquivos de menus e interfaces
import 'start_menu.dart';
import 'pause_menu.dart';
import 'game_over_menu.dart';
import 'score_hud.dart';

void main() {
  runApp(const GameApp());
}

class GameApp extends StatelessWidget {
  const GameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameWidget<VampireGame>(
          game: VampireGame(),
          overlayBuilderMap: {
            'Menu': (context, game) => StartMenu(game: game),
            'Pause': (context, game) => PauseMenu(game: game),
            'GameOver': (context, game) => GameOverMenu(game: game),
            'ScoreHUD': (context, game) => ScoreHUD(game: game),
            'PauseButton': (context, game) => Positioned(
                  top: 20,
                  right: 20,
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: const Icon(Icons.pause, color: Colors.white, size: 40),
                      onPressed: () => game.pausarJogo(),
                    ),
                  ),
                ),
          },
          initialActiveOverlays: const ['Menu'],
        ),
      ),
    );
  }
}

class VampireGame extends FlameGame with HasCollisionDetection, HasKeyboardHandlerComponents {
  late Player player;
  int score = 0;
  int bestScore = 0;
  String dificuldade = 'MÉDIO'; 

  // --- CÁLCULO DE DIFICULDADE PROGRESSIVA ---
  double get multiplicadorDificuldade {
    int leveisPassados = score ~/ 500; 
    return 1.0 + (leveisPassados * 0.20); 
  }

  @override
  Color backgroundColor() => const Color(0xFF0D0B1E);

  // --- ESCUTA DA TECLA ESC PARA PAUSAR ---
  @override
  KeyEventResult onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is KeyDownEvent;
    
    // Se apertar ESC e o jogo estiver rodando (botão de pause ativo e menu de pause fechado)
    if (isKeyDown && event.logicalKey == LogicalKeyboardKey.escape) {
      if (overlays.isActive('PauseButton') && !overlays.isActive('Pause')) {
        pausarJogo();
        return KeyEventResult.handled; 
      }
    }
    
    return super.onKeyEvent(event, keysPressed);
  }

  // --- GERENCIAMENTO DE ENTIDADES E MUNDO ---

  void iniciarJogo() {
    score = 0;
    overlays.remove('Menu');
    overlays.addAll(['PauseButton', 'ScoreHUD']);
    _montarMundo();
  }

  void _montarMundo() {
    removeAll(children);
    
    add(CityMap());
    
    player = Player();
    add(player);
    
    add(EnemyManager());
    
    resumeEngine();
  }

  // --- CONTROLE DE TELAS (OVERLAYS) ---

  void pausarJogo() {
    pauseEngine();
    overlays.add('Pause');
    overlays.remove('PauseButton');
  }

  void retomarJogo() {
    resumeEngine();
    overlays.remove('Pause');
    overlays.add('PauseButton');
  }

  void finalizarJogo() {
    pauseEngine();
    if (score > bestScore) bestScore = score;
    overlays.removeAll(['PauseButton', 'ScoreHUD']);
    overlays.add('GameOver');
  }

  void reiniciarJogo() {
    score = 0;
    // Remove qualquer menu que possa estar aberto antes de recriar o mundo
    overlays.remove('GameOver');
    overlays.remove('Pause'); 
    
    _montarMundo();
    overlays.addAll(['PauseButton', 'ScoreHUD']);
    resumeEngine(); // Garante que o motor do jogo volte a rodar
  }

  void sairDoJogo() {
    removeAll(children);
    resumeEngine();
    overlays.removeAll(['Pause', 'PauseButton', 'GameOver', 'ScoreHUD']);
    overlays.add('Menu');
  }
}
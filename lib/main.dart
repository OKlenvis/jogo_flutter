import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import 'player.dart';
import 'enemy_manager.dart';
import 'start_menu.dart';
import 'pause_menu.dart';
import 'game_over_menu.dart';
import 'score_hud.dart';
import 'city_map.dart';

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
  String dificuldade = 'MÉDIO';
  int score = 0;
  int bestScore = 0;

  @override
  Color backgroundColor() => const Color(0xFF0D0B1E);

  void iniciarJogo() {
    score = 0;
    overlays.remove('Menu');
    overlays.addAll(['PauseButton', 'ScoreHUD']);
    _montarCenario();
  }

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
    overlays.remove('GameOver');
    resumeEngine();
    _montarCenario();
    overlays.addAll(['PauseButton', 'ScoreHUD']);
  }

  void sairDoJogo() {
    removeAll(children);
    resumeEngine();
    overlays.removeAll(['Pause', 'PauseButton', 'GameOver', 'ScoreHUD']);
    overlays.add('Menu');
  }

  void _montarCenario() {
    removeAll(children); 
    add(CityMap());
    player = Player();
    add(player);
    add(EnemyManager());
  }
}
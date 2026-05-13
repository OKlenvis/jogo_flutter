import 'dart:math';
import 'package:flame/components.dart';
import 'main.dart';
import 'enemy.dart';

class EnemyManager extends Component with HasGameRef<VampireGame> {
  late Timer timer;
  Random random = Random();

  @override
  void onMount() {
    super.onMount();
    
    // Define o tempo de surgimento baseado na dificuldade
    double spawnTempo = 1.5; // Médio
    if (gameRef.dificuldade == 'FÁCIL') spawnTempo = 2.2;
    if (gameRef.dificuldade == 'DIFÍCIL') spawnTempo = 0.7;

    timer = Timer(spawnTempo, onTick: _spawnEnemy, repeat: true);
  }

  void _spawnEnemy() {
    double x = random.nextBool() ? -50 : gameRef.size.x + 50;
    double y = random.nextDouble() * gameRef.size.y;
    gameRef.add(Enemy(position: Vector2(x, y)));
  }

  @override
  void update(double dt) {
    super.update(dt);
    timer.update(dt);
  }
}
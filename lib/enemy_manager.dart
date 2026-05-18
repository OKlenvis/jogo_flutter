import 'dart:math';
import 'package:flame/components.dart';
import 'main.dart';
import 'enemy.dart'; 

class EnemyManager extends Component with HasGameRef<VampireGame> {
  late Timer _timerSpawn;
  late Timer _timerDificuldade;
  final Random _random = Random();

  // Configurações iniciais de tempo (em segundos)
  double _intervaloAtual = 2.0; // Começa nascendo 1 inimigo a cada 2 segundos
  final double _intervaloMinimo = 0.3; // Limite máximo para não travar o jogo (3 inimigos por segundo)

  @override
  Future<void> onLoad() async {
    // 1. Timer que cria os inimigos na tela usando o intervalo dinâmico
    _timerSpawn = Timer(
      _intervaloAtual,
      onTick: _spawnInimigo,
      repeat: true,
    );

    // 2. NOVO: Timer que aumenta a dificuldade a cada 10 segundos
    _timerDificuldade = Timer(
      10.0,
      onTick: _aumentarDificuldade,
      repeat: true,
    );
  }

  void _aumentarDificuldade() {
    if (gameRef.paused) return;

    // Reduz o tempo de espera para spawnar o próximo inimigo (nascem mais rápido)
    if (_intervaloAtual > _intervaloMinimo) {
      _intervaloAtual -= 0.15; // Diminui 0.15 segundos do tempo de espera a cada 10s
      
      // Garante que não fique menor que o limite mínimo seguro
      if (_intervaloAtual < _intervaloMinimo) {
        _intervaloAtual = _intervaloMinimo;
      }

      // Atualiza o timer de spawn com a nova velocidade acelerada
      _timerSpawn.limit = _intervaloAtual;
      
      print('Dificuldade Aumentou! Novo intervalo de spawn: ${_intervaloAtual.toStringAsFixed(2)}s');
    }
  }

  void _spawnInimigo() {
    if (gameRef.paused) return;

    Vector2 posicaoSpawn = Vector2.zero();
    int bordaAleatoria = _random.nextInt(4);
    const double margemForaDaTela = 50.0; 

    switch (bordaAleatoria) {
      case 0: // Cima
        posicaoSpawn.x = _random.nextDouble() * gameRef.size.x;
        posicaoSpawn.y = -margemForaDaTela;
        break;
      case 1: // Baixo
        posicaoSpawn.x = _random.nextDouble() * gameRef.size.x;
        posicaoSpawn.y = gameRef.size.y + margemForaDaTela;
        break;
      case 2: // Esquerda
        posicaoSpawn.x = -margemForaDaTela;
        posicaoSpawn.y = _random.nextDouble() * gameRef.size.y;
        break;
      case 3: // Direita
        posicaoSpawn.x = gameRef.size.x + margemForaDaTela;
        posicaoSpawn.y = _random.nextDouble() * gameRef.size.y;
        break;
    }

    final inimigo = Enemy(position: posicaoSpawn);
    gameRef.add(inimigo);
  }

  @override
  void update(double dt) {
    // Atualiza os dois contadores de tempo a cada frame do jogo
    _timerSpawn.update(dt);
    _timerDificuldade.update(dt);
  }
}
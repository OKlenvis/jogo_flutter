import 'dart:math';
import 'package:flame/components.dart';
import 'main.dart';
import 'enemy.dart'; // Certifique-se de que o nome do arquivo do seu inimigo está correto

class EnemyManager extends Component with HasGameRef<VampireGame> {
  late Timer _timerSpawn;
  final Random _random = Random();

  @override
  Future<void> onLoad() async {
    // Configura o temporizador para tentar spawnar um inimigo a cada 1.5 segundos
    // Você pode diminuir esse tempo se quiser mais inimigos na tela ao mesmo tempo
    _timerSpawn = Timer(
      1.5,
      onTick: _spawnInimigo,
      repeat: true,
    );
  }

  void _spawnInimigo() {
    // Evita spawnar se o jogo estiver pausado ou nos menus
    if (gameRef.paused) return;

    Vector2 posicaoSpawn = Vector2.zero();
    
    // Escolhe aleatoriamente uma das 4 bordas: 0=Cima, 1=Baixo, 2=Esquerda, 3=Direita
    int bordaAleatoria = _random.nextInt(4);

    // Margem segura para o inimigo nascer totalmente fora da visão da tela
    const double margemForaDaTela = 50.0; 

    switch (bordaAleatoria) {
      case 0: // --- BORDA DE CIMA ---
        posicaoSpawn.x = _random.nextDouble() * gameRef.size.x;
        posicaoSpawn.y = -margemForaDaTela;
        break;
        
      case 1: // --- BORDA DE BAIXO ---
        posicaoSpawn.x = _random.nextDouble() * gameRef.size.x;
        posicaoSpawn.y = gameRef.size.y + margemForaDaTela;
        break;
        
      case 2: // --- BORDA DA ESQUERDA ---
        posicaoSpawn.x = -margemForaDaTela;
        posicaoSpawn.y = _random.nextDouble() * gameRef.size.y;
        break;
        
      case 3: // --- BORDA DA DIREITA ---
        posicaoSpawn.x = gameRef.size.x + margemForaDaTela;
        posicaoSpawn.y = _random.nextDouble() * gameRef.size.y;
        break;
    }

    // Cria o inimigo passando a posição sorteada
    // (Ajuste o nome da classe 'Enemy' caso o seu tenha outro nome, ex: Inimigo)
    final inimigo = Enemy(position: posicaoSpawn);
    gameRef.add(inimigo);
  }

  @override
  void update(double dt) {
    _timerSpawn.update(dt);
  }
}
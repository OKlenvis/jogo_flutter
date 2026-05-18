import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';
import 'main.dart';

class CityMap extends PositionComponent with HasGameRef<VampireGame> {
  CityMap() : super(priority: -1); // Fica sempre atrás do jogador e inimigos

  @override
  Future<void> onLoad() async {
    size = gameRef.size;

    // --- CRIAÇÃO DAS BARREIRAS DA ÁGUA ---
    // Criamos caixas de colisão invisíveis posicionadas exatamente onde o lago está.
    // Ajuste os valores de posição (Vector2) e tamanho (Vector2) baseado no tamanho da sua tela.
    
    // Parte central/superior do lago
    add(WaterObstacle(
      position: Vector2(size.x * 0.15, size.y * 0.4),
      size: Vector2(size.x * 0.4, size.y * 0.4),
    ));

    // Braço esquerdo do rio (inferior)
    add(WaterObstacle(
      position: Vector2(0, size.y * 0.75),
      size: Vector2(size.x * 0.25, size.y * 0.25),
    ));

    // Braço direito do rio (inferior)
    add(WaterObstacle(
      position: Vector2(size.x * 0.45, size.y * 0.8),
      size: Vector2(size.x * 0.25, size.y * 0.2),
    ));
  }

  @override
  void render(Canvas canvas) {
    // 1. FUNDO DE GRAMA (Verde)
    canvas.drawRect(size.toRect(), Paint()..color = const Color(0xFF2E7D32));

    // 2. DESENHO DO CAMINHO DE TERRA (Marrom Direito e Superior)
    final terraPaint = Paint()..color = const Color(0xFF8D6E63);
    // Estrada da direita
    canvas.drawRect(Rect.fromLTWH(size.x * 0.7, 0, size.x * 0.3, size.y), terraPaint);
    // Caminho superior que conecta à esquerda
    canvas.drawRect(Rect.fromLTWH(size.x * 0.25, size.y * 0.15, size.x * 0.55, size.y * 0.12), terraPaint);
    canvas.drawRect(Rect.fromLTWH(size.x * 0.25, 0, size.x * 0.08, size.y * 0.15), terraPaint);

    // 3. DESENHO DO LAGO DE ÁGUA (Azul)
    final aguaPaint = Paint()..color = const Color(0xFF1E88E5);
    final bordaPaint = Paint()
      ..color = const Color(0xFF4E342E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Criando o formato do lago usando um Path (Desenho livre)
    final path = Path();
    path.moveTo(0, size.y * 0.85);
    path.lineTo(size.x * 0.18, size.y * 0.78);
    path.lineTo(size.x * 0.12, size.y * 0.48);
    path.lineTo(size.x * 0.22, size.y * 0.42);
    path.lineTo(size.x * 0.48, size.y * 0.42);
    path.lineTo(size.x * 0.58, size.y * 0.55);
    path.lineTo(size.x * 0.58, size.y * 0.82);
    path.lineTo(size.x * 0.70, size.y * 0.95);
    path.lineTo(size.x * 0.70, size.y);
    path.lineTo(size.x * 0.45, size.y);
    path.lineTo(size.x * 0.45, size.y * 0.88);
    path.lineTo(size.x * 0.28, size.y * 0.78);
    path.lineTo(0, size.y);
    path.close();

    canvas.drawPath(path, aguaPaint);
    canvas.drawPath(path, bordaPaint); // Desenha a bordinha de terra em volta da água

    // 4. ELEMENTOS DO CENÁRIO (Árvores, Caixas e Cerca)
    _desenharElementosDecorativos(canvas);
  }

  void _desenharElementosDecorativos(Canvas canvas) {
    final verdeEscuro = Paint()..color = const Color(0xFF1B5E20);
    final marromCerca = Paint()..color = const Color(0xFF5D4037);
    final caixaPaint = Paint()..color = const Color(0xFFA1887F);

    // Desenhar algumas Árvores (Círculos verdes)
    canvas.drawCircle(Offset(size.x * 0.1, size.y * 0.15), 25, verdeEscuro); // Topo esquerda
    canvas.drawCircle(Offset(size.x * 0.15, size.y * 0.32), 22, verdeEscuro);
    canvas.drawCircle(Offset(size.x * 0.52, size.y * 0.3), 20, verdeEscuro); // Perto da água
    canvas.drawCircle(Offset(size.x * 0.8, size.y * 0.7), 28, verdeEscuro);  // Na terra

    // Desenhar Cerca Superior (Linhas marrons)
    canvas.drawRect(Rect.fromLTWH(size.x * 0.38, size.y * 0.02, size.x * 0.25, 4), marromCerca);
    for (double i = 0.38; i <= 0.63; i += 0.05) {
      canvas.drawRect(Rect.fromLTWH(size.x * i, 0, 4, size.y * 0.06), marromCerca);
    }

    // Desenhar Caixas empilhadas perto do lago (Quadrados)
    canvas.drawRect(Rect.fromLTWH(size.x * 0.6, size.y * 0.65, 25, 25), caixaPaint);
    canvas.drawRect(Rect.fromLTWH(size.x * 0.64, size.y * 0.67, 22, 22), caixaPaint);
    canvas.drawRect(Rect.fromLTWH(size.x * 0.62, size.y * 0.62, 24, 24), caixaPaint);
  }
}

// --- CLASSE DA BARREIRA INVISÍVEL ---
class WaterObstacle extends PositionComponent with CollisionCallbacks {
  WaterObstacle({required Vector2 position, required Vector2 size})
      : super(position: position, size: size);

  @override
  Future<void> onLoad() async {
    // Adiciona o corpo físico rígido que impede a passagem
    add(RectangleHitbox()..collisionType = CollisionType.passive);
  }
}
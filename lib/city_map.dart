import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class CityMap extends PositionComponent with HasGameRef {
  @override
  Future<void> onLoad() async {
    // Define o tamanho do mapa para preencher a tela inteira
    size = gameRef.size;
    priority = -1; // Garante que o mapa fique atrás de tudo (player, inimigos)
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Cores das ruas e calçadas
    final streetPaint = Paint()..color = const Color(0xFF1C1C1E); // Asfalto escuro
    final sidewalkPaint = Paint()..color = const Color(0xFF3A3A3C); // Calçada cinza
    final linePaint = Paint()..color = const Color(0xFFF2F2F7).withOpacity(0.5); // Faixas da rua

    // Desenha a "Base" como calçada
    canvas.drawRect(size.toRect(), sidewalkPaint);

    // Configurações do layout da cidade
    double streetWidth = 150;
    double blockSize = 300;

    // Desenha as Ruas Verticais
    for (double i = 0; i < size.x; i += blockSize) {
      Rect streetRect = Rect.fromLTWH(i + (blockSize / 2) - (streetWidth / 2), 0, streetWidth, size.y);
      canvas.drawRect(streetRect, streetPaint);
      
      // Linha tracejada no meio da rua
      _drawDashedLine(canvas, Offset(i + (blockSize / 2), 0), Offset(i + (blockSize / 2), size.y), linePaint);
    }

    // Desenha as Ruas Horizontais
    for (double j = 0; j < size.y; j += blockSize) {
      Rect streetRect = Rect.fromLTWH(0, j + (blockSize / 2) - (streetWidth / 2), size.x, streetWidth);
      canvas.drawRect(streetRect, streetPaint);

      // Linha tracejada no meio da rua
      _drawDashedLine(canvas, Offset(0, j + (blockSize / 2)), Offset(size.x, j + (blockSize / 2)), linePaint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    double dashWidth = 20, dashSpace = 20;
    double distance = (end - start).distance;
    double currentDistance = 0;
    
    while (currentDistance < distance) {
      canvas.drawLine(
        start + (end - start) * (currentDistance / distance),
        start + (end - start) * ((currentDistance + dashWidth) / distance),
        paint,
      );
      currentDistance += dashWidth + dashSpace;
    }
  }
}
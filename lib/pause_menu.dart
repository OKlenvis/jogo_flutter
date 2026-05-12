import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';

class PauseMenu extends StatelessWidget {
  final VampireGame game;
  const PauseMenu({super.key, required this.game});

  TextStyle pixelStyle({double size = 20, Color color = const Color(0xFFFF5252)}) {
    return GoogleFonts.pressStart2p(
      textStyle: TextStyle(
        color: color,
        fontSize: size,
        shadows: const [
          Shadow(offset: Offset(3, 3), color: Colors.black),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.8), // Fundo um pouco mais escuro para o texto brilhar
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('PAUSADO', style: pixelStyle(size: 40)),
            
            const SizedBox(height: 40),

            // A provocação adicionada
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Vai fugir é seu COCO?\nSabia que não era capaz!',
                textAlign: TextAlign.center,
                style: pixelStyle(size: 12, color: Colors.yellow).copyWith(
                  height: 1.8, // Espaçamento entre as linhas da provocação
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Opções do Menu
            _pauseButton('RESUME', () => game.retomarJogo()),
            
            const SizedBox(height: 20),

            _pauseButton('RESTART', () => game.reiniciarJogo()),

            const SizedBox(height: 20),

            _pauseButton('QUIT', () => game.sairDoJogo()),
          ],
        ),
      ),
    );
  }

  Widget _pauseButton(String text, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        '> $text', 
        style: pixelStyle(size: 18, color: Colors.white),
      ),
    );
  }
}
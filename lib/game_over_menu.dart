import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';

class GameOverMenu extends StatelessWidget {
  final VampireGame game;
  const GameOverMenu({super.key, required this.game});

  TextStyle pixelStyle({double size = 20, Color color = Colors.red}) {
    return GoogleFonts.pressStart2p(
      textStyle: TextStyle(color: color, fontSize: size, shadows: const [Shadow(offset: Offset(2, 2), color: Colors.black)]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('GAME OVER', style: pixelStyle(size: 30)),
            const SizedBox(height: 20),
            Text('Não aguentou a pressão né seu frango!', textAlign: TextAlign.center, style: pixelStyle(size: 10, color: Colors.yellow)),
            const SizedBox(height: 40),
            Text('SCORE: ${game.score}', style: pixelStyle(size: 18, color: Colors.white)),
            Text('BEST: ${game.bestScore}', style: pixelStyle(size: 14, color: Colors.orange)),
            const SizedBox(height: 60),
            _btn('> REINICIAR', () => game.reiniciarJogo()),
            _btn('> QUIT', () => game.sairDoJogo()),
          ],
        ),
      ),
    );
  }

  Widget _btn(String text, VoidCallback onTap) {
    return TextButton(onPressed: onTap, child: Text(text, style: pixelStyle(size: 16, color: Colors.white)));
  }
}
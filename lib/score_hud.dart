import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';

class ScoreHUD extends StatelessWidget {
  final VampireGame game;
  const ScoreHUD({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 30, left: 20,
      child: StreamBuilder(
        stream: Stream.periodic(const Duration(milliseconds: 100)),
        builder: (context, snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SCORE: ${game.score}', style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 16)),
              Text('BEST: ${game.bestScore}', style: GoogleFonts.pressStart2p(color: Colors.yellow, fontSize: 10)),
            ],
          );
        },
      ),
    );
  }
}
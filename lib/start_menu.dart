import 'dart:io'; // Para fechar o processo no Desktop
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para fechar no Android/iOS
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';

class StartMenu extends StatefulWidget {
  final VampireGame game;
  const StartMenu({super.key, required this.game});

  @override
  State<StartMenu> createState() => _StartMenuState();
}

class _StartMenuState extends State<StartMenu> {
  final Color vermelhoNormal = const Color(0xFFFF5252);
  final Color vermelhoStar = const Color(0xFF8B0000);

  TextStyle pixelStyle({double size = 20, Color? color}) {
    return GoogleFonts.pressStart2p(
      textStyle: TextStyle(
        color: color ?? vermelhoNormal,
        fontSize: size,
        shadows: const [Shadow(offset: Offset(3, 3), color: Colors.black)],
      ),
    );
  }

  // Função para encerrar o aplicativo corretamente
  void _fecharAplicativo() {
    if (Platform.isAndroid || Platform.isIOS) {
      SystemNavigator.pop(); // Fecha no Mobile
    } else {
      exit(0); // Fecha no Windows, Mac ou Linux
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Adicionado Scaffold para evitar problemas de renderização
      backgroundColor: const Color(0xFF0D0B1E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('DESTROY\nVAMPIRES', 
              textAlign: TextAlign.center, 
              style: pixelStyle(size: 40)
            ),
            
            const SizedBox(height: 15),
            
            Text(
              'Salve o mundo da ameaça noturna!',
              textAlign: TextAlign.center,
              style: pixelStyle(size: 10, color: Colors.yellow),
            ),
            
            const SizedBox(height: 50),

            // Botão de Dificuldade
            _menuButton('DIFICULDADE: ${widget.game.dificuldade}', () {
              setState(() {
                if (widget.game.dificuldade == 'FÁCIL') {
                  widget.game.dificuldade = 'MÉDIO';
                } else if (widget.game.dificuldade == 'MÉDIO') {
                  widget.game.dificuldade = 'DIFÍCIL';
                } else {
                  widget.game.dificuldade = 'FÁCIL';
                }
              });
            }),

            const SizedBox(height: 15),

            // Botão QUIT GAME
            _menuButton('QUIT GAME', _fecharAplicativo),

            const SizedBox(height: 60),

            // Botão START
            GestureDetector(
              onTap: () => widget.game.iniciarJogo(),
              child: MouseRegion( // Feedback visual para o mouse
                cursor: SystemMouseCursors.click,
                child: Text('START', style: pixelStyle(size: 32, color: vermelhoStar)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuButton(String text, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap, 
      child: Text('> $text', style: pixelStyle(size: 14))
    );
  }
} // Chave corrigida aqui
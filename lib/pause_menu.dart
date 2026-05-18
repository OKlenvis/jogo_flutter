import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart';

class PauseMenu extends StatefulWidget {
  final VampireGame game;
  const PauseMenu({super.key, required this.game});

  @override
  State<PauseMenu> createState() => _PauseMenuState();
}

class _PauseMenuState extends State<PauseMenu> {
  int _opcaoSelecionada = 0; // 0: Continuar, 1: Reiniciar, 2: Sair
  final int _totalOpcoes = 3;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_tratarTecladoGlobal);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_tratarTecladoGlobal);
    super.dispose();
  }

  bool _tratarTecladoGlobal(KeyEvent event) {
    if (event is KeyDownEvent) {
      final key = event.logicalKey;
      if (key == LogicalKeyboardKey.keyW || key == LogicalKeyboardKey.keyA) {
        _moverSelecao(-1);
        return true;
      } else if (key == LogicalKeyboardKey.keyS || key == LogicalKeyboardKey.keyD) {
        _moverSelecao(1);
        return true;
      } else if (key == LogicalKeyboardKey.enter) {
        _executarAcao();
        return true;
      }
    }
    return false;
  }

  void _moverSelecao(int direcao) {
    setState(() {
      _opcaoSelecionada = (_opcaoSelecionada + direcao) % _totalOpcoes;
      if (_opcaoSelecionada < 0) _opcaoSelecionada = _totalOpcoes - 1;
    });
  }

  void _executarAcao() {
    if (_opcaoSelecionada == 0) {
      widget.game.retomarJogo();
    } else if (_opcaoSelecionada == 1) {
      widget.game.reiniciarJogo();
    } else {
      widget.game.sairDoJogo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.75),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('JOGO PAUSADO', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 50),
            _construirBotao(texto: 'CONTINUAR', index: 0, onPressed: widget.game.retomarJogo),
            const SizedBox(height: 15),
            _construirBotao(texto: 'REINICIAR PARTIDA', index: 1, onPressed: widget.game.reiniciarJogo),
            const SizedBox(height: 15),
            _construirBotao(texto: 'SAIR PARA O MENU', index: 2, onPressed: widget.game.sairDoJogo),
          ],
        ),
      ),
    );
  }

  Widget _construirBotao({required String texto, required int index, required VoidCallback onPressed}) {
    final bool estaSel = _opcaoSelecionada == index;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: estaSel ? Colors.yellowAccent : Colors.grey, width: estaSel ? 3 : 1),
        backgroundColor: estaSel ? Colors.white10 : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      ),
      onPressed: onPressed,
      child: Text(estaSel ? '> $texto <' : texto, style: TextStyle(color: estaSel ? Colors.yellowAccent : Colors.white, fontSize: 18)),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Para checar se está rodando no navegador
import 'dart:io' as io; // Alias para evitar conflitos de nomes
import 'main.dart';

class StartMenu extends StatefulWidget {
  final VampireGame game;
  const StartMenu({super.key, required this.game});

  @override
  State<StartMenu> createState() => _StartMenuState();
}

class _StartMenuState extends State<StartMenu> {
  int _opcaoSelecionada = 0; // 0: FÁCIL, 1: MÉDIO, 2: DIFÍCIL, 3: JOGAR, 4: SAIR
  final int _totalOpcoes = 5;
  
  // Controle para saber se o jogador já confirmou a dificuldade com Enter
  bool _dificuldadeConfirmada = false;

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
      int novaOpcao = (_opcaoSelecionada + direcao) % _totalOpcoes;
      if (novaOpcao < 0) novaOpcao = _totalOpcoes - 1;

      // Impede o foco de ir ao "JOGAR" se a dificuldade não foi escolhida por Enter
      if (novaOpcao == 3 && !_dificuldadeConfirmada) {
        if (direcao > 0) {
          novaOpcao = 4; // Vai direto para o Sair
        } else {
          novaOpcao = 2; // Volta para o Difícil
        }
      }

      _opcaoSelecionada = novaOpcao;
    });
  }

  // --- FUNÇÃO PARA INTERROMPER E FECHAR O JOGO DE IMEDIATO ---
  void _fecharAplicacaoAbsoluto() {
    if (kIsWeb) {
      // Se for Web, redireciona para uma página em branco e para a aba
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    } else {
      // Se for Desktop (Windows/Mac/Linux) ou Mobile, para o thread de código na hora
      io.exit(0);
    }
  }

  void _executarAcao() {
    if (_opcaoSelecionada == 0) {
      widget.game.dificuldade = 'FÁCIL';
      setState(() {
        _dificuldadeConfirmada = true;
        _opcaoSelecionada = 3; 
      });
    } else if (_opcaoSelecionada == 1) {
      widget.game.dificuldade = 'MÉDIO';
      setState(() {
        _dificuldadeConfirmada = true;
        _opcaoSelecionada = 3;
      });
    } else if (_opcaoSelecionada == 2) {
      widget.game.dificuldade = 'DIFÍCIL';
      setState(() {
        _dificuldadeConfirmada = true;
        _opcaoSelecionada = 3;
      });
    } 
    else if (_opcaoSelecionada == 3 && _dificuldadeConfirmada) {
      widget.game.iniciarJogo();
    } 
    else if (_opcaoSelecionada == 4) {
      _fecharAplicacaoAbsoluto();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0B1E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'VAMPIRE SURVIVORS',
              style: TextStyle(color: Colors.redAccent, fontSize: 45, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            const SizedBox(height: 40),
            const Text(
              'PASSO 1: SELECIONE A DIFICULDADE E APERTE ENTER:',
              style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _construirBotaoSeletor('FÁCIL', 0),
                const SizedBox(width: 10),
                _construirBotaoSeletor('MÉDIO', 1),
                const SizedBox(width: 10),
                _construirBotaoSeletor('DIFÍCIL', 2),
              ],
            ),
            const SizedBox(height: 50),
            
            _construirBotaoJogar(),
            const SizedBox(height: 20),
            
            _construirBotaoSair(),
          ],
        ),
      ),
    );
  }

  Widget _construirBotaoSeletor(String diff, int index) {
    final bool estaFocado = _opcaoSelecionada == index;
    final bool estaAtivo = widget.game.dificuldade == diff && _dificuldadeConfirmada;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: estaFocado ? Colors.yellowAccent : (estaAtivo ? Colors.redAccent : Colors.grey), 
          width: estaFocado ? 3 : 1
        ),
        backgroundColor: estaAtivo ? Colors.redAccent.withOpacity(0.2) : (estaFocado ? Colors.white10 : Colors.transparent),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      ),
      onPressed: () {
        setState(() {
          _opcaoSelecionada = index;
          widget.game.dificuldade = diff;
          _dificuldadeConfirmada = true;
        });
      },
      child: Text(
        diff,
        style: TextStyle(
          color: estaFocado ? Colors.yellowAccent : Colors.white,
          fontWeight: estaAtivo ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _construirBotaoJogar() {
    final bool estaFocado = _opcaoSelecionada == 3;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _dificuldadeConfirmada 
            ? (estaFocado ? Colors.yellowAccent : Colors.redAccent)
            : Colors.grey.shade800,
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 18),
        side: BorderSide(color: Colors.white, width: estaFocado && _dificuldadeConfirmada ? 3 : 0),
      ),
      onPressed: _dificuldadeConfirmada ? widget.game.iniciarJogo : null,
      child: Text(
        estaFocado && _dificuldadeConfirmada ? '> INICIAR JOGO <' : 'INICIAR JOGO',
        style: TextStyle(
          color: estaFocado && _dificuldadeConfirmada ? Colors.black : Colors.white54,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _construirBotaoSair() {
    final bool estaFocado = _opcaoSelecionada == 4;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: estaFocado ? Colors.yellowAccent : Colors.grey, width: estaFocado ? 3 : 1),
        backgroundColor: estaFocado ? Colors.white10 : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      ),
      onPressed: _fecharAplicacaoAbsoluto,
      child: Text(
        estaFocado ? '> SAIR DO JOGO <' : 'SAIR DO JOGO',
        style: TextStyle(
          color: estaFocado ? Colors.yellowAccent : Colors.white,
          fontSize: 16,
          fontWeight: estaFocado ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
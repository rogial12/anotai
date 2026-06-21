import 'package:flutter/material.dart';

// Estado vazio exibido quando não há notas na aba selecionada.
// TODO: extrair de home_view.dart quando o design for implementado.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(); // placeholder sem impacto visual
  }
}

import 'package:flutter/material.dart';
import '../../styles/app_theme.dart';

// Estado vazio exibido quando não há notas na aba selecionada.
class EmptyState extends StatelessWidget {
  final int tabIndex;

  const EmptyState({super.key, required this.tabIndex});

  @override
  Widget build(BuildContext context) {
    final message = tabIndex == 0
        ? 'Nenhuma nota ainda.'
        : tabIndex == 1
            ? 'Nenhuma nota arquivada.'
            : 'Lixeira vazia.';

    return Center(
      child: Text(
        message,
        style: AppTheme.notePreview.copyWith(color: AppTheme.muted),
      ),
    );
  }
}

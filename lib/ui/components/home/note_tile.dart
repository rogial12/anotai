import 'package:flutter/material.dart';
import '../../../models/nota.dart';
import '../../styles/app_theme.dart';
import '../../utils/formatters.dart';

// Linha de nota clicável: título, prévia, data, botões de favorita/restaurar/opções.
// Widget "burro" — não conhece o ViewModel. Recebe dados e dispara callbacks.
class NoteTile extends StatelessWidget {
  final Nota nota;
  final bool isLixeira;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorita;
  final VoidCallback? onRestore; // só usado na aba Lixeira
  final List<PopupMenuEntry<String>> menuItems;

  const NoteTile({
    super.key,
    required this.nota,
    required this.isLixeira,
    required this.onTap,
    required this.onToggleFavorita,
    required this.menuItems,
    this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: AppTheme.tilePadding,
      title: Text(
        nota.titulo.isEmpty ? 'Sem título' : nota.titulo,
        style: AppTheme.noteTitleList,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              nota.conteudo,
              style: AppTheme.notePreview,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatDate(nota.criadaEm),
            style: AppTheme.meta,
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botão restaurar — só na aba Lixeira
          if (isLixeira)
            IconButton(
              icon: const Icon(Icons.restore),
              color: AppTheme.faint,
              onPressed: onRestore,
              tooltip: 'Restaurar',
            ),

          // Botão favorita — nas abas Anotações e Arquivo
          if (!isLixeira)
            IconButton(
              icon: nota.isFavorita
                  ? Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.amber.withValues(alpha: 0.18),
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        color: AppTheme.amber,
                        size: 24,
                      ),
                    )
                  : const SizedBox(
                      width: 32,
                      height: 32,
                      child: Icon(Icons.star_border, size: 24),
                    ),
              color: AppTheme.faint,
              iconSize: 32,
              onPressed: onToggleFavorita,
              tooltip: nota.isFavorita
                  ? 'Remover de favoritos'
                  : 'Adicionar aos favoritos',
            ),

          // Menu de opções
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppTheme.faint),
            tooltip: 'Mais opções',
            itemBuilder: (_) => menuItems,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

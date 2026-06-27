import 'package:flutter/material.dart';
import '../../styles/app_theme.dart';

// Header da EditorView: botão voltar, título da nota, favorita, categorias, opções.
// Widget burro — não conhece o ViewModel. Recebe estado e dispara callbacks.
class EditorHeader extends StatelessWidget {
  final String title;       // título salvo da nota, ou '' quando ainda sem título
  final bool isFavorita;
  final VoidCallback onBack;
  final VoidCallback onToggleFavorita;
  final VoidCallback? onCategoriaTapped; // null = placeholder sem ação
  final List<PopupMenuEntry<String>> menuItems;

  const EditorHeader({
    super.key,
    required this.title,
    required this.isFavorita,
    required this.onBack,
    required this.onToggleFavorita,
    required this.menuItems,
    this.onCategoriaTapped,
  });

  @override
  Widget build(BuildContext context) {
    final hasTitle = title.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        border: Border(
          bottom: BorderSide(color: AppTheme.line, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Botão voltar
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppTheme.ink,
            onPressed: onBack,
            tooltip: 'Voltar',
          ),

          const SizedBox(width: 8),

          // Título da nota (salvo) — placeholder "Nova nota" quando vazio
          Expanded(
            child: Text(
              hasTitle ? title : 'Nova nota',
              style: AppTheme.sectionTitle.copyWith(
                color: hasTitle ? AppTheme.ink : AppTheme.faint,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Botão favorita (só quando há nota salva)
          if (hasTitle)
            IconButton(
              icon: Icon(
                isFavorita ? Icons.star : Icons.star_border,
              ),
              color: isFavorita ? AppTheme.amber : AppTheme.faint,
              onPressed: onToggleFavorita,
              tooltip: isFavorita
                  ? 'Remover de favoritos'
                  : 'Adicionar aos favoritos',
            ),

          // Botão de categorias (só quando há nota salva)
          if (hasTitle)
            IconButton(
              icon: const Icon(Icons.sell_outlined),
              color: AppTheme.faint,
              onPressed: onCategoriaTapped,
              tooltip: 'Categorias',
            ),

          // Menu de opções
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppTheme.faint),
            tooltip: 'Mais opções',
            itemBuilder: (_) => menuItems,
          ),

        ],
      ),
    );
  }
}

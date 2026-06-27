import 'package:flutter/material.dart';
import '../../../models/categoria.dart';
import '../../styles/app_theme.dart';

// Barra de chips de filtro exibida abaixo do SectionHeader.
// Chips fixas: "Todos" (primeira) e "Favoritas" (segunda).
// Chips de categorias do usuário ficam entre "Favoritas" e "+".
// Chip "+" abre o dialog de criação de categoria quando onAddTapped é fornecido.
class ChipBar extends StatelessWidget {
  final Set<String> selectedChips;
  final ValueChanged<String> onChipTapped;
  final List<Categoria> categorias;
  final VoidCallback? onAddTapped;
  // Long press numa chip de categoria → ação de gerenciamento (renomear/excluir)
  final ValueChanged<Categoria>? onChipLongPressed;

  const ChipBar({
    super.key,
    required this.selectedChips,
    required this.onChipTapped,
    this.categorias = const [],
    this.onAddTapped,
    this.onChipLongPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      child: Row(
        children: [
          _FilterChip(
            label: 'Todos',
            id: 'todos',
            isSelected: selectedChips.contains('todos'),
            onTap: () => onChipTapped('todos'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Favoritas',
            id: 'favoritas',
            icon: Icons.star_rounded,
            isSelected: selectedChips.contains('favoritas'),
            onTap: () => onChipTapped('favoritas'),
          ),

          // Chips de categorias personalizadas
          ...categorias.map((cat) => Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _FilterChip(
              label: cat.nome,
              id: cat.id,
              isSelected: selectedChips.contains(cat.id),
              onTap: () => onChipTapped(cat.id),
              onLongPress: onChipLongPressed != null
                  ? () => onChipLongPressed!(cat)
                  : null,
            ),
          )),

          const SizedBox(width: 8),
          _AddChip(onTap: onAddTapped),
        ],
      ),
    );
  }
}

// Chip individual de filtro com estado selecionado/não-selecionado.
class _FilterChip extends StatelessWidget {
  final String label;
  final String id;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _FilterChip({
    required this.label,
    required this.id,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          // Selecionada: fundo terracota suave + borda terracota
          // Não selecionada: fundo neutro + borda discreta
          color: isSelected ? AppTheme.accentWeak : AppTheme.paper2,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          border: Border.all(
            color: isSelected ? AppTheme.accent : AppTheme.line,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected ? AppTheme.accent : AppTheme.muted,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTheme.meta.copyWith(
                fontSize: 13,
                color: isSelected ? AppTheme.accent : AppTheme.muted,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Chip "+" — abre o dialog de criação de categoria quando onTap é fornecido.
class _AddChip extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddChip({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.paper2,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          border: Border.all(color: AppTheme.line),
        ),
        child: const Icon(Icons.add_rounded, size: 14, color: AppTheme.faint),
      ),
    );
  }
}

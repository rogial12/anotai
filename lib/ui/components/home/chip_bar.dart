import 'package:flutter/material.dart';
import '../../styles/app_theme.dart';

// Barra de chips de filtro exibida abaixo do SectionHeader.
// Chips fixas: "Todos" (sempre primeira) e "Favoritas" (sempre segunda).
// Chip "+" é placeholder por enquanto — sem ação.
// Chips personalizadas (categorias do usuário) serão adicionadas nos passos seguintes.
class ChipBar extends StatelessWidget {
  // Conjunto de IDs das chips selecionadas. IDs reservados: 'todos', 'favoritas'.
  final Set<String> selectedChips;

  // Chamado quando o usuário toca em uma chip, passando o ID dela.
  final ValueChanged<String> onChipTapped;

  const ChipBar({
    super.key,
    required this.selectedChips,
    required this.onChipTapped,
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
          const SizedBox(width: 8),
          const _AddChip(),
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

  const _FilterChip({
    required this.label,
    required this.id,
    required this.isSelected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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

// Chip "+" — placeholder sem ação. Será o hub de gerenciamento no Passo 5.
class _AddChip extends StatelessWidget {
  const _AddChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.paper2,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(color: AppTheme.line),
      ),
      child: const Icon(Icons.add_rounded, size: 14, color: AppTheme.faint),
    );
  }
}

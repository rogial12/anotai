import 'package:flutter/material.dart';
import '../../styles/app_theme.dart';

// Cabeçalho da HomeView: wordmark à esquerda, busca e configurações à direita.
// Widget burro — recebe callbacks e o controller do campo de busca.
class HomeHeader extends StatelessWidget {
  final VoidCallback onSettings;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const HomeHeader({
    super.key,
    required this.onSettings,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.card,
      padding: EdgeInsets.fromLTRB(
        AppTheme.headerPaddingH,
        AppTheme.headerPaddingV,
        AppTheme.headerPaddingH,
        AppTheme.headerPaddingBottom,
      ),
      child: Row(
        children: [
          // Wordmark
          Expanded(
            child: Text('Anotai', style: AppTheme.wordmark),
          ),

          // Campo de busca em pílula
          SizedBox(
            height: 38,
            width: 200,
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              style: AppTheme.meta.copyWith(color: AppTheme.ink),
              decoration: InputDecoration(
                hintText: 'Buscar',
                hintStyle: AppTheme.meta.copyWith(color: AppTheme.faint),
                prefixIcon: const Icon(Icons.search, size: 18, color: AppTheme.faint),
                prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                filled: true,
                fillColor: AppTheme.paper2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  borderSide: const BorderSide(color: AppTheme.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  borderSide: const BorderSide(color: AppTheme.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  borderSide: const BorderSide(color: AppTheme.accent),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Botão de configurações
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            color: AppTheme.faint,
            tooltip: 'Configurações',
            onPressed: onSettings,
          ),
        ],
      ),
    );
  }
}

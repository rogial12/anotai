import 'package:flutter/material.dart';
import '../../styles/app_theme.dart';

// Cabeçalho da HomeView: wordmark à esquerda, busca e configurações à direita.
// Widget burro — recebe apenas o callback de configurações.
class HomeHeader extends StatelessWidget {
  final VoidCallback onSettings;

  const HomeHeader({super.key, required this.onSettings});

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
          Container(
            height: 38,
            width: 200,
            decoration: BoxDecoration(
              color: AppTheme.paper2,
              borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              border: Border.all(color: AppTheme.line),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.search, size: 18, color: AppTheme.faint),
                const SizedBox(width: 8),
                Text(
                  'Buscar',
                  style: AppTheme.meta.copyWith(color: AppTheme.faint),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Botão de configurações
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            color: AppTheme.faint,
            tooltip: 'Configurações',
            onPressed: onSettings, // TODO: navegar para SettingsView
          ),
        ],
      ),
    );
  }
}

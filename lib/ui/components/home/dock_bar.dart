import 'package:flutter/material.dart';
import '../../styles/app_theme.dart';

// Barra de navegação inferior com 3 abas: Anotações, Arquivo, Lixeira.
// Usa NavigationBar do Material 3. Widget burro — recebe estado e dispara callback.
class DockBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const DockBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onTabChanged,
      backgroundColor: AppTheme.card,
      indicatorColor: AppTheme.accentWeak,
      surfaceTintColor: Colors.transparent,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.notes_outlined),
          selectedIcon: Icon(Icons.notes, color: AppTheme.accent),
          label: 'Anotações',
        ),
        NavigationDestination(
          icon: Icon(Icons.archive_outlined),
          selectedIcon: Icon(Icons.archive, color: AppTheme.accent),
          label: 'Arquivo',
        ),
        NavigationDestination(
          icon: Icon(Icons.delete_outline),
          selectedIcon: Icon(Icons.delete, color: AppTheme.accent),
          label: 'Lixeira',
        ),
      ],
    );
  }
}

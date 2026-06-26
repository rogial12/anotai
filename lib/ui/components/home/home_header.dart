import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../styles/app_theme.dart';

// Cabeçalho da HomeView: gerencia o modo normal (wordmark + ícones) e o modo busca.
// StatefulWidget porque mantém _isSearching como estado interno de UI.
class HomeHeader extends StatefulWidget {
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
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  bool _isSearching = false;
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchFocus.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _isSearching = true);
    // Aguarda o próximo frame para o TextField existir antes de pedir foco
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  void _closeSearch() {
    widget.searchController.clear();
    widget.onSearchChanged('');
    _searchFocus.unfocus();
    setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Wordmark: 3% da largura da tela, travado entre 27px e 35px
    final wordmarkSize = (screenWidth * 0.03).clamp(27.0, 35.0);

    return Container(
      color: AppTheme.card,
      padding: EdgeInsets.fromLTRB(
        AppTheme.headerPaddingH,
        AppTheme.headerPaddingV,
        AppTheme.headerPaddingH,
        AppTheme.headerPaddingBottom,
      ),
      child: _isSearching ? _buildSearchMode() : _buildNormalMode(wordmarkSize),
    );
  }

  Widget _buildNormalMode(double wordmarkSize) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Anotai',
            style: GoogleFonts.bricolageGrotesque(
              fontSize: wordmarkSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.025 * wordmarkSize,
              height: 1,
              color: AppTheme.ink,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.search),
          color: AppTheme.faint,
          tooltip: 'Buscar',
          onPressed: _openSearch,
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          color: AppTheme.faint,
          tooltip: 'Configurações',
          onPressed: widget.onSettings,
        ),
      ],
    );
  }

  Widget _buildSearchMode() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 38,
            child: TextField(
              controller: widget.searchController,
              focusNode: _searchFocus,
              onChanged: widget.onSearchChanged,
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
        ),
        IconButton(
          icon: const Icon(Icons.close),
          color: AppTheme.faint,
          tooltip: 'Fechar busca',
          onPressed: _closeSearch,
        ),
      ],
    );
  }
}

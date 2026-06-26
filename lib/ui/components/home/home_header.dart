import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../styles/app_theme.dart';

// StatefulWidget porque precisa lembrar se está no modo busca ou não
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

  // Cria o State que vai guardar a memória do widget
  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  // Memória interna: false = modo normal, true = modo busca
  bool _isSearching = false;

  // Objeto que representa o foco do teclado no campo de busca
  final FocusNode _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchFocus.dispose(); // libera o FocusNode da memória quando o widget some
    super.dispose();
  }

  void _openSearch() {
    setState(() => _isSearching = true); // troca para modo busca e reconstrói o widget
    // Aguarda o próximo frame (o TextField precisa existir antes de receber foco)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus(); // abre o teclado
    });
  }

  void _closeSearch() {
    widget.searchController.clear();  // apaga o texto do campo
    widget.onSearchChanged('');       // avisa o ViewModel que a query voltou a ser vazia
    _searchFocus.unfocus();           // fecha o teclado
    setState(() => _isSearching = false); // volta ao modo normal e reconstrói
  }

  @override
  Widget build(BuildContext context) {
    // Largura atual da tela em pixels lógicos (dp)
    final screenWidth = MediaQuery.of(context).size.width;
    // Tamanho do wordmark: 3% da largura, nunca menor que 27 nem maior que 35
    final wordmarkSize = (screenWidth * 0.03).clamp(27.0, 35.0);

    return Container(
      color: AppTheme.card,
      padding: EdgeInsets.fromLTRB(
        AppTheme.headerPaddingH,
        AppTheme.headerPaddingV,
        AppTheme.headerPaddingH,
        AppTheme.headerPaddingBottom,
      ),
      // Escolhe qual modo renderizar baseado em _isSearching
      child: _isSearching ? _buildSearchMode() : _buildNormalMode(wordmarkSize),
    );
  }

  // Modo normal: wordmark + botão lupa + botão configurações
  Widget _buildNormalMode(double wordmarkSize) {
    return Row(
      children: [
        Expanded( // ocupa todo o espaço horizontal disponível
          child: Text(
            'Anotai',
            style: GoogleFonts.bricolageGrotesque(
              fontSize: wordmarkSize,              // tamanho dinâmico calculado acima
              fontWeight: FontWeight.w800,
              letterSpacing: -0.025 * wordmarkSize, // espaçamento proporcional ao tamanho
              height: 1,
              color: AppTheme.ink,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.search),
          color: AppTheme.faint,
          tooltip: 'Buscar',
          onPressed: _openSearch, // abre o modo busca
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          color: AppTheme.faint,
          tooltip: 'Configurações',
          onPressed: widget.onSettings, // acessa parâmetro do StatefulWidget via widget.
        ),
      ],
    );
  }

  // Modo busca: campo de texto expandido + botão fechar
  Widget _buildSearchMode() {
    return Row(
      children: [
        Expanded( // campo ocupa todo o espaço antes do botão fechar
          child: SizedBox(
            height: 38, // altura fixa para o campo de busca
            child: TextField(
              controller: widget.searchController, // controller vem da HomeView
              focusNode: _searchFocus,             // conecta ao foco gerenciado aqui
              onChanged: widget.onSearchChanged,   // notifica o ViewModel a cada tecla
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
          onPressed: _closeSearch, // fecha o modo busca
        ),
      ],
    );
  }
}

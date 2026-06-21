import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppTheme: tema centralizado do Anotai seguindo o design handoff do Claude Design
///
/// Direção visual: editorial / papel (fundo creme quente), cor de destaque âmbar-terroso (terracota),
/// tipografia sans-serif limpa (Hanken Grotesk, Bricolage Grotesque), leitura confortável.
///
/// Design tokens baseados em oklch, convertidos para HEX aproximado.

class AppTheme {
  // Cores (design tokens)
  static const Color paper = Color(0xFFFAF6EF); // --paper: fundo principal
  static const Color paper2 = Color(0xFFF2ECE1); // --paper2: hover de linhas/botões
  static const Color card = Color(0xFFFFFDFA); // --card: cartões, menus
  static const Color ink = Color(0xFF3A352D); // --ink: texto principal
  static const Color muted = Color(0xFF7A7367); // --muted: texto secundário
  static const Color faint = Color(0xFFA39B8D); // --faint: texto terciário
  static const Color line = Color(0xFFE5DFD4); // --line: bordas principais
  static const Color line2 = Color(0xFFECE7DD); // --line2: divisores suaves
  static const Color accent = Color(0xFFB5552F); // --accent: terracota (destaque)
  static const Color accentPress = Color(0xFF9E4727); // --accent-press: hover do destaque
  static const Color accentWeak = Color(0xFFF3E4D6); // --accent-weak: fundo suave
  static const Color amber = Color(0xFFE0A23C); // --amber: estrela de favorito
  static const Color danger = Color(0xFFC0432F); // --danger: ações destrutivas
  static const Color dangerWeak = Color(0xFFF8E2DC); // --danger-weak: hover destrutivo
  static const Color saved = Color(0xFF3F9A6B); // Ponto "Salvo" (verde)
  static const Color textOnAccent = Color(0xFFFFFFFF); // Texto sobre destaque (branco)

  /// ThemeData para Material 3
  static ThemeData get lightTheme {
    return ThemeData(
      // Esquema de cores
      colorScheme: ColorScheme.light(
        primary: accent, // Terracota
        onPrimary: textOnAccent,
        primaryContainer: accentWeak,
        onPrimaryContainer: accent,
        secondary: muted,
        tertiary: faint,
        error: danger,
        errorContainer: dangerWeak,
        surface: card,
        onSurface: ink,
        surfaceTint: accent,
      ),

      // Tipografia base
      useMaterial3: true,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: card,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.bricolageGrotesque(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.025,
          color: ink,
        ),
      ),

      // Bottom Navigation Bar (dock)
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: accent,
        unselectedItemColor: muted,
        selectedLabelStyle: GoogleFonts.hankenGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.hankenGrotesk(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        elevation: 12,
        type: BottomNavigationBarType.fixed,
      ),

      // Scaffold
      scaffoldBackgroundColor: paper,

      // Cards
      cardColor: card,
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusListItem),
        ),
      ),

      // TextField
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusPrimaryButton),
          borderSide: const BorderSide(color: line, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusPrimaryButton),
          borderSide: const BorderSide(color: line, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusPrimaryButton),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        hintStyle: GoogleFonts.hankenGrotesk(fontSize: 16, color: faint),
        labelStyle: GoogleFonts.hankenGrotesk(color: muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: textOnAccent,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPrimaryButton),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.hankenGrotesk(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusIconButton),
          ),
          textStyle: GoogleFonts.hankenGrotesk(
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusIconButton),
          ),
          iconSize: 20,
        ),
      ),

      // PopupMenuButton
      popupMenuTheme: PopupMenuThemeData(
        color: card,
        textStyle: GoogleFonts.hankenGrotesk(fontSize: 14.5, color: ink),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMenu),
        ),
        elevation: 12,
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        titleTextStyle: GoogleFonts.bricolageGrotesque(
          fontSize: 16.5,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.005,
          color: ink,
        ),
        subtitleTextStyle: GoogleFonts.hankenGrotesk(
          fontSize: 14.5,
          fontWeight: FontWeight.w400,
          color: muted,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusListItem),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusListItem),
        ),
        titleTextStyle: GoogleFonts.bricolageGrotesque(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: GoogleFonts.hankenGrotesk(
          fontSize: 14.5,
          color: textOnAccent,
        ),
        actionTextColor: amber,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusPrimaryButton),
        ),
      ),
    );
  }

  /// Tipografia conforme handoff do Claude Design
  /// Usa GoogleFonts para garantir o carregamento correto das fontes.
  /// São métodos (não const) porque GoogleFonts retorna instâncias em runtime.

  // Wordmark "Anotai" - Bricolage 800, clamp(27px,3vw,35px), -0.025em, height 1
  static TextStyle wordmark({double? fontSize}) =>
      GoogleFonts.bricolageGrotesque(
        fontSize: fontSize ?? 27,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.025,
        color: ink,
        height: 1,
      );

  // Saudação "Olá, ..." - Hanken 14.5px, 400
  static TextStyle get greeting => GoogleFonts.hankenGrotesk(
        fontSize: 14.5,
        fontWeight: FontWeight.w400,
        color: muted,
      );

  // Título de seção (h2) - Bricolage 20px, 700, -0.01em
  static TextStyle get sectionTitle => GoogleFonts.bricolageGrotesque(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.01,
        color: ink,
      );

  // Contador de seção - Hanken 13.5px, 400, tabular-nums
  static TextStyle get sectionCounter => GoogleFonts.hankenGrotesk(
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        color: faint,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  // Título da nota (lista) - Bricolage 16.5px, 600, -0.005em
  static TextStyle get noteTitle => GoogleFonts.bricolageGrotesque(
        fontSize: 16.5,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.005,
        color: ink,
      );

  // Prévia da nota (lista) - Hanken 14.5px, 400, height 1.5
  static TextStyle get notePreview => GoogleFonts.hankenGrotesk(
        fontSize: 14.5,
        fontWeight: FontWeight.w400,
        color: muted,
        height: 1.5,
      );

  // Data / meta - Hanken 12.5px, 400, tabular-nums
  static TextStyle get dateMeta => GoogleFonts.hankenGrotesk(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        color: faint,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  // Item de menu - Hanken 14.5px, 400
  static TextStyle get menuItem => GoogleFonts.hankenGrotesk(
        fontSize: 14.5,
        fontWeight: FontWeight.w400,
        color: ink,
      );

  // Label do dock (inativo) - Hanken 14px, 500
  static TextStyle get dockLabelInactive => GoogleFonts.hankenGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: muted,
      );

  // Label do dock (ativo) - Hanken 14px, 600
  static TextStyle get dockLabelActive => GoogleFonts.hankenGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: accent,
      );

  // Título no editor - Bricolage 700, clamp(25px,3.2vw,33px), -0.02em, height 1.2
  static TextStyle editorTitle({double? fontSize}) =>
      GoogleFonts.bricolageGrotesque(
        fontSize: fontSize ?? 25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02,
        color: ink,
        height: 1.2,
      );

  // Corpo no editor (sans) - Hanken 18px, 400, height 1.78
  static TextStyle get editorBodySans => GoogleFonts.hankenGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: ink,
        height: 1.78,
      );

  // Corpo no editor (serif) - Newsreader 19px, 400, height 1.78
  static TextStyle get editorBodySerif => GoogleFonts.newsreader(
        fontSize: 19,
        fontWeight: FontWeight.w400,
        color: ink,
        height: 1.78,
      );

  /// Border Radius conforme handoff
  // Botões primários
  static const double radiusPrimaryButton = 11;
  // Ícones-botão
  static const double radiusIconButton = 9;
  // Linhas da lista
  static const double radiusListItem = 13;
  // Menus/popovers
  static const double radiusMenu = 13;
  // Dock
  static const double radiusDock = 18;
  // Chip do dock
  static const double radiusDockChip = 13;
  // Busca e avatar (pílula)
  static const double radiusPill = 999;

  /// Sombras conforme handoff (aproximação de oklch para RGBA)
  // Botão primário: 0 1px 2px oklch(0.5 0.12 48 / .25)
  static const BoxShadow shadowPrimaryButton = BoxShadow(
    color: Color.fromARGB(64, 181, 85, 47), // oklch(0.5 0.12 48) ≈ terracota escuro, 25% alpha
    blurRadius: 2,
    offset: Offset(0, 1),
  );

  // Menu de linha: 0 12px 34px oklch(0.4 0.03 60 / .16), 0 2px 6px oklch(0.4 0.03 60 / .08)
  static const List<BoxShadow> shadowRowMenu = [
    BoxShadow(
      color: Color.fromARGB(41, 80, 60, 48), // oklch(0.4 0.03 60), 16% alpha
      blurRadius: 34,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color.fromARGB(20, 80, 60, 48), // oklch(0.4 0.03 60), 8% alpha
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  // Popover do editor: 0 14px 36px oklch(0.4 0.03 60 / .18)
  static const List<BoxShadow> shadowPopover = [
    BoxShadow(
      color: Color.fromARGB(46, 80, 60, 48), // oklch(0.4 0.03 60), 18% alpha
      blurRadius: 36,
      offset: Offset(0, 14),
    ),
  ];

  // Dock: 0 10px 30px oklch(0.4 0.03 60 / .14), 0 2px 6px oklch(0.4 0.03 60 / .07)
  static const List<BoxShadow> shadowDock = [
    BoxShadow(
      color: Color.fromARGB(36, 80, 60, 48), // oklch(0.4 0.03 60), 14% alpha
      blurRadius: 30,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color.fromARGB(18, 80, 60, 48), // oklch(0.4 0.03 60), 7% alpha
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  /// Espaçamentos-chave
  // Header: clamp(22px,3vw,34px) clamp(20px,4vw,48px) 16px
  // (usa _clampPadding na view para cálculos dinâmicos)
  static const double paddingHeaderTop = 22;
  static const double paddingHeaderHorizontal = 20;
  static const double paddingHeaderBottom = 16;

  // Linha da lista: 17px 14px (vertical x horizontal)
  static const double paddingListItemVertical = 17;
  static const double paddingListItemHorizontal = 14;

  // Corpo do editor: clamp(28px,5vw,56px) clamp(20px,5vw,40px) 80px
  // (usa _clampPadding na view)
  static const double paddingEditorVertical = 28;
  static const double paddingEditorHorizontal = 20;
  static const double paddingEditorBottom = 80;

  /// Larguras máximas de conteúdo
  static const double maxWidthListContent = 920;
  static const double maxWidthEditorContent = 720;

  /// Áreas de toque (min hit target)
  static const double minTouchTargetSize = 36;
  static const double recommendedTouchTargetSize = 44; // Para mobile
}

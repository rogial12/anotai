import 'package:flutter/material.dart';

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
        titleTextStyle: const TextStyle(
          fontFamily: 'Bricolage Grotesque',
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
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Hanken Grotesk',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Hanken Grotesk',
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
          borderRadius: BorderRadius.circular(13),
        ),
      ),

      // TextField
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: line, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: line, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Hanken Grotesk',
          fontSize: 16,
          color: faint,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Hanken Grotesk',
          color: muted,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: textOnAccent,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontFamily: 'Hanken Grotesk',
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Hanken Grotesk',
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
          iconSize: 20,
        ),
      ),

      // PopupMenuButton
      popupMenuTheme: PopupMenuThemeData(
        color: card,
        textStyle: const TextStyle(
          fontFamily: 'Hanken Grotesk',
          fontSize: 14.5,
          color: ink,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        elevation: 12,
      ),

      // ListTile
      listTileTheme: ListTileThemeData(
        titleTextStyle: const TextStyle(
          fontFamily: 'Bricolage Grotesque',
          fontSize: 16.5,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.005,
          color: ink,
        ),
        subtitleTextStyle: const TextStyle(
          fontFamily: 'Hanken Grotesk',
          fontSize: 14.5,
          fontWeight: FontWeight.w400,
          color: muted,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'Bricolage Grotesque',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: const TextStyle(
          fontFamily: 'Hanken Grotesk',
          fontSize: 14.5,
          color: textOnAccent,
        ),
        actionTextColor: amber,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11),
        ),
      ),
    );
  }

  /// Tipografia customizada
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'Bricolage Grotesque',
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.025,
    color: ink,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'Bricolage Grotesque',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.01,
    color: ink,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Hanken Grotesk',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: ink,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Hanken Grotesk',
    fontSize: 14.5,
    fontWeight: FontWeight.w400,
    color: ink,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Hanken Grotesk',
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    color: faint,
  );

  /// Sombras
  static const BoxShadow shadowSmall = BoxShadow(
    color: Color.fromARGB(64, 80, 60, 48),
    blurRadius: 2,
    offset: Offset(0, 1),
  );

  static const List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Color.fromARGB(41, 80, 60, 48),
      blurRadius: 34,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color.fromARGB(20, 80, 60, 48),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowLarge = [
    BoxShadow(
      color: Color.fromARGB(46, 80, 60, 48),
      blurRadius: 36,
      offset: Offset(0, 14),
    ),
    BoxShadow(
      color: Color.fromARGB(20, 80, 60, 48),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];
}

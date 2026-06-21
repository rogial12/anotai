import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Tokens de design centralizados: cores, tipografia, raios, sombras, espaçamentos.
// Nenhuma view ou componente deve ter valores hardcoded — tudo vem daqui.
class AppTheme {
  // ---------------------------------------------------------------------------
  // Cores
  // Fonte: docs/design_handoff_anotai/README.md — seção "Design Tokens / Cores"
  // Os valores HEX são aproximações dos originais em oklch.
  // ---------------------------------------------------------------------------

  // Fundos
  static const Color paper      = Color(0xFFFAF6EF); // fundo principal (papel creme)
  static const Color paper2     = Color(0xFFF2ECE1); // hover de linhas/botões neutros
  static const Color card       = Color(0xFFFFFDFA); // cartões, menus, dock, inputs

  // Texto
  static const Color ink        = Color(0xFF3A352D); // texto principal (quase-preto quente)
  static const Color muted      = Color(0xFF7A7367); // texto secundário / prévia
  static const Color faint      = Color(0xFFA39B8D); // datas, ícones inativos

  // Bordas
  static const Color line       = Color(0xFFE5DFD4); // bordas e divisores
  static const Color line2      = Color(0xFFECE7DD); // divisores internos (mais suaves)

  // Destaque (terracota)
  static const Color accent      = Color(0xFFB5552F); // botões primários, itens ativos
  static const Color accentPress = Color(0xFF9E4727); // hover/active do destaque
  static const Color accentWeak  = Color(0xFFF3E4D6); // fundo suave (chip ativo, avatar)
  static const Color accentFg    = Color(0xFFFFFFFF); // texto sobre fundo accent

  // Semânticas
  static const Color amber      = Color(0xFFE0A23C); // estrela de favorito
  static const Color danger     = Color(0xFFC0432F); // ações destrutivas
  static const Color dangerWeak = Color(0xFFF8E2DC); // hover de itens destrutivos
  static const Color saved      = Color(0xFF3F9A6B); // indicador "Salvo" (verde)

  // ---------------------------------------------------------------------------
  // Tipografia
  // Fonte: docs/design_handoff_anotai/README.md — seção "Tipografia"
  // Bricolage Grotesque: títulos, wordmark, nome da nota na lista
  // Hanken Grotesk: interface, corpo, datas, labels
  // Tamanhos com clamp() no handoff recebem valor fixo intermediário aqui;
  // o ajuste responsivo será feito no componente via MediaQuery.
  // ---------------------------------------------------------------------------

  // Wordmark "Anotai" — clamp(27px,3vw,35px) → fixo 31px até implementar clamp
  static TextStyle get wordmark => GoogleFonts.bricolageGrotesque(
        fontSize: 31,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.025 * 31,
        height: 1,
        color: AppTheme.ink,
      );

  // Saudação "Olá, …"
  static TextStyle get greeting => GoogleFonts.hankenGrotesk(
        fontSize: 14.5,
        fontWeight: FontWeight.w400,
        color: AppTheme.ink,
      );

  // Título de seção (h2): "Anotações", "Arquivo", "Lixeira"
  static TextStyle get sectionTitle => GoogleFonts.bricolageGrotesque(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.01 * 20,
        color: AppTheme.ink,
      );

  // Contador de seção: "5 notas"
  static TextStyle get sectionCount => GoogleFonts.hankenGrotesk(
        fontSize: 13.5,
        fontWeight: FontWeight.w400,
        color: AppTheme.muted,
      );

  // Título da nota na lista
  static TextStyle get noteTitleList => GoogleFonts.bricolageGrotesque(
        fontSize: 16.5,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.005 * 16.5,
        color: AppTheme.ink,
      );

  // Prévia do conteúdo na lista
  static TextStyle get notePreview => GoogleFonts.hankenGrotesk(
        fontSize: 14.5,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppTheme.muted,
      );

  // Data / meta (listas e editor)
  static TextStyle get meta => GoogleFonts.hankenGrotesk(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        color: AppTheme.faint,
      );

  // Item de menu (PopupMenuItem)
  static TextStyle get menuItem => GoogleFonts.hankenGrotesk(
        fontSize: 14.5,
        fontWeight: FontWeight.w400,
        color: AppTheme.ink,
      );

  // Label do dock — inativo
  static TextStyle get dockLabel => GoogleFonts.hankenGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppTheme.muted,
      );

  // Label do dock — ativo
  static TextStyle get dockLabelActive => GoogleFonts.hankenGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppTheme.accent,
      );

  // Título no editor — clamp(25px,3.2vw,33px) → fixo 29px até implementar clamp
  static TextStyle get editorTitle => GoogleFonts.bricolageGrotesque(
        fontSize: 29,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 29,
        height: 1.2,
        color: AppTheme.ink,
      );

  // Corpo no editor (sans-serif)
  static TextStyle get editorBody => GoogleFonts.hankenGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.78,
        color: AppTheme.ink,
      );

  // Corpo no editor (serif — modo leitura opcional)
  static TextStyle get editorBodySerif => GoogleFonts.newsreader(
        fontSize: 19,
        fontWeight: FontWeight.w400,
        height: 1.78,
        color: AppTheme.ink,
      );

  // TODO: adicionar tokens de border radius
  // TODO: adicionar tokens de sombra
  // TODO: adicionar tokens de espaçamento
}

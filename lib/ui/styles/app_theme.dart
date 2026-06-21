import 'package:flutter/material.dart';

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

  // TODO: adicionar tokens de tipografia (GoogleFonts)
  // TODO: adicionar tokens de border radius
  // TODO: adicionar tokens de sombra
  // TODO: adicionar tokens de espaçamento
}

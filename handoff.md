# Handoff de sessão — Anotai

## Contexto pedagógico (LEIA PRIMEIRO)

Este projeto é um exercício de aprendizagem. O desenvolvedor (Igor) está retomando programação após um período afastado. As regras abaixo são obrigatórias:

- **NUNCA aplique mudanças sem consentimento explícito.** Apresente o plano e espere aprovação.
- **Explique o raciocínio antes de implementar.** Por que essa abordagem? Quais alternativas?
- **Não decida arquitetura sozinho.** Apresente opções com prós/contras.
- **Vá no ritmo do usuário.** Tarefas pequenas e incrementais.
- **A cada mudança arquitetural relevante, pergunte sobre atualização da documentação** (README.md e docs/diagrama.md) antes de seguir.

---

## O projeto

**Anotai** — app de anotações offline-first construído com Flutter/Dart.

- Plataforma atual: Web (Flutter web, roda no Chrome via `flutter run -d chrome`)
- Plataforma futura: Android
- Sincronização entre dispositivos: planejada para fase posterior

**Stack:** Flutter · Dart · Hive (banco local) · Provider (estado)

---

## Arquitetura

Padrão MVVM. Estrutura atual de `lib/`:

```
lib/
├── models/
│   └── nota.dart
├── repositories/
│   ├── nota_repository.dart         (interface)
│   └── local_nota_repository.dart   (implementação Hive)
├── viewmodels/
│   └── nota_viewmodel.dart
├── ui/
│   ├── views/
│   │   ├── home_view.dart           (tela principal — 3 abas)
│   │   └── editor_view.dart         (criação/edição de nota)
│   ├── components/
│   │   ├── home/
│   │   │   ├── home_header.dart     (placeholder)
│   │   │   ├── dock_bar.dart        (placeholder)
│   │   │   ├── note_tile.dart       (placeholder)
│   │   │   ├── section_header.dart  (placeholder)
│   │   │   └── empty_state.dart     (placeholder)
│   │   └── editor/
│   │       ├── editor_header.dart   (placeholder)
│   │       └── info_popover.dart    (placeholder)
│   ├── styles/
│   │   └── app_theme.dart           (COMPLETO — ver abaixo)
│   └── utils/
│       └── formatters.dart          (placeholder)
└── main.dart
```

---

## Estado atual do AppTheme

`lib/ui/styles/app_theme.dart` está **completo** com todos os tokens de design:

- **16 cores** — fundos (paper, paper2, card), texto (ink, muted, faint), bordas (line, line2), destaque terracota (accent, accentPress, accentWeak, accentFg), semânticas (amber, danger, dangerWeak, saved)
- **13 estilos de tipografia** — via `google_fonts` (Bricolage Grotesque + Hanken Grotesk + Newsreader): wordmark, greeting, sectionTitle, sectionCount, noteTitleList, notePreview, meta, menuItem, dockLabel, dockLabelActive, editorTitle, editorBody, editorBodySerif
- **7 valores de border radius** — radiusButton (11), radiusIcon (9), radiusTile (13), radiusMenu (13), radiusDock (18), radiusDockChip (13), radiusPill (999)
- **4 listas de sombras** — shadowButton, shadowMenu, shadowPopover, shadowDock
- **Espaçamentos** — listMaxWidth (920), editorMaxWidth (720), headerPaddingV/H/Bottom, tilePadding, editorPaddingTop/H/Bottom, listBottomPadding (130)

O `main.dart` já aplica as cores globalmente via `ThemeData` (scaffoldBackgroundColor, colorScheme, appBarTheme). As fontes ainda não aparecem — isso é esperado e intencional.

---

## Por que as fontes ainda não aparecem

O ThemeData aplica cores em cascata, mas não fontes. Cada componente precisa referenciar explicitamente o estilo do AppTheme (ex: `style: AppTheme.noteTitleList`). Isso acontecerá quando os componentes forem implementados. Os valores já estão centralizados no AppTheme — os componentes só apontarão para lá.

---

## O que está implementado (funcionalidades)

- Criação e edição de notas (título + conteúdo)
- Salvamento automático com debounce de 5 segundos
- Três abas: Anotações, Arquivo, Lixeira
- Soft delete (move para lixeira com SnackBar + Undo de 4s)
- Hard delete (Dialog de confirmação na lixeira)
- Arquivamento / desarquivamento
- Favoritar notas (estrela)
- Menu de contexto dinâmico por aba
- Botão de informações (data de criação)

---

## Próximos passos (UI — em ordem)

Os componentes são **placeholders** — existem como arquivos mas retornam `SizedBox.shrink()`. A implementação deve ser feita **um por vez**, **com commit por componente**:

1. **`EmptyState`** — mais simples, só texto estilizado
2. **`SectionHeader`** — título da seção + contador
3. **`NoteTile`** — linha de nota com título, prévia, data, botões
4. **`DockBar`** — substitui o BottomNavigationBar atual
5. **`HomeHeader`** — wordmark + saudação + busca + avatar + botão "Nova nota"
6. **`EditorHeader`** — header sticky com status de salvamento e botões
7. **`InfoPopover`** — popover de informações da nota

A referência de design está em `docs/design_handoff_anotai/README.md`.

---

## Referência de design (resumo)

Direção visual: editorial/papel. Fundo creme quente, destaque terracota, tipografia sans-serif limpa.

- Fundo principal: `#FAF6EF` (AppTheme.paper)
- Destaque: `#B5552F` (AppTheme.accent)
- Texto principal: `#3A352D` (AppTheme.ink)
- Títulos: Bricolage Grotesque
- Interface/corpo: Hanken Grotesk

Arquivo completo: `docs/design_handoff_anotai/README.md`

---

## Regras de commit

- Commits direto na `main` durante o MVP
- Um commit por mudança significativa (não acumular)
- Mensagens no formato: `feat(escopo): descrição curta`
- Exemplos usados nesta sessão:
  - `refactor: reorganiza lib/ em camadas ui/ e domínio separados`
  - `feat(styles): adiciona tokens de cor ao AppTheme`
  - `feat(theme): aplica AppTheme ao ThemeData global do app`

---

## Documentação do projeto

- `README.md` — visão geral, arquitetura, estrutura, diagrama de classes (Mermaid)
- `docs/diagrama.md` — diagrama de classes dedicado (mesmo conteúdo do README)
- `docs/design_handoff_anotai/README.md` — especificação visual completa (fonte de verdade do design)
- `CLAUDE.md` — instruções do projeto para o assistente (leia antes de qualquer coisa)

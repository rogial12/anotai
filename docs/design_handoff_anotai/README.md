# Handoff: Anotai — App de Anotações (HomeView + EditorView)

## Visão geral
Redesenho da interface do **Anotai**, um app de anotações com foco no conteúdo em
texto. Este pacote cobre duas telas e seus menus:

1. **HomeView** — lista de notas com 3 seções (Anotações, Arquivo, Lixeira), busca,
   favoritar e menu de opções contextual por seção.
2. **EditorView** — criação/edição de nota com título, corpo, salvamento automático
   (debounce), favoritar, popover de Informações e menu de opções contextual.

Direção visual: **editorial / papel** (fundo creme quente), cor de destaque
**âmbar-terroso (terracota)**, tipografia sans-serif limpa, leitura confortável.
PC-first, mas com layout fluido preparado para redimensionar até mobile.

---

## Sobre os arquivos deste pacote
Os arquivos aqui são **referências de design feitas em HTML** — um protótipo que
demonstra o visual e o comportamento pretendidos, **não código de produção para
copiar diretamente**.

- `Anotai.dc.html` — protótipo navegável (HomeView + EditorView + menus). Roda num
  runtime próprio (`support.js`, não incluso) e usa uma sintaxe de template
  (`{{ }}`, `<sc-if>`, `<sc-for>`). **Não importe esse runtime no seu projeto.** Use
  o arquivo como fonte de verdade para layout, medidas, cores e copy. A lógica em
  `class Component extends DCLogic` é JavaScript comum e serve de referência direta
  para a sua implementação de estado.
- `spec_original_v1.md` — especificação funcional original do app (fluxos, regras de
  cada menu, comportamento de salvamento). É a fonte de verdade do **comportamento**.

**Tarefa:** recriar estas telas no ambiente já existente do repositório (React, Vue,
Flutter, etc.), usando os padrões, componentes e biblioteca de ícones que o projeto
já adota. O app original é **Flutter** (a spec cita `ListTile`, `PopupMenu`,
`BottomNavigationBar`, `Hive`); se o alvo continuar sendo Flutter, traduza os tokens
abaixo para `ThemeData`/widgets.

## Fidelidade
**Alta fidelidade (hi-fi).** Cores, tipografia, espaçamentos e interações são finais.
Recrie a UI fielmente usando as bibliotecas/padrões do seu codebase. As cores estão
em `oklch`; há equivalentes aproximados em HEX na seção Design Tokens para ambientes
que não suportam `oklch`.

---

## Design Tokens

### Cores (CSS custom properties → HEX aproximado)
| Token | oklch | HEX aprox. | Uso |
|---|---|---|---|
| `--paper` | `oklch(0.975 0.012 78)` | `#FAF6EF` | Fundo principal (papel) |
| `--paper2` | `oklch(0.955 0.016 76)` | `#F2ECE1` | Hover de linhas/botões neutros |
| `--card` | `oklch(0.995 0.005 85)` | `#FFFDFA` | Cartões, menus, dock, inputs |
| `--ink` | `oklch(0.28 0.022 62)` | `#3A352D` | Texto principal (quase-preto quente) |
| `--muted` | `oklch(0.53 0.022 66)` | `#7A7367` | Texto secundário / prévia |
| `--faint` | `oklch(0.66 0.018 68)` | `#A39B8D` | Texto terciário / datas / ícones inativos |
| `--line` | `oklch(0.9 0.013 76)` | `#E5DFD4` | Bordas e divisores |
| `--line2` | `oklch(0.93 0.01 76)` | `#ECE7DD` | Divisores internos (mais suaves) |
| `--accent` | `oklch(0.56 0.13 48)` | `#B5552F` | Destaque (terracota): botões primários, ativos |
| `--accent-press` | `oklch(0.5 0.13 46)` | `#9E4727` | Estado :hover/:active do destaque |
| `--accent-weak` | `oklch(0.93 0.04 62)` | `#F3E4D6` | Fundo suave do destaque (chip ativo, avatar) |
| `--amber` | `oklch(0.76 0.135 73)` | `#E0A23C` | Estrela de favorito |
| `--danger` | `oklch(0.55 0.16 28)` | `#C0432F` | Ações destrutivas (lixeira, excluir) |
| `--danger-weak` | `oklch(0.94 0.045 30)` | `#F8E2DC` | Hover de itens destrutivos |
| Texto sobre destaque | — | `#FFFFFF` | Label de botões primários |
| Ponto "Salvo" | `oklch(0.62 0.12 150)` | `#3F9A6B` | Indicador verde de salvo |

> Os tokens são definidos como CSS vars no container raiz e herdados por todos os
> filhos. Mapeie-os para o sistema de tema do seu projeto.

### Tipografia
- **Display / títulos / wordmark:** `Bricolage Grotesque` (Google Fonts), pesos 500–800.
- **Interface / corpo / leitura:** `Hanken Grotesk` (Google Fonts), pesos 400–700.
- **Opcional (modo leitura serifada do editor):** `Newsreader` (fallback `Georgia, serif`).
- Antialiasing: `-webkit-font-smoothing: antialiased`.

| Papel | Família | Tamanho | Peso | Tracking | Line-height |
|---|---|---|---|---|---|
| Wordmark "Anotai" | Bricolage | `clamp(27px,3vw,35px)` | 800 | -0.025em | 1 |
| Saudação ("Olá, …") | Hanken | 14.5px | 400 | — | — |
| Título de seção (h2) | Bricolage | 20px | 700 | -0.01em | — |
| Contador de seção | Hanken | 13.5px | 400 | — | tabular-nums |
| Título da nota (lista) | Bricolage | 16.5px | 600 | -0.005em | — (1 linha, ellipsis) |
| Prévia da nota (lista) | Hanken | 14.5px | 400 | — | 1.5 (clamp 1 linha) |
| Data / meta | Hanken | 12.5–13px | 400/500 | — | tabular-nums |
| Item de menu | Hanken | 14.5px | 400 | — | — |
| Label do dock | Hanken | 14px | 500 (ativo 600) | — | — |
| Título no editor | Bricolage | `clamp(25px,3.2vw,33px)` | 700 | -0.02em | 1.2 |
| Corpo no editor (sans) | Hanken | 18px | 400 | — | 1.78 |
| Corpo no editor (serif) | Newsreader | 19px | 400 | — | 1.78 |

### Raios, sombras, espaçamento
- **Border-radius:** botões primários 11px · ícones-botão 9–10px · linhas da lista
  13px · menus/popovers 13–14px · dock 18px · chip do dock 13px · busca e avatar 999px (pílula).
- **Sombras:**
  - Botão primário: `0 1px 2px oklch(0.5 0.12 48 / .25)`.
  - Menu de linha: `0 12px 34px oklch(0.4 0.03 60 / .16), 0 2px 6px oklch(0.4 0.03 60 / .08)`.
  - Popover do editor: `0 14px 36px oklch(0.4 0.03 60 / .18)`.
  - Dock: `0 10px 30px oklch(0.4 0.03 60 / .14), 0 2px 6px oklch(0.4 0.03 60 / .07)`.
- **Paddings-chave:** header `clamp(22px,3vw,34px) clamp(20px,4vw,48px) 16px` ·
  linha da lista `17px 14px` · corpo do editor `clamp(28px,5vw,56px) clamp(20px,5vw,40px) 80px`.
- **Largura máxima de conteúdo:** lista `920px`, coluna do editor `720px` (ambas centradas).
- **Áreas de toque:** ícones-botão 36–40px (≥44px recomendado no mobile).

### Ícones (linha, stroke ≈1.7, 18–20px, `currentColor`)
Conjunto consistente e desenhado à mão no protótipo. Substitua pela biblioteca de
ícones do seu projeto, mantendo a mesma metáfora:

| Função | Ícone | Equivalente Material/Lucide |
|---|---|---|
| Buscar | lupa | `search` |
| Nova nota | "+" | `plus` / `add` |
| Favorito (vazio/cheio) | estrela contorno / preenchida | `star_border` / `star` |
| Opções | 3 pontos verticais | `more_vert` |
| Salvar | check | `check` |
| Voltar | seta à esquerda | `arrow_left` |
| Informações | "i" em círculo | `info` |
| Restaurar | seta circular | `restore` / `rotate-ccw` |
| Arquivar | caixa | `archive` / `inbox` |
| Desarquivar | caixa com seta p/ cima | `archive` + up |
| Lixeira / Enviar p/ lixeira | lixeira | `delete` / `trash` |
| Excluir definitivamente | lixeira com linhas | `delete_forever` |
| Tab Anotações | linhas de lista | `list` / `notes` |

---

## Telas / Views

### 1) HomeView
**Propósito:** ver, buscar e gerenciar notas, alternando entre Anotações, Arquivo e Lixeira.

**Layout (colunas em flex, vertical):**
- **Header** (topo, `flex:none`, wrap): à esquerda o wordmark "Anotai" + saudação
  "Olá, {userName}"; à direita um grupo flex (gap 12px) com: campo de busca em pílula
  (input + lupa), botão primário "Nova nota" (+), avatar circular 42px com a inicial.
- **Main** (scroll, `flex:1`, padding inferior 130px p/ não cobrir com o dock):
  bloco centrado de até 920px com:
  - cabeçalho da seção: `h2` com o nome da seção + contador ("5 notas") com borda
    inferior de 1px (`--line`).
  - **Lista de notas** (cada item é uma linha clicável, radius 13px, hover `--paper2`):
    - Esquerda (flex:1): linha do título (estrela âmbar 15px só se favorita +
      título Bricolage 16.5px, 1 linha ellipsis) e prévia (1 linha, `--muted`,
      `-webkit-line-clamp:1`).
    - Direita (flex:none): data (`--faint`, 12.5px) + botão **favoritar** (estrela;
      nas abas Anotações/Arquivo) **ou** botão **restaurar** (na Lixeira) + botão
      **opções** (3 pontos).
  - **Estado vazio:** ícone de documento + mensagem centrada (texto varia por aba).
- **Dock inferior flutuante** (`position:absolute; bottom:22px; centralizado`):
  cartão pílula com 3 itens — Anotações / Arquivo / Lixeira. Item ativo: fundo
  `--accent-weak`, texto `--accent`, peso 600. Inativo: transparente, `--muted`,
  hover `--paper2`.

**Copy exata das seções/estados vazios:**
- Anotações → contador "{n} notas" · vazio "Nenhuma nota ainda."
- Arquivo → vazio "Nenhuma nota arquivada."
- Lixeira → vazio "Lixeira vazia."
- Busca sem resultado → "Nenhuma nota encontrada."

**Menu de opções da linha (popover ancorado à direita da linha, ~52px abaixo):**
- Aba **Anotações:** `Arquivar` — divisor — `Enviar para a lixeira` (vermelho).
- Aba **Arquivo:** `Desarquivar` — divisor — `Enviar para a lixeira` (vermelho).
- Aba **Lixeira:** `Restaurar` — divisor — `Excluir definitivamente` (vermelho).

### 2) EditorView
**Propósito:** criar ou editar uma nota; foco total no texto.

**Layout:**
- **Header** (sticky no topo, borda inferior, fundo translúcido com `backdrop-filter:
  blur(8px)`):
  - Esquerda: botão **Voltar** (seta, com borda) + bloco de status: rótulo do modo
    ("Nova nota" / "Editar nota") e linha de autosave (pontinho colorido +
    "Salvando…" / "Salvo").
  - Direita (grupo flex, `position:relative` para ancorar popovers): **Favoritar**
    (estrela) · **Informações** (i) · **Opções** (3 pontos) · divisor vertical ·
    botão primário **Salvar** (check + label).
- **Main** (scroll): coluna centrada de até 720px com:
  - `textarea` de **Título** (auto-altura, Bricolage 700, placeholder "Título").
  - Linha meta: data · "{n} palavras".
  - Divisor 1px.
  - `textarea` de **Conteúdo** (placeholder "Escreva sua nota…", min-height 50vh,
    line-height 1.78; família alterna sans/serif conforme a opção).

**Popover de Informações** (ancorado ao botão "i", 270px): título "Informações da
nota" + linhas "Criada em / Palavras / Caracteres" + botão "Fechar".

**Menu de opções do editor** (contextual ao estado da nota):
- Nota comum: `Arquivar` — divisor — `Enviar para a lixeira` (vermelho).
- Nota arquivada: `Desarquivar` — divisor — `Enviar para a lixeira` (vermelho).
- Nota na lixeira: `Restaurar` — divisor — `Excluir definitivamente` (vermelho).

---

## Interações & comportamento
- **Abrir nota:** clique em qualquer parte da linha → EditorView em modo edição.
- **Nova nota:** botão "Nova nota" → EditorView em modo criação (campos vazios).
- **Favoritar:** clique na estrela (lista ou editor) alterna `favorita` e salva na
  hora. `stopPropagation` para não abrir a nota ao clicar na estrela/opções.
- **Menus/popovers:** abrir um fecha os outros; um overlay transparente em tela cheia
  fecha qualquer menu ao clicar fora.
- **Mover entre seções:** arquivar/desarquivar/lixeira/restaurar atualizam os flags da
  nota e a lista recalcula. No **editor**, ao executar uma dessas ações o app volta
  para a Home e muda para a aba de destino (ex.: Arquivar → aba Arquivo).
- **Salvamento automático (debounce):** cada digitação marca status "salvando" e
  agenda um commit; após **900 ms** sem digitar, persiste e marca "Salvo". (A spec
  original pede 5 s — ajuste o intervalo conforme desejado.) Ao sair (Voltar/Salvar),
  força o commit imediato. Sem diálogo de confirmação.
- **Modo criação → edição:** o primeiro commit cria a nota (id novo) e passa a editar.
- **Transições:** menus/popovers entram com `pop` (opacity + translateY 6px + scale,
  0.14s); troca de view com `fade` 0.25s. Hovers de fundo/cor em 0.12–0.15s.
- **Responsividade:** tipografia e paddings em `clamp()`, busca em `clamp(170px,22vw,
  250px)`, grupos do header com `flex-wrap`. Sugestão p/ telas estreitas: o dock
  flutuante já funciona como bottom-nav; reduzir os labels a ícones quando faltar
  largura.

### Comportamentos da spec ainda **não** implementados no protótipo (v1.1)
Diálogo de confirmação ao "Excluir definitivamente", SnackBar de "Desfazer" ao enviar
p/ lixeira, seleção múltipla por long-press, e aba dedicada de Favoritas. Ver
`spec_original_v1.md`.

---

## Gerenciamento de estado
Modelo de **uma nota**:
```
Note { id, title, content, favorita: bool, arquivada: bool, apagada: bool, date }
```
Estado da tela:
- `view`: `'home' | 'editor'`
- `tab`: `'notas' | 'arquivo' | 'lixeira'`
- `search`: string (filtra título+conteúdo, case-insensitive)
- `notes`: Note[]
- `editingId`: id da nota aberta (ou `null` em criação)
- `editorTitle`, `editorContent`: rascunho dos campos
- `saveStatus`: `'salvo' | 'salvando'`
- `rowMenuId`, `editorMenuOpen`, `infoOpen`: controle de menus/popovers

**Filtros por aba:** Anotações = `!arquivada && !apagada` · Arquivo = `arquivada &&
!apagada` · Lixeira = `apagada`. Restaurar apenas zera `apagada` (a nota volta para
Arquivo se ainda `arquivada`, senão para Anotações).

**Persistência:** o protótipo guarda tudo em memória. No app real, ligar ao
armazenamento existente (a spec cita **Hive**, no Flutter). `date` é exibida em
formato BR curto ("12 jun 2026").

Props expostas como ajustes no protótipo (opcionais): `userName` (texto da saudação/
inicial do avatar), `showGreeting` (bool), `noteSerif` (bool — usa fonte serifada na
leitura do editor).

---

## Assets
- **Fontes:** Bricolage Grotesque, Hanken Grotesk, Newsreader (Google Fonts).
- **Ícones:** SVGs de linha inline no protótipo — substituir pela biblioteca do
  projeto (tabela de equivalências acima).
- **Imagens:** nenhuma. O avatar é um círculo com a inicial do usuário.

## Arquivos neste pacote
- `Anotai.dc.html` — protótipo de referência (HomeView + EditorView + menus + lógica).
- `spec_original_v1.md` — especificação funcional original (fonte de verdade do comportamento).
- `README.md` — este documento.
- `screenshots/01-home-anotacoes.png` — HomeView, aba Anotações.
- `screenshots/02-home-menu-opcoes.png` — HomeView com o menu de opções da nota aberto.
- `screenshots/03-editor.png` — EditorView editando uma nota.

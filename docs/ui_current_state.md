# UI Atual — HomeView e EditorView

Documento descritivo da interface e features atuais do Anotai v1.0, para uso no Claude Design.

---

## HomeView — Tela Principal

### Estrutura geral

**AppBar (topo)**
- Título: "Anotai" (alinhado à esquerda)
- Botão de busca: ícone de lupa (alinhado à direita, placeholder para v1.1)

**Body (conteúdo)**
- Dinamicamente muda conforme a aba selecionada (ver abas abaixo)

**BottomNavigationBar (base)**
- 3 abas navegáveis:
  1. **Anotações** — notas ativas (não arquivadas, não apagadas)
  2. **Arquivo** — notas arquivadas
  3. **Lixeira** — notas apagadas (soft delete)

**FAB (botão flutuante)**
- Posição: canto inferior direito
- Ícone: "+" (plus)
- Ação: cria nota nova, navega para EditorView em modo criação

---

## HomeView — Conteúdo por Aba

### Aba 1: Anotações (notas ativas)

**Estado vazio:**
- Mensagem: "Nenhuma nota ainda."
- Centro da tela

**Estado com notas:**
- **ListView** com lista de notas ativas
- Cada nota é um **ListTile** com:

#### Estrutura de cada ListTile

```
[Título da nota]
Conteúdo da nota (primeiras linhas)

                                        ⭐ [...]
```

- **Área clicável:** tap em qualquer lugar do tile → abre EditorView em modo edição
- **Trailing (extremidade direita):**
  - **Botão Favorita:** ícone de estrela
    - Vazia: `★` (não favorita) — cor padrão
    - Cheia: `★` (favorita) — cor amarela
    - Ação: tap → inverte `isFavorita`, salva automaticamente
  - **Botão Opções (3 pontos verticais):** ícone `⋮`
    - Ação: tap → abre PopupMenu com opções

#### PopupMenu — Aba Anotações

Opções disponíveis:
- **Arquivar** — move nota para aba "Arquivo" (`isArquivada = true`)
- [Separador visual]
- **Enviar para a lixeira** — move para "Lixeira" (`isApagada = true`), mostra SnackBar com "Desfazer" (v1.1)

---

### Aba 2: Arquivo (notas arquivadas)

**Estado vazio:**
- Mensagem: "Nenhuma nota arquivada."

**Estado com notas:**
- Estrutura idêntica à aba Anotações
- Cada ListTile tem:
  - Botão Favorita (mesmo comportamento)
  - Botão Opções com PopupMenu diferente:

#### PopupMenu — Aba Arquivo

Opções:
- **Desarquivar** — remove do arquivo (`isArquivada = false`), volta para "Anotações"
- [Separador visual]
- **Enviar para a lixeira** — move para "Lixeira" (`isApagada = true`)

---

### Aba 3: Lixeira (notas apagadas/soft delete)

**Estado vazio:**
- Mensagem: "Lixeira vazia."

**Estado com notas:**
- Estrutura base igual às outras abas, com adições:
- Cada ListTile tem:
  - Botão Favorita (desabilitado visualmente, ou não aparece — ainda não decidido)
  - **Botão Restaurar (ícone de seta para cima/restauração)** — alinhado antes do menu
    - Ação: tap → chama `restaurarNota()`, nota volta ao estado anterior
    - Comportamento: se `isArquivada = true`, volta para "Arquivo"; senão, para "Anotações"
  - Botão Opções com PopupMenu específico:

#### PopupMenu — Aba Lixeira

Opções:
- **Excluir definitivamente** — hard delete do Hive, abre Dialog de confirmação (v1.1)
  - Dialog: "Deseja excluir permanentemente esta nota? Esta ação não pode ser desfeita."
  - Botões: Cancelar (padrão) | Excluir (vermelho)
  - Só executa se confirmar

---

## HomeView — Features v1.1 Planejadas (não implementadas)

- **Seleção múltipla:** long press em nota → entra em modo seleção, checkbox aparece
- **Ações em massa:** barra de ações com botões contextuais (Arquivar, Enviar, etc.)
- **SnackBar de Undo:** ao enviar para lixeira, mostra "Nota movida para a lixeira" com botão "Desfazer"
- **Busca:** botão de busca no AppBar (placeholder) → futura implementação
- **Aba Favoritas:** futura navegação dedicada para notas favoritadas

---

## EditorView — Tela de Edição/Criação

### Estrutura geral

**AppBar (topo)**
- Título: dinâmico
  - Se criando: "Nova nota"
  - Se editando: "Editar nota"
- Botões à direita (actions):
  1. **Botão Favorita** (só em modo edição)
  2. **Botão Informações** (ícone "i")
  3. **Botão Opções** (3 pontos)
  4. **Botão Salvar** (ícone checkmark/✓)

**Body (conteúdo)**
- Dois campos de texto empilhados verticalmente:
  1. Campo de Título
  2. Campo de Conteúdo (expansível)

**FAB (opcional)**
- Duplica a ação do botão Salvar do AppBar
- Ícone: checkmark/✓
- Ação: salva e volta para HomeView

---

## EditorView — Campos de Entrada

### Campo de Título

- **Placeholder:** "Título"
- **Single-line:** não expande, uma linha apenas
- **Estilo:** texto maior, bold (FontSize 18, FontWeight.w500)
- **Border:** OutlineInputBorder (caixa com borda)
- **Padding:** 12px horizontal, 12px vertical

### Campo de Conteúdo

- **Placeholder:** "Escreva sua nota..."
- **Multi-line:** expansível, ocupa todo espaço restante
- **maxLines:** null (ilimitado)
- **expands:** true (preenche espaço disponível)
- **Align:** top (texto alinhado ao topo, não centralizado)
- **Border:** OutlineInputBorder
- **Padding:** 12px all sides

---

## EditorView — AppBar Actions (de esquerda para direita)

### 1. Botão Favorita ⭐

- **Aparece:** só em modo edição (quando `notaEmEdicao != null`)
- **Ícone vazio:** `★` — não favorita (cor padrão)
- **Ícone cheio:** `★` — favorita (cor amarela)
- **Ação:** tap → inverte `isFavorita`, salva automaticamente
- **Tooltip:** "Adicionar aos favoritos" ou "Remover de favoritos"

### 2. Botão Informações ℹ️

- **Ícone:** "i" em círculo ou outline
- **Sempre visível** (criar ou editar)
- **Ação:** tap → abre **BottomSheet** com informações:

#### BottomSheet de Informações

Bandeja que surge na base da tela, contendo:
- **Título:** "Informações da nota"
- **Conteúdo:**
  - Data de criação: "Criada em: DD-MM-AAAA" (formato brasileiro)
- **Botão:** "Fechar" para descartar a bandeja
- Futuramente: mais informações (última edição, tamanho, etc.)

### 3. Botão Opções ⋮

- **Ícone:** 3 pontos verticais
- **Sempre visível** (criar ou editar)
- **Ação:** tap → abre PopupMenu com opções contextuais

#### PopupMenu — EditorView

O menu muda conforme o estado da nota:

**Se nota é comum (não arquivada, não apagada):**
- **Arquivar**
- [Separador]
- **Enviar para a lixeira** (vermelho)

**Se nota é arquivada:**
- **Desarquivar**
- [Separador]
- **Enviar para a lixeira** (vermelho)

**Se nota está na lixeira (apagada):**
- **Restaurar**
- [Separador]
- **Excluir definitivamente** (vermelho, abre Dialog de confirmação)

### 4. Botão Salvar ✓

- **Ícone:** checkmark
- **Sempre visível**
- **Ação:** tap → força salvamento imediato e volta para HomeView

---

## EditorView — Salvamento Automático

**Comportamento:**
- Toda digitação em qualquer campo dispara um listener
- Timer de debounce: **5 segundos**
  - Se usuário parar de digitar por 5s → salva automaticamente
  - Se usuário digita novamente → timer reinicia (debounce)
- Ao sair da tela (voltar para HomeView) → força salvamento imediato
- Sem diálogo de confirmação de salvamento — acontece em silêncio (UX fluida)

**Estados:**
- Modo criação: após primeiro salvamento, entra em modo edição
- Modo edição: qualquer mudança dispara o debounce

---

## Paleta de Cores (atual)

- **Cor primária:** Indigo (ColorScheme.fromSeed)
- **Favorita:** Amarela/Amber
- **Ações destrutivas (Enviar lixeira, Excluir):** Vermelho
- **Fundo:** Branco/claro (padrão Material)
- **Texto:** Preto/cinza escuro (padrão)

---

## Ícones Utilizados

| Feature | Ícone | Origem |
|---------|-------|--------|
| Novo (FAB) | `+` plus | Icons.add |
| Favorita vazia | `★` star_border | Icons.star_border |
| Favorita cheia | `★` star | Icons.star |
| Busca | `🔍` search | Icons.search |
| Informações | `ℹ️` info_outline | Icons.info_outline |
| Opções | `⋮` more_vert | Icons.more_vert |
| Salvar | `✓` check | Icons.check |
| Restaurar | `↻` restore | Icons.restore |
| Arquivo | `📦` archive | Icons.archive |
| Lixeira | `🗑️` delete | Icons.delete |
| Anotações | `📝` note | Icons.note |

---

## Responsividade

- **Web (chrome):** layouts otimizados para tela grande
- **Mobile (futuro Android):** ajustes automáticos de padding/tamanho via MediaQuery
- **Tablets:** aproveita tela grande, layouts adaptativos

---

## Fluxos de Navegação (v1.0)

```
HomeView (aba Anotações)
    ├── [tap em nota] → EditorView (modo edição)
    ├── [FAB +] → EditorView (modo criação)
    └── [BottomNav] → muda para Arquivo ou Lixeira

EditorView
    ├── [Salvar/Voltar] → HomeView
    └── [Menu Opções] → PopupMenu (ações contextuais)
```

---

## Próximos Fluxos (v1.1)

- **Seleção múltipla:** long press → modo seleção, checkboxes aparecem, barra de ações
- **SnackBar:** ao enviar para lixeira, mostra "Desfazer" por 4-5s
- **Dialog:** ao excluir definitivamente, pede confirmação
- **Busca:** botão de busca ativa campo de filtro em tempo real

---

## Fase 3 — Features Avançadas (futura)

### Modo Escuro

**O que é:**
- Tema alternativo com paleta de cores otimizada para ambientes pouco iluminados
- Reduz fadiga ocular em uso noturno
- Alterna automaticamente ou via toggle manual nas configurações

**Implementação:**
- Duas paletas no ThemeData: `lightTheme` e `darkTheme`
- Detecta preferência do sistema via `MediaQuery.of(context).platformBrightness`
- Opção de toggle manual em um futuro menu de Configurações

**Paleta de cores — Dark Mode:**
- **Background:** Cinza escuro/preto (#121212 ou similar)
- **Surface:** Cinza mais claro (#1E1E1E)
- **Text primário:** Branco/cinza muito claro
- **Text secundário:** Cinza médio
- **Cor primária:** Indigo (mantém)
- **Favorita:** Amarela/Amber (mantém, mas pode ser mais clara)
- **Ações destrutivas:** Vermelho (mantém)

**Componentes afetados:**
- ListTiles: fundo escuro, texto claro
- AppBar: fundo escuro
- TextFields: border e fundo adaptados
- Buttons: cores contrastantes no dark mode
- BottomSheet: fundo escuro
- PopupMenus: fundo escuro, texto claro

**User Experience:**
- Transição suave entre temas (sem piscar)
- Preservar escolha do usuário (salvar em SharedPreferences)
- Se "automático": muda com hora do dia ou configuração do dispositivo


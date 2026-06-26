# Anotai

Um app de anotações offline-first construído com Flutter como projeto de aprendizado prático.

## Sobre

Anotai é um exercício pedagógico: um app real sendo desenvolvido do zero com foco em
arquitetura de software, boas práticas e versionamento com Git.

## Status

**MVP completo** — funcionalidades principais implementadas. Em fase de expansão e adaptação para Android.

## Funcionalidades (MVP)

✅ **Criação e edição**
- Criação de notas com título e conteúdo
- Edição em tempo real com salvamento automático (5 segundos de debounce)
- Salvamento imediato ao fechar a nota

✅ **Organização**
- Arquivamento de notas em pasta dedicada
- Desarquivamento com volta automática à aba original
- Marcação de notas como favoritas

✅ **Lixeira**
- Exclusão soft (move para lixeira, não deleta de verdade)
- Exclusão automática após 30 dias na lixeira (`limparExpiradas` roda na inicialização)
- Restauração mantém estado anterior (se era arquivada, volta ao arquivo)
- Exclusão permanente com confirmação

✅ **Busca**
- Filtragem em tempo real por título e conteúdo
- Isolada por aba — buscar em "Anotações" não afeta "Arquivo"
- Limpa automaticamente ao trocar de aba

✅ **Interface**
- Três abas: Anotações, Arquivo, Lixeira
- Menu de contexto dinâmico por aba
- Data de criação exibida em cada nota na lista
- Dialog de informações da nota (criação, última edição, palavras, caracteres)
- Indicador visual de favoritas (estrela)
- Design system centralizado (`AppTheme`) com cores, tipografia, raios, sombras e espaçamentos

**Planejado para o futuro (Fase 2+)**
- Aba dedicada para favoritas
- Lock/unlock de notas (modo read-only)
- Histórico de versões (reverter para estado anterior)
- Suporte a imagens nas anotações
- Plataforma Android
- Sincronização entre dispositivos

## Tech Stack

- **Flutter / Dart** — framework UI multiplataforma
- **Hive** — banco de dados local NoSQL, otimizado para Flutter
- **Provider** — gerenciamento de estado (ChangeNotifier)

## Arquitetura

Padrão **MVVM** (Model-View-ViewModel) com **Service Layer**, camadas bem definidas:

```
lib/
├── models/         # Nota, Categoria: classes de dados com serialização
├── repositories/   # NotaRepository + CategoriaRepository (interfaces) + implementações Hive
├── services/       # Regras de negócio: TrashService, ArchiveService, NoteEditorService, CategoriaService
├── viewmodels/     # NotaViewModel: estado reativo, ChangeNotifier, delega para Services
├── ui/             # Tudo relacionado à interface
│   ├── views/      # HomeView, EditorView: orquestram a tela
│   ├── components/ # Widgets reutilizáveis (home/ e editor/)
│   ├── styles/     # AppTheme: tokens implementados (cores, tipografia, raios, sombras, espaçamentos)
│   └── utils/      # Funções auxiliares puras (formatadores, etc.)
└── main.dart       # Inicialização (Hive, Provider, app raiz)
```

O fluxo entre camadas:
```
View  →  ViewModel  →  Services  →  Repository  →  Hive
 UI      estado +        regras      acesso aos      banco
         notifica        negócio       dados
```

### Padrões utilizados

- **Repository Pattern** — abstração entre lógica e persistência
- **Service Layer** — regras de negócio isoladas do ViewModel (`TrashService`, `ArchiveService`, `NoteEditorService`, `FavoriteService`, `SearchService`, `CategoriaService`)
- **Entity with ID** — `Categoria` é uma entidade com ID próprio; notas armazenam `categoriaIds` (lista de IDs), não os nomes — renomear uma categoria não exige atualizar as notas
- **Soft Delete** — exclusão lógica com flag `isApagada` + `apagadaEm` (timestamp para expiração de 30 dias)
- **Change Notifier** — reatividade: Views escutam mudanças no ViewModel
- **Debounce** — salvamento automático após 5s de inatividade
- **Injeção de Dependência** — serviços e ViewModel recebem Repository no construtor

### Estados da Nota

Uma nota tem três estados **independentes**:
- `isFavorita`: marca como favorita (estrela)
- `isArquivada`: marca como arquivada (aba "Arquivo")
- `isApagada`: marca como deletada (aba "Lixeira")

Exemplo: uma nota pode estar `isArquivada=true` e depois ser `isApagada=true`.
Ao restaurar da lixeira, volta com `isArquivada=true` (lembra do estado anterior).

## Como rodar localmente

**Pré-requisitos**
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versão 3.12+)
- Google Chrome (para rodar no web)

**Instalação**
```bash
git clone https://github.com/rogial12/anotai.git
cd anotai
flutter pub get
flutter run -d chrome
```

**Estrutura do projeto**
```
anotai/
├── lib/
│   ├── models/
│   │   ├── nota.dart                 # Modelo com toMap/fromMap; inclui categoriaIds
│   │   └── categoria.dart            # Entidade Categoria com id + nome
│   ├── repositories/
│   │   ├── nota_repository.dart      # Interface (contrato)
│   │   ├── local_nota_repository.dart # Implementação Hive
│   │   ├── categoria_repository.dart  # Interface (contrato)
│   │   └── local_categoria_repository.dart # Implementação Hive (box 'categorias')
│   ├── services/
│   │   ├── trash_service.dart        # Soft delete, restauração, exclusão permanente
│   │   ├── archive_service.dart      # Arquivamento e desarquivamento
│   │   ├── note_editor_service.dart  # Criação de nota vazia, salvamento
│   │   ├── favorite_service.dart     # Toggle de favorita
│   │   ├── search_service.dart       # Filtro em memória (stateless)
│   │   └── categoria_service.dart    # Criar, renomear, deletar categorias
│   ├── viewmodels/nota_viewmodel.dart # Estado reativo, delega operações para Services
│   ├── ui/
│   │   ├── views/
│   │   │   ├── home_view.dart        # Tela principal (3 abas)
│   │   │   └── editor_view.dart      # Tela de edição (padrão "sempre editando")
│   │   ├── components/
│   │   │   ├── home/                 # NoteTile, DockBar, HomeHeader, etc.
│   │   │   └── editor/               # EditorHeader
│   │   ├── styles/app_theme.dart     # Tokens implementados: 16 cores, 13 estilos, raios, sombras, espaçamentos
│   │   └── utils/formatters.dart     # Funções auxiliares puras: formatDate, wordCount, charCount
│   └── main.dart                     # Entry point
├── pubspec.yaml                      # Dependências (hive, provider)
├── docs/diagrama.md                  # Diagrama de classes (Mermaid)
└── README.md                         # Este arquivo
```

**Diagrama de classes do projeto:** ver [docs/diagrama.md](docs/diagrama.md)

## Mudanças principais (MVP)

### Modelo Nota
- **Estados independentes:** `isFavorita`, `isArquivada`, `isApagada`
- **`isApagada`** — soft delete com lixeira de 30 dias
- **`apagadaEm`** — timestamp de quando a nota foi para a lixeira; usado pelo `TrashService.limparExpiradas()`
- **Serialização:** `toMap()` e `fromMap()` para persistência Hive

### ViewModel
- **Novo:** `_notaEmEdicao` — rastreia nota em edição
- **Novos métodos:** `desarquivarNota()`, `deletarPermanentemente()`, `setNotaEmEdicao()`
- **Refatorado:** `restaurarNota()` — mantém estado `isArquivada` ao restaurar
- **Refatorado:** getters filtrados agora usam `isApagada` em lugar de `apagadaEm`

### Views
- **HomeView:** Menu dinâmico por aba, `PopupMenuButton` para posicionamento correto
- **EditorView:** Envolvida em `Consumer` para escutar mudanças, botão favorita funcional, bottom sheet de informações


## Roadmap detalhado

| Fase | Feature | Status |
|------|---------|--------|
| **Fase 2** | Busca por título/conteúdo | ✅ Concluído |
| | Chips de categorias (inclui Favoritas) | 🔄 Em andamento |
| | Diálogo de confirmação + Undo de exclusão | ✅ Concluído |
| | Countdown de 30 dias na lixeira | ✅ Concluído |
| | Melhorias na UI — linguagem de design consistente | ✅ Concluído |
| | Contagem de caracteres/palavras na edição | ✅ Concluído |
| **Fase 3** | Exportação PDF | ⏳ Planejado |
| | Exportação/backup manual | ⏳ Planejado |
| | Suporte a imagens nas anotações | ⏳ Planejado |
| | Lock/unlock (modo read-only) | ⏳ Planejado |
| | Histórico de versões (reverter estado) | ⏳ Planejado |
| | Anotações criptografadas | ⏳ Planejado |
| | Modo escuro (dark mode) | ⏳ Planejado |
| **Fase 4** | Autenticação biométrica (digital/face) | ⏳ Planejado |
| | Sincronização entre dispositivos | ⏳ Planejado |
| | Resolução de conflitos de sincronização | ⏳ Planejado |

## TODO — Pendências imediatas

### Android — ajustes de layout (identificados no primeiro teste)

- [x] **EditorView**: header sobreposto pela barra de sistema — `SafeArea(top: true)` adicionado ao body
- [x] **HomeHeader**: wordmark quebrando linha — refatorado para `StatefulWidget` com dois modos (normal/busca); wordmark com tamanho dinâmico via `MediaQuery`
- [ ] **HomeView**: espaçamento extra antes das tiles — `ListView.builder` aplicando padding do sistema automaticamente

### MVP

- [ ] **Exportação PDF** — último item formal do MVP pendente

### UX / Melhorias

- [ ] **SettingsView** — tela de configurações (botão existe no header, sem destino)
- [ ] **Aba Favoritas** — aba dedicada na DockBar para notas marcadas como favoritas
- [ ] **Valores responsivos (clamp)** — `AppTheme` usa valores fixos intermediários; implementar `MediaQuery`-based clamp para fontes, paddings e espaçamentos

### Adiado (depende de outra feature)

- [ ] **Dialog "apagar nota esvaziada"** — exibir confirmação quando o usuário apaga todo o conteúdo de uma nota existente; adiado até o histórico de versões estar implementado (sem ele, cancelar o dialog não restaura o conteúdo)

---

### Notas sobre o Roadmap

- **Fase 2** foca em polimento do MVP (UX, busca, confirmações)
- **Fase 3** adiciona features avançadas (histórico, criptografia, tags)
- **Fase 4** expande para multiplataforma com sincronização
- Todas as fases mantêm compatibilidade com versões anteriores

## Notas de desenvolvimento

- Commits direto na `main` durante MVP (migrar para feature branches + PRs na Fase 2)
- Todos os métodos têm comentários explicativos (educacional)
- Estado reativo via `Consumer<NotaViewModel>` — View não precisa saber de persistência
- Testes ainda não implementados (foco em funcionalidade + aprendizado)

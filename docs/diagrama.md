# Diagrama de Classes — Anotai

Arquitetura MVVM implementada no MVP.

```mermaid
classDiagram
    class Nota {
        +String id
        +String titulo
        +String conteudo
        +DateTime criadaEm
        +DateTime atualizadaEm
        +bool isFavorita
        +bool isArquivada
        +bool isApagada
        +DateTime? apagadaEm
        +List categoriaIds
        +toMap() Map
        +fromMap() Nota
    }

    class Categoria {
        +String id
        +String nome
        +toMap() Map
        +fromMap() Categoria
    }

    class NotaViewModel {
        -List _notas
        -Nota? _notaEmEdicao
        +List notas
        +List favoritas
        +List arquivadas
        +List lixeira
        +Nota? notaEmEdicao
        +carregarNotas()
        +criarNotaVazia()
        +salvarNota()
        +apagarNota()
        +restaurarNota()
        +deletarPermanentemente()
        +arquivarNota()
        +desarquivarNota()
        +toggleFavorita()
        +setNotaEmEdicao()
    }

    class NotaRepository {
        <<interface>>
        +buscarTodas() List
        +salvar(Nota nota)
        +deletar(String id)
    }

    class LocalNotaRepository {
        -Box _box
        +buscarTodas() List
        +salvar(Nota nota)
        +deletar(String id)
    }

    class CategoriaRepository {
        <<interface>>
        +buscarTodas() List
        +salvar(Categoria categoria)
        +deletar(String id)
    }

    class LocalCategoriaRepository {
        -Box _box
        +buscarTodas() List
        +salvar(Categoria categoria)
        +deletar(String id)
    }

    namespace ui_views {
        class HomeView {
            -int _selectedTabIndex
            -NotaViewModel viewModel
            +build()
            -_buildContextMenuItems()
        }

        class EditorView {
            -TextEditingController _titleController
            -TextEditingController _contentController
            -Timer? _debounceTimer
            -NotaViewModel viewModel
            +build()
            -_onTextChanged()
            -_saveAutomatically()
            -_saveAndClose()
            -_showInfoDialog()
            -_buildContextMenuItems()
        }
    }

    namespace ui_components_home {
        class HomeHeader {
            +VoidCallback onSettings
            +TextEditingController searchController
            +ValueChanged onSearchChanged
            -bool _isSearching
            -FocusNode _searchFocus
            -_openSearch()
            -_closeSearch()
            -_buildNormalMode()
            -_buildSearchMode()
        }
        class DockBar {
            +int selectedIndex
            +ValueChanged onTabChanged
        }
        class NoteTile {
            +Nota nota
            +bool isLixeira
            +VoidCallback onTap
            +VoidCallback onToggleFavorita
            +VoidCallback? onRestore
            +List menuItems
        }
        class SectionHeader {
            +String title
            +int count
        }
        class EmptyState {
            +int tabIndex
        }
    }

    namespace ui_components_editor {
        class EditorHeader {
            +String title
            +bool isFavorita
            +VoidCallback onBack
            +VoidCallback onToggleFavorita
            +List menuItems
        }
    }

    namespace ui_utils {
        class Formatters {
            +formatDate(DateTime) String
            +wordCount(String) int
            +charCount(String) int
        }
    }

    namespace ui_styles {
        class AppTheme {
            +Color paper, paper2, card
            +Color ink, muted, faint
            +Color accent, accentPress, accentWeak
            +Color amber, danger, saved
            +TextStyle wordmark, greeting, sectionTitle
            +TextStyle noteTitleList, notePreview, meta
            +TextStyle editorTitle, editorBody, editorBodySerif
            +double radiusButton, radiusTile, radiusDock
            +List shadowButton, shadowMenu, shadowDock
            +EdgeInsets tilePadding
            +double listMaxWidth, editorMaxWidth
        }
    }

    namespace services {
        class FavoriteService {
            +toggleFavorita()
        }
        class SearchService {
            +buscar(List notas, String query) List
        }
        class TrashService {
            +apagarNota()
            +restaurarNota()
            +deletarPermanentemente()
            +limparExpiradas(List notas) List
        }
        class ArchiveService {
            +arquivarNota()
            +desarquivarNota()
        }
        class NoteEditorService {
            +criarNotaVazia()
            +salvarNota()
        }
        class CategoriaService {
            +buscarTodas() List
            +criar(String nome) Categoria
            +renomear(Categoria categoria, String novoNome)
            +deletar(String id)
        }
    }

    NotaViewModel --> NotaRepository : usa
    NotaViewModel --> FavoriteService : delega
    NotaViewModel --> SearchService : delega
    NotaViewModel --> TrashService : delega
    NotaViewModel --> ArchiveService : delega
    NotaViewModel --> NoteEditorService : delega
    FavoriteService --> NotaRepository : usa
    TrashService --> NotaRepository : usa
    ArchiveService --> NotaRepository : usa
    NoteEditorService --> NotaRepository : usa
    LocalNotaRepository ..|> NotaRepository : implementa
    CategoriaService --> CategoriaRepository : usa
    LocalCategoriaRepository ..|> CategoriaRepository : implementa
    HomeView --> NotaViewModel : observa
    EditorView --> NotaViewModel : observa
    NotaViewModel --> Nota : gerencia
    Nota --> Categoria : referencia via categoriaIds
```

## Histórico de mudanças

### Modelo Nota
- **Adicionado:** `bool isApagada` (soft delete)
- **Adicionado:** `DateTime? apagadaEm` (timestamp de entrada na lixeira; `null` = fora da lixeira; usado por `limparExpiradas` para expiração de 30 dias)
- **Estados:** Independentes (`isFavorita`, `isArquivada`, `isApagada`)
- **Serialização:** `toMap()` e `fromMap()` para persistência Hive

### ViewModel
- **Novo:** `_notaEmEdicao` — rastreia nota em edição
- **Novo:** `criarNotaVazia()` — cria nota vazia ao abrir editor (padrão "sempre editando")
- **Novo:** `salvarNota()` — substitui `criarNota` + `editarNota`, sem distinção criar/editar
- **Removidos:** `criarNota()` e `editarNota()` — lógica migrada para `NoteEditorService`
- **Refatorado:** `restaurarNota()` — mantém estado `isArquivada` ao restaurar
- **Refatorado:** getters filtrados excluem notas vazias (título e conteúdo em branco)

### Views
- **HomeView:** FAB chama `criarNotaVazia()` antes de navegar para o editor
- **EditorView:** `_saveAutomatically()` simplificado para uma chamada a `salvarNota()`; `_hasChanges` removido

### Camada Services (implementada)
- **`TrashService`**: `apagarNota`, `restaurarNota`, `deletarPermanentemente`, `limparExpiradas` (exclui permanentemente notas com mais de 30 dias na lixeira; chamado no `carregarNotas`)
- **`ArchiveService`**: `arquivarNota`, `desarquivarNota`
- **`NoteEditorService`**: `criarNotaVazia`, `salvarNota`
- **`FavoriteService`**: `toggleFavorita`
- **`SearchService`**: `buscar` (stateless, sem repositório — filtra lista em memória)
- Todos os serviços recebem `NotaRepository` via injeção de dependência e são instanciados em `main.dart`

### Categorias (Passo 1 — ajuste arquitetural)
- **Novo modelo:** `Categoria { id, nome }` com `toMap`/`fromMap`
- **Nova interface:** `CategoriaRepository` (mesmo contrato do `NotaRepository`)
- **Nova implementação:** `LocalCategoriaRepository` (Hive, box `'categorias'`)
- **Novo serviço:** `CategoriaService` — `criar`, `renomear`, `deletar`, `buscarTodas`; não gerencia associação nota↔categoria (responsabilidade do ViewModel)
- **`Nota` atualizada:** novo campo `List<String> categoriaIds` (padrão `[]`; compatível com notas antigas via `?? []` no `fromMap`)
- **`main.dart`:** `ChangeNotifierProvider` substituído por `MultiProvider`; `CategoriaService` disponível na árvore via `Provider<CategoriaService>`
- **Decisão de design:** categorias armazenadas por ID nas notas (não por nome) — renomear uma categoria não exige atualizar nenhuma nota

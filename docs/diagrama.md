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
        +toMap() Map
        +fromMap() Nota
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
        class TrashService {
            +apagarNota()
            +restaurarNota()
            +deletarPermanentemente()
            +limparExpiradas()
        }
        class ArchiveService {
            +arquivarNota()
            +desarquivarNota()
        }
        class NoteEditorService {
            +criarNotaVazia()
            +salvarNota()
        }
    }

    NotaViewModel --> NotaRepository : usa
    NotaViewModel --> TrashService : delega
    NotaViewModel --> ArchiveService : delega
    NotaViewModel --> NoteEditorService : delega
    TrashService --> NotaRepository : usa
    ArchiveService --> NotaRepository : usa
    NoteEditorService --> NotaRepository : usa
    LocalNotaRepository ..|> NotaRepository : implementa
    HomeView --> NotaViewModel : observa
    EditorView --> NotaViewModel : observa
    NotaViewModel --> Nota : gerencia
```

## Histórico de mudanças

### Modelo Nota
- **Removido:** `DateTime? apagadaEm`
- **Adicionado:** `bool isApagada` (soft delete com countdown 30 dias)
- **Estados:** Agora são independentes (`isFavorita`, `isArquivada`, `isApagada`)
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
- **`TrashService`**: `apagarNota`, `restaurarNota`, `deletarPermanentemente` + `limparExpiradas` (TODO — expiração de 30 dias)
- **`ArchiveService`**: `arquivarNota`, `desarquivarNota`
- **`NoteEditorService`**: `criarNotaVazia`, `salvarNota`
- Todos os serviços recebem `NotaRepository` via injeção de dependência e são instanciados em `main.dart`

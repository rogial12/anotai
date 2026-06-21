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
        +criarNota()
        +editarNota()
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
            -bool _hasChanges
            -NotaViewModel viewModel
            +build()
            -_onTextChanged()
            -_saveAutomatically()
            -_saveAndClose()
            -_showInfoBottomSheet()
            -_buildContextMenuItems()
        }
    }

    namespace ui_components_home {
        class HomeHeader["HomeHeader (placeholder)"]
        class DockBar["DockBar (placeholder)"]
        class NoteTile["NoteTile (placeholder)"]
        class SectionHeader["SectionHeader (placeholder)"]
        class EmptyState["EmptyState (placeholder)"]
    }

    namespace ui_components_editor {
        class EditorHeader["EditorHeader (placeholder)"]
        class InfoPopover["InfoPopover (placeholder)"]
    }

    NotaViewModel --> NotaRepository : usa
    LocalNotaRepository ..|> NotaRepository : implementa
    HomeView --> NotaViewModel : observa
    EditorView --> NotaViewModel : observa
    NotaViewModel --> Nota : gerencia
```

## Mudanças principais (MVP)

### Modelo Nota
- **Removido:** `DateTime? apagadaEm`
- **Adicionado:** `bool isApagada` (soft delete com countdown 30 dias)
- **Estados:** Agora são independentes (`isFavorita`, `isArquivada`, `isApagada`)
- **Serialização:** `toMap()` e `fromMap()` para persistência Hive

### ViewModel
- **Novo:** `_notaEmEdicao` — rastreia nota em edição
- **Novos métodos:** `desarquivarNota()`, `deletarPermanentemente()`, `setNotaEmEdicao()`
- **Refatorado:** `restaurarNota()` — mantém estado `isArquivada` ao restaurar
- **Refatorado:** getters filtrados agora usam `isApagada` em lugar de `apagadaEm`

### Views
- **HomeView:** Menu dinâmico por aba, `PopupMenuButton` para posicionamento correto
- **EditorView:** Envolvida em `Consumer` para escutar mudanças, botão favorita funcional, bottom sheet de informações

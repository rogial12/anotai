# Anotai

Um app de anotações offline-first construído com Flutter como projeto de aprendizado prático.

## Sobre

Anotai é um exercício pedagógico: um app real sendo desenvolvido do zero com foco em
arquitetura de software, boas práticas e versionamento com Git.

## Status

**MVP completo** — todas as funcionalidades principais estão implementadas e funcionais.

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
- Permanece por tempo indeterminado (futura implementação de countdown 30 dias)
- Restauração mantém estado anterior (se era arquivada, volta ao arquivo)
- Exclusão permanente com um clique

✅ **Interface**
- Três abas: Anotações, Arquivo, Lixeira
- Menu de contexto dinâmico por aba
- Botão de informações com data de criação (DD-MM-AAAA)
- Indicador visual de favoritas (estrela)

**Planejado para o futuro (Fase 2+)**
- Busca por título ou conteúdo
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

Padrão **MVVM** (Model-View-ViewModel), com camadas bem definidas:

```
lib/
├── models/         # Nota: classe de dados com serialização
├── repositories/   # NotaRepository (interface) + LocalNotaRepository (Hive)
├── viewmodels/     # NotaViewModel: lógica de estado, ChangeNotifier
├── views/          # HomeView, EditorView: UI com Consumer<ViewModel>
└── main.dart       # Inicialização (Hive, Provider, app raiz)
```

### Padrões utilizados

- **Repository Pattern** — abstração entre lógica e persistência
- **Soft Delete** — exclusão lógica com flag `isApagada` (futuro: countdown 30 dias)
- **Change Notifier** — reatividade: Views escutam mudanças no ViewModel
- **Debounce** — salvamento automático após 5s de inatividade
- **Injeção de Dependência** — ViewModel recebe Repository no construtor

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
│   ├── models/nota.dart              # Modelo com toMap/fromMap
│   ├── repositories/
│   │   ├── nota_repository.dart      # Interface (contrato)
│   │   └── local_nota_repository.dart # Implementação Hive
│   ├── viewmodels/nota_viewmodel.dart # Lógica + estado reativo
│   ├── views/
│   │   ├── home_view.dart            # Tela principal (3 abas)
│   │   └── editor_view.dart          # Tela de criação/edição
│   └── main.dart                     # Entry point
├── pubspec.yaml                      # Dependências (hive, provider)
├── docs/diagrama.md                  # Diagrama de classes (Mermaid)
└── README.md                         # Este arquivo
```

## Próximos passos (Roadmap)

**Fase 2 — Melhorias MVP**
- Busca com filtro em tempo real
- Aba "Favoritas"
- Diálogos de confirmação antes de deletar
- Countdown 30 dias na lixeira

**Fase 3 — Features avançadas**
- Lock/unlock com modo read-only
- Histórico de versões (git-like)
- Suporte a imagens
- Tags/categorias

**Fase 4 — Multiplataforma**
- App Android nativo
- Sincronização em nuvem
- Suporte offline-first com sync

## Notas de desenvolvimento

- Commits direto na `main` durante MVP (migrar para feature branches + PRs na Fase 2)
- Todos os métodos têm comentários explicativos (educacional)
- Estado reativo via `Consumer<NotaViewModel>` — View não precisa saber de persistência
- Testes ainda não implementados (foco em funcionalidade + aprendizado)

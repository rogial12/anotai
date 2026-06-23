import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/nota_viewmodel.dart';
import '../../models/nota.dart';
import 'editor_view.dart';
import '../components/home/empty_state.dart';
import '../components/home/section_header.dart';
import '../components/home/note_tile.dart';
import '../components/home/dock_bar.dart';
import '../components/home/home_header.dart';
import '../styles/app_theme.dart';

/// HomeView é a tela principal do app, onde o usuário vê todas as suas notas.
///
/// Estrutura:
/// - AppBar no topo com título e botão de busca (placeholder)
/// - Body com abas (via BottomNavigationBar): Anotações, Arquivo, Lixeira
/// - Cada aba exibe uma lista de notas diferentes
/// - Cada nota tem um botão de favorita e um menu de opções (três pontos)
/// - FAB (botão flutuante) para criar nova nota
///
/// É um StatefulWidget porque precisa rastrear qual aba está ativa.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Rastreia qual aba está selecionada: 0 = Anotações, 1 = Arquivo, 2 = Lixeira
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.paper,
      // Body: conteúdo principal que muda baseado na aba selecionada
      body: Consumer<NotaViewModel>(
        builder: (context, viewModel, _) {
          // Determine qual lista de notas mostrar baseado na aba selecionada
          List<Nota> notasParaExibir;
          String tituloSecao;

          if (_selectedTabIndex == 0) {
            notasParaExibir = viewModel.notas;
            tituloSecao = 'Anotações';
          } else if (_selectedTabIndex == 1) {
            notasParaExibir = viewModel.arquivadas;
            tituloSecao = 'Arquivo';
          } else {
            notasParaExibir = viewModel.lixeira;
            tituloSecao = 'Lixeira';
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header do app: wordmark + busca + configurações
              HomeHeader(
                onSettings: () {
                  // TODO: navegar para SettingsView
                },
              ),

              // Cabeçalho da seção: título + contador (sempre visível)
              SectionHeader(
                title: tituloSecao,
                count: notasParaExibir.length,
              ),

              // Conteúdo: estado vazio ou lista de notas
              if (notasParaExibir.isEmpty)
                Expanded(child: EmptyState(tabIndex: _selectedTabIndex))
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: notasParaExibir.length,
                    itemBuilder: (context, index) {
                      final nota = notasParaExibir[index];
                      return NoteTile(
                        nota: nota,
                        isLixeira: _selectedTabIndex == 2,
                        onTap: () {
                          viewModel.setNotaEmEdicao(nota);
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const EditorView()),
                          );
                        },
                        onToggleFavorita: () => viewModel.toggleFavorita(nota),
                        onRestore: () => viewModel.restaurarNota(nota),
                        menuItems: _buildContextMenuItems(viewModel, nota, _selectedTabIndex),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: DockBar(
        selectedIndex: _selectedTabIndex,
        onTabChanged: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<NotaViewModel>(context, listen: false)
              .setNotaEmEdicao(null);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const EditorView()),
          );
        },
        backgroundColor: AppTheme.accent,
        foregroundColor: AppTheme.accentFg,
        tooltip: 'Nova nota',
        child: const Icon(Icons.edit_outlined),
      ),
    );
  }

  /// _showDeleteUndoSnackBar: exibe SnackBar com opção de desfazer exclusão
  ///
  /// Fluxo (ESTÁGIO 1 — Soft Delete):
  /// 1. Mostra SnackBar com mensagem "Nota movida para a lixeira"
  /// 2. Botão "Desfazer" chama restaurarNota() — reverte o soft delete
  /// 3. Duração: 4 segundos (consistente com debounce do projeto)
  ///
  /// Recebe:
  /// - viewModel: referência ao ViewModel para chamar restaurarNota()
  /// - nota: nota que foi soft-deletada
  void _showDeleteUndoSnackBar(NotaViewModel viewModel, Nota nota) {
    // Remove qualquer SnackBar anterior que esteja na fila
    // Isso garante que apenas uma SnackBar é exibida por vez
    ScaffoldMessenger.of(context).clearSnackBars();

    // Exibe SnackBar com opção de desfazer por 4 segundos
    final snackBar = SnackBar(
      content: const Text('Nota movida para a lixeira'),
      duration: const Duration(seconds: 4),
      // Ação no SnackBar: botão "Desfazer"
      action: SnackBarAction(
        label: 'Desfazer',
        // Quando toca, restaura a nota (reverte o soft delete)
        onPressed: () {
          viewModel.restaurarNota(nota);
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    // Force dismiss após 4 segundos se o usuário não clicar em Desfazer
    // (garante que a SnackBar some mesmo se houver rebuilds)
    Future.delayed(const Duration(seconds: 4), () {
      // Verifica se o widget ainda está na árvore antes de acessar context
      // Evita erro se a tela foi fechada durante o delay
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });
  }

  /// _buildContextMenuItems: constrói a lista de opções do menu
  ///
  /// O menu muda baseado na aba selecionada:
  /// - Aba "Anotações": Arquivar, Enviar para lixeira (com SnackBar + Undo)
  /// - Aba "Arquivo": Desarquivar, Enviar para lixeira (com SnackBar + Undo)
  /// - Aba "Lixeira": Excluir definitivamente (com Dialog de confirmação)
  ///
  /// Implementa o fluxo de exclusão em dois estágios:
  /// 1. Soft delete (move para lixeira): SnackBar com botão "Desfazer" por 4-5s
  /// 2. Hard delete (lixeira): Dialog de confirmação antes de executar
  ///
  /// Recebe:
  /// - viewModel: referência ao ViewModel para chamar as ações
  /// - nota: a nota sobre a qual o menu foi aberto
  /// - tabIndex: qual aba está ativa (0 = Anotações, 1 = Arquivo, 2 = Lixeira)
  List<PopupMenuEntry<String>> _buildContextMenuItems(
      NotaViewModel viewModel, Nota nota, int tabIndex) {
    if (tabIndex == 0) {
      // Aba "Anotações": notas comuns
      return <PopupMenuEntry<String>>[
        // Opção: Arquivar
        PopupMenuItem(
          onTap: () {
            // Arquiva a nota
            viewModel.arquivarNota(nota);
          },
          child: const Text('Arquivar'),
        ),
        // Separador visual
        const PopupMenuDivider(),
        // Opção: Enviar para lixeira (em vermelho)
        // ESTÁGIO 1: Soft delete com SnackBar + Undo
        PopupMenuItem(
          onTap: () {
            // Apaga a nota (move para lixeira)
            viewModel.apagarNota(nota);
            // Mostra SnackBar com opção de desfazer
            _showDeleteUndoSnackBar(viewModel, nota);
          },
          child: const Text(
            'Enviar para a lixeira',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ];
    } else if (tabIndex == 1) {
      // Aba "Arquivo": notas arquivadas
      return <PopupMenuEntry<String>>[
        // Opção: Desarquivar
        PopupMenuItem(
          onTap: () {
            // Desarchiva a nota
            viewModel.desarquivarNota(nota);
          },
          child: const Text('Desarquivar'),
        ),
        // Separador visual
        const PopupMenuDivider(),
        // Opção: Enviar para lixeira (em vermelho)
        // ESTÁGIO 1: Soft delete com SnackBar + Undo
        PopupMenuItem(
          onTap: () {
            // Apaga a nota (move para lixeira)
            viewModel.apagarNota(nota);
            // Mostra SnackBar com opção de desfazer
            _showDeleteUndoSnackBar(viewModel, nota);
          },
          child: const Text(
            'Enviar para a lixeira',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ];
    } else {
      // Aba "Lixeira": notas apagadas
      // ESTÁGIO 2: Hard delete com Dialog de confirmação
      return <PopupMenuEntry<String>>[
        // Opção: Excluir definitivamente (em vermelho)
        PopupMenuItem(
          onTap: () {
            // Abre Dialog de confirmação ANTES de executar a ação destrutiva
            _showDeleteConfirmationDialog(context, viewModel, nota);
          },
          child: const Text(
            'Excluir definitivamente',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ];
    }
  }

  /// _showDeleteConfirmationDialog: exibe Dialog de confirmação antes de hard delete
  ///
  /// Fluxo:
  /// 1. Abre Dialog perguntando se tem certeza
  /// 2. Se confirma: chama deletarPermanentemente() e fecha a nota
  /// 3. Se cancela: fecha o Dialog, nota permanece na lixeira
  ///
  /// Recebe:
  /// - context: contexto do Flutter
  /// - viewModel: referência ao ViewModel
  /// - nota: nota a ser excluída permanentemente
  void _showDeleteConfirmationDialog(
      BuildContext context, NotaViewModel viewModel, Nota nota) {
    // showDialog: exibe um Dialog modal
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // AlertDialog: Dialog padrão do Material Design
        return AlertDialog(
          // Título do Dialog
          title: const Text('Excluir permanentemente?'),
          // Conteúdo/mensagem principal
          content: const Text(
            'Esta ação não pode ser desfeita. Deseja excluir permanentemente esta nota?',
          ),
          // Botões do Dialog
          actions: [
            // Botão Cancelar (ação segura, padrão)
            TextButton(
              onPressed: () {
                // Fecha o Dialog sem fazer nada
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            // Botão Excluir (ação destrutiva, em vermelho)
            TextButton(
              onPressed: () {
                // Executa a exclusão permanente
                viewModel.deletarPermanentemente(nota);
                // Fecha o Dialog
                Navigator.of(context).pop();
                // Mostra SnackBar confirmando a exclusão
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nota excluída permanentemente'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              // Estilo para deixar o texto vermelho (destrutivo)
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }
}

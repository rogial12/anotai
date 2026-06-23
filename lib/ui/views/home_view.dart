import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/nota_viewmodel.dart';
import '../../models/nota.dart';
import 'editor_view.dart';
import '../components/home/empty_state.dart';

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
      // AppBar: barra no topo com título e botão de busca
      appBar: AppBar(
        title: const Text('Anotai'),
        actions: [
          // Botão de busca na extremidade direita do AppBar (placeholder por enquanto)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implementar lógica de busca na Fase 2
            },
            tooltip: 'Buscar',
          ),
        ],
      ),
      // Body: conteúdo principal que muda baseado na aba selecionada
      body: Consumer<NotaViewModel>(
        builder: (context, viewModel, _) {
          // Determine qual lista de notas mostrar baseado na aba selecionada
          List<Nota> notasParaExibir;

          if (_selectedTabIndex == 0) {
            // Aba "Anotações": mostra notas ativas (não arquivadas, não apagadas)
            notasParaExibir = viewModel.notas;
          } else if (_selectedTabIndex == 1) {
            // Aba "Arquivo": mostra apenas notas arquivadas (não apagadas)
            notasParaExibir = viewModel.arquivadas;
          } else {
            // Aba "Lixeira": mostra apenas notas apagadas
            notasParaExibir = viewModel.lixeira;
          }

          // Se não há notas nessa aba, exibe mensagem vazia
          if (notasParaExibir.isEmpty) {
            return EmptyState(tabIndex: _selectedTabIndex);
          }

          // Lista as notas da aba selecionada
          return ListView.builder(
            // itemCount: quantidade de notas a exibir
            itemCount: notasParaExibir.length,
            // itemBuilder: constrói cada item da lista
            itemBuilder: (context, index) {
              // Pega a nota no índice atual
              final nota = notasParaExibir[index];

              // ListTile é um widget que representa uma linha na lista
              return ListTile(
                // Título da nota (vai no topo da linha)
                title: Text(nota.titulo),
                // Subtítulo da nota (vai abaixo do título, em texto menor/desbotado)
                subtitle: Text(nota.conteudo),
                // Trailing: widget no final da linha (extremidade direita)
                // Aqui colocamos o botão de favorita, restaurar (se lixeira), e menu de opções
                trailing: Row(
                  // mainAxisSize: deixar a Row compacta (ocupar só o espaço necessário)
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botão de favorita (estrela)
                    // Quando toca, chama toggleFavorita do viewModel
                    IconButton(
                      icon: Icon(
                        // Se a nota é favorita, mostra estrela preenchida; senão, vazia
                        nota.isFavorita
                            ? Icons.star
                            : Icons.star_border,
                      ),
                      // Se favorita, cor amarela; senão, cor padrão
                      color: nota.isFavorita ? Colors.amber : null,
                      onPressed: () {
                        // Chama o método do viewModel que inverte o estado de favorita
                        viewModel.toggleFavorita(nota);
                      },
                      tooltip: nota.isFavorita
                          ? 'Remover de favoritos'
                          : 'Adicionar aos favoritos',
                    ),

                    // Botão de restaurar (apenas na aba Lixeira)
                    // Aparece só se _selectedTabIndex == 2 (Lixeira)
                    if (_selectedTabIndex == 2)
                      IconButton(
                        icon: const Icon(Icons.restore),
                        onPressed: () {
                          // Restaura a nota da lixeira
                          // Importante: mantém isArquivada, então volta para o lugar certo
                          viewModel.restaurarNota(nota);
                        },
                        tooltip: 'Restaurar',
                      ),

                    // Botão de opções (três pontos verticais)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      tooltip: 'Mais opções',
                      // itemBuilder: constrói o menu baseado na aba selecionada
                      itemBuilder: (BuildContext context) {
                        return _buildContextMenuItems(viewModel, nota, _selectedTabIndex);
                      },
                    ),
                  ],
                ),
                // onTap: quando toca na nota (em qualquer lugar exceto os botões), edita
                onTap: () {
                  // Define que essa nota está sendo editada
                  viewModel.setNotaEmEdicao(nota);
                  // Navega para a EditorView
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditorView()),
                  );
                },
              );
            },
          );
        },
      ),
      // BottomNavigationBar: barra com abas na base da tela
      bottomNavigationBar: BottomNavigationBar(
        // currentIndex: qual aba está selecionada
        currentIndex: _selectedTabIndex,
        // onTap: chamado quando o usuário toca numa aba
        onTap: (index) {
          // Atualiza o índice da aba selecionada
          // setState reconstrói o widget com o novo índice
          setState(() {
            _selectedTabIndex = index;
          });
        },
        // items: lista de abas
        items: const [
          // Aba 1: Anotações
          BottomNavigationBarItem(
            icon: Icon(Icons.note),
            label: 'Anotações',
          ),
          // Aba 2: Arquivo
          BottomNavigationBarItem(
            icon: Icon(Icons.archive),
            label: 'Arquivo',
          ),
          // Aba 3: Lixeira
          BottomNavigationBarItem(
            icon: Icon(Icons.delete),
            label: 'Lixeira',
          ),
        ],
      ),
      // FAB: botão flutuante para criar nova nota
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Limpa a nota em edição (null = modo criação)
          Provider.of<NotaViewModel>(context, listen: false)
              .setNotaEmEdicao(null);
          // Navega para a EditorView em modo criação
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const EditorView()),
          );
        },
        tooltip: 'Nova nota',
        child: const Icon(Icons.add),
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

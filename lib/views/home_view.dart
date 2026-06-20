import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/nota_viewmodel.dart';
import '../models/nota.dart';
import 'editor_view.dart';

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
            return Center(
              child: Text(
                // Mensagem personalizadas por aba
                _selectedTabIndex == 0
                    ? 'Nenhuma nota ainda.'
                    : _selectedTabIndex == 1
                        ? 'Nenhuma nota arquivada.'
                        : 'Lixeira vazia.',
              ),
            );
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
                    // Usa PopupMenuButton que gerencia a posição automaticamente
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

  /// _buildContextMenuItems: constrói a lista de opções do menu
  ///
  /// Retorna diferentes opções baseado na aba selecionada:
  /// - Aba "Anotações": Arquivar, Enviar para lixeira
  /// - Aba "Arquivo": Desarquivar, Enviar para lixeira
  /// - Aba "Lixeira": Excluir definitivamente
  ///
  /// É chamado pelo PopupMenuButton, que gerencia a posição automaticamente
  ///
  /// Recebe:
  /// - viewModel: referência ao ViewModel para chamar as ações
  /// - nota: a nota sobre a qual o menu foi aberto
  /// - tabIndex: qual aba está ativa (0 = Anotações, 1 = Arquivo, 2 = Lixeira)
  ///
  /// Retorna:
  /// - Lista de PopupMenuEntry com as opções
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
        PopupMenuItem(
          onTap: () {
            // Apaga a nota (move para lixeira)
            viewModel.apagarNota(nota);
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
        PopupMenuItem(
          onTap: () {
            // Apaga a nota (move para lixeira)
            viewModel.apagarNota(nota);
          },
          child: const Text(
            'Enviar para a lixeira',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ];
    } else {
      // Aba "Lixeira": notas apagadas
      return <PopupMenuEntry<String>>[
        // Opção: Excluir definitivamente (em vermelho)
        PopupMenuItem(
          onTap: () {
            // Exclui permanentemente do banco
            viewModel.deletarPermanentemente(nota);
          },
          child: const Text(
            'Excluir definitivamente',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ];
    }
  }
}

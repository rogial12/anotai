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

          return Column(
            children: [
              _buildHeader(context, viewModel),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _clampPadding(20, 4, 48),
                      vertical: 24,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 920),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              tabLabels[_selectedTabIndex],
                              notasParaExibir.length,
                            ),
                            const SizedBox(height: 16),
                            if (notasParaExibir.isEmpty)
                              _buildEmptyState(_selectedTabIndex)
                            else
                              _buildNotesList(context, viewModel, notasParaExibir),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer<NotaViewModel>(
        builder: (context, viewModel, _) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 22, left: 20, right: 20),
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: AppTheme.shadowMedium,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == index
                                ? AppTheme.accentWeak
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                tabIcons[index],
                                color: _selectedTabIndex == index
                                    ? AppTheme.accent
                                    : AppTheme.muted,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                tabLabels[index],
                                style: TextStyle(
                                  fontFamily: 'Hanken Grotesk',
                                  fontSize: 14,
                                  fontWeight: _selectedTabIndex == index
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: _selectedTabIndex == index
                                      ? AppTheme.accent
                                      : AppTheme.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, NotaViewModel viewModel) {
    return Container(
      color: AppTheme.card,
      padding: EdgeInsets.only(
        left: _clampPadding(20, 4, 48),
        right: _clampPadding(20, 4, 48),
        top: _clampPadding(22, 3, 34),
        bottom: 16,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Anotai',
                  style: TextStyle(
                    fontFamily: 'Bricolage Grotesque',
                    fontSize: _clampFontSize(27, 3, 35),
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.025,
                    color: AppTheme.ink,
                  ),
                ),
                const Spacer(),
                Container(
                  width: _clampPadding(170, 22, 250),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppTheme.line, width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppTheme.faint,
                        size: 18,
                      ),
                      hintText: 'Buscar',
                      hintStyle: const TextStyle(
                        fontFamily: 'Hanken Grotesk',
                        fontSize: 14.5,
                        color: AppTheme.faint,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 0,
                      ),
                    ),
                    style: const TextStyle(
                      fontFamily: 'Hanken Grotesk',
                      fontSize: 14.5,
                      color: AppTheme.ink,
                    ),
                    onChanged: (value) {
                      // TODO: Implementar filtro de busca na Fase 2
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Provider.of<NotaViewModel>(context, listen: false)
                        .setNotaEmEdicao(null);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EditorView()),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Nova nota'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppTheme.accentWeak,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'I',
                      style: TextStyle(
                        fontFamily: 'Bricolage Grotesque',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Olá, Igor',
                style: const TextStyle(
                  fontFamily: 'Hanken Grotesk',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String sectionName, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              sectionName,
              style: const TextStyle(
                fontFamily: 'Bricolage Grotesque',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.01,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$count ${count == 1 ? 'nota' : 'notas'}',
              style: const TextStyle(
                fontFamily: 'Hanken Grotesk',
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: AppTheme.faint,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 1,
          color: AppTheme.line,
        ),
      ],
    );
  }

  Widget _buildEmptyState(int tabIndex) {
    final messages = [
      'Nenhuma nota ainda.',
      'Nenhuma nota arquivada.',
      'Lixeira vazia.',
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(
              Icons.note_outlined,
              size: 48,
              color: AppTheme.faint,
            ),
            const SizedBox(height: 16),
            Text(
              messages[tabIndex],
              style: const TextStyle(
                fontFamily: 'Hanken Grotesk',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppTheme.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesList(
    BuildContext context,
    NotaViewModel viewModel,
    List<Nota> notas,
  ) {
    return Column(
      children: List.generate(
        notas.length,
        (index) {
          final nota = notas[index];
          return _buildNoteTile(context, viewModel, nota);
        },
      ),
    );
  }

  Widget _buildNoteTile(
    BuildContext context,
    NotaViewModel viewModel,
    Nota nota,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppTheme.line, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            viewModel.setNotaEmEdicao(nota);
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EditorView()),
            );
          },
          borderRadius: BorderRadius.circular(13),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 17),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (nota.isFavorita)
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: Icon(
                                Icons.star,
                                size: 15,
                                color: AppTheme.amber,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              nota.titulo.isEmpty ? '(sem título)' : nota.titulo,
                              style: const TextStyle(
                                fontFamily: 'Bricolage Grotesque',
                                fontSize: 16.5,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.005,
                                color: AppTheme.ink,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nota.conteudo,
                        style: const TextStyle(
                          fontFamily: 'Hanken Grotesk',
                          fontSize: 14.5,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.muted,
                          height: 1.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${nota.criadaEm.day} ${_monthName(nota.criadaEm.month)}',
                      style: const TextStyle(
                        fontFamily: 'Hanken Grotesk',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.faint,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_selectedTabIndex == 2)
                          IconButton(
                            onPressed: () {
                              viewModel.restaurarNota(nota);
                            },
                            icon: const Icon(Icons.restore),
                            color: AppTheme.muted,
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            tooltip: 'Restaurar',
                          )
                        else
                          IconButton(
                            onPressed: () {
                              viewModel.toggleFavorita(nota);
                            },
                            icon: Icon(
                              nota.isFavorita ? Icons.star : Icons.star_border,
                              color: nota.isFavorita ? AppTheme.amber : AppTheme.faint,
                            ),
                            iconSize: 18,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            tooltip: nota.isFavorita
                                ? 'Remover de favoritos'
                                : 'Adicionar aos favoritos',
                          ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          color: AppTheme.card,
                          iconSize: 18,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          itemBuilder: (BuildContext context) {
                            return _buildContextMenuItems(viewModel, nota);
                          },
                        ),
                      ],
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

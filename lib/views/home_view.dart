import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../viewmodels/nota_viewmodel.dart';
import '../models/nota.dart';
import 'editor_view.dart';

/// HomeView: tela principal do Anotai, seguindo o handoff do Claude Design
///
/// Layout editorial: header com wordmark + saudação + busca + avatar,
/// lista de notas com 3 seções (Anotações, Arquivo, Lixeira), dock flutuante na base.
///
/// Design tokens: fundo creme quente (paper), texto quase-preto (ink), destaque terracota (accent).
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedTabIndex = 0;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Usa clamp para responsividade: clamp(minSize, percentualVw, maxSize)
  double _clampPadding(double min, double vwPercent, double max) {
    final screenWidth = MediaQuery.of(context).size.width;
    final vwValue = screenWidth * (vwPercent / 100);
    return vwValue.clamp(min, max);
  }

  double _clampFontSize(double min, double vwPercent, double max) {
    final screenWidth = MediaQuery.of(context).size.width;
    final vwValue = screenWidth * (vwPercent / 100);
    return vwValue.clamp(min, max);
  }

  @override
  Widget build(BuildContext context) {
    final tabLabels = ['Anotações', 'Arquivo', 'Lixeira'];
    final tabIcons = [Icons.list, Icons.archive, Icons.delete];

    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: Consumer<NotaViewModel>(
        builder: (context, viewModel, _) {
          List<Nota> notasParaExibir;
          if (_selectedTabIndex == 0) {
            notasParaExibir = viewModel.notas;
          } else if (_selectedTabIndex == 1) {
            notasParaExibir = viewModel.arquivadas;
          } else {
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildContextMenuItems(
    NotaViewModel viewModel,
    Nota nota,
  ) {
    if (_selectedTabIndex == 0) {
      return <PopupMenuEntry<String>>[
        PopupMenuItem(
          onTap: () {
            viewModel.arquivarNota(nota);
          },
          child: const Text('Arquivar'),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          onTap: () {
            viewModel.apagarNota(nota);
            _showDeleteUndoSnackBar(viewModel, nota);
          },
          child: const Text(
            'Enviar para a lixeira',
            style: TextStyle(color: AppTheme.danger),
          ),
        ),
      ];
    } else if (_selectedTabIndex == 1) {
      return <PopupMenuEntry<String>>[
        PopupMenuItem(
          onTap: () {
            viewModel.desarquivarNota(nota);
          },
          child: const Text('Desarquivar'),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          onTap: () {
            viewModel.apagarNota(nota);
            _showDeleteUndoSnackBar(viewModel, nota);
          },
          child: const Text(
            'Enviar para a lixeira',
            style: TextStyle(color: AppTheme.danger),
          ),
        ),
      ];
    } else {
      return <PopupMenuEntry<String>>[
        PopupMenuItem(
          onTap: () {
            _showDeleteConfirmationDialog(context, viewModel, nota);
          },
          child: const Text(
            'Excluir definitivamente',
            style: TextStyle(color: AppTheme.danger),
          ),
        ),
      ];
    }
  }

  void _showDeleteUndoSnackBar(NotaViewModel viewModel, Nota nota) {
    ScaffoldMessenger.of(context).clearSnackBars();

    final snackBar = SnackBar(
      content: const Text('Nota movida para a lixeira'),
      duration: const Duration(seconds: 4),
      action: SnackBarAction(
        label: 'Desfazer',
        onPressed: () {
          viewModel.restaurarNota(nota);
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    });
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    NotaViewModel viewModel,
    Nota nota,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Excluir permanentemente?'),
          content: const Text(
            'Esta ação não pode ser desfeita. Deseja excluir permanentemente esta nota?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                viewModel.deletarPermanentemente(nota);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nota excluída permanentemente'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.danger,
              ),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  String _monthName(int month) {
    const months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez'
    ];
    return months[month - 1];
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../viewmodels/nota_viewmodel.dart';
import '../theme/app_theme.dart';

/// EditorView: tela de criação e edição de notas seguindo o handoff do Claude Design
///
/// Layout editorial:
/// - Header sticky com backdrop-filter (blur 8px), back button, status line, favorita, info, opções, save
/// - Área principal: textarea de título (auto-height), meta line (data + word count), textarea de conteúdo
/// - Popover de informações (270px, ancorado ao botão info)
/// - Salvamento automático com debounce 5 segundos
class EditorView extends StatefulWidget {
  const EditorView({super.key});

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late NotaViewModel _viewModel;
  Timer? _debounceTimer;
  bool _hasChanges = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<NotaViewModel>(context, listen: false);
    final notaEmEdicao = _viewModel.notaEmEdicao;

    _titleController = TextEditingController(
      text: notaEmEdicao?.titulo ?? '',
    );

    _contentController = TextEditingController(
      text: notaEmEdicao?.conteudo ?? '',
    );

    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() => _hasChanges = true);
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 900), _saveAutomatically);
  }

  Future<void> _saveAutomatically() async {
    if (!_hasChanges) return;
    final notaEmEdicao = _viewModel.notaEmEdicao;

    try {
      setState(() => _isSaving = true);

      if (notaEmEdicao == null) {
        await _viewModel.criarNota(
          titulo: _titleController.text,
          conteudo: _contentController.text,
        );
        _viewModel.setNotaEmEdicao(
          _viewModel.notas.firstWhere(
            (n) => n.titulo == _titleController.text,
          ),
        );
      } else {
        await _viewModel.editarNota(
          notaEmEdicao,
          titulo: _titleController.text,
          conteudo: _contentController.text,
        );
      }

      _hasChanges = false;
    } catch (e) {
      print('Erro ao salvar: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _saveAndClose() async {
    _debounceTimer?.cancel();
    await _saveAutomatically();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  int _getWordCount() {
    final text = _contentController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  int _getCharCount() {
    return _contentController.text.length;
  }

  String _formatDate(DateTime date) {
    const months = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
    ];
    return '${date.day} de ${months[date.month - 1]}';
  }

  void _showInfoPopover(BuildContext context) {
    final notaEmEdicao = _viewModel.notaEmEdicao;
    if (notaEmEdicao == null) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: offset.dy + size.height + 8,
          right: 20,
          child: GestureDetector(
            onTap: () => entry.remove(),
            child: Container(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: 270,
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: AppTheme.line, width: 1),
                    boxShadow: AppTheme.shadowMedium,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informações da nota',
                        style: const TextStyle(
                          fontFamily: 'Bricolage Grotesque',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.005,
                          color: AppTheme.ink,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(height: 1, color: AppTheme.line2),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: AppTheme.faint,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _formatDate(notaEmEdicao.criadaEm),
                              style: const TextStyle(
                                fontFamily: 'Hanken Grotesk',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.description,
                            size: 14,
                            color: AppTheme.faint,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${_getWordCount()} palavra${_getWordCount() == 1 ? '' : 's'}',
                              style: const TextStyle(
                                fontFamily: 'Hanken Grotesk',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.text_fields,
                            size: 14,
                            color: AppTheme.faint,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${_getCharCount()} caractere${_getCharCount() == 1 ? '' : 's'}',
                              style: const TextStyle(
                                fontFamily: 'Hanken Grotesk',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 10), () {
      entry.remove();
    });
  }

  List<PopupMenuEntry<String>> _buildContextMenuItems() {
    final notaEmEdicao = _viewModel.notaEmEdicao;
    if (notaEmEdicao == null) return [];

    if (notaEmEdicao.isApagada) {
      return <PopupMenuEntry<String>>[
        PopupMenuItem(
          onTap: () {
            _viewModel.restaurarNota(notaEmEdicao);
            Navigator.of(context).pop();
          },
          child: const Text('Restaurar'),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          onTap: () {
            _viewModel.deletarPermanentemente(notaEmEdicao);
            Navigator.of(context).pop();
          },
          child: const Text(
            'Excluir definitivamente',
            style: TextStyle(color: AppTheme.danger),
          ),
        ),
      ];
    } else if (notaEmEdicao.isArquivada) {
      return <PopupMenuEntry<String>>[
        PopupMenuItem(
          onTap: () {
            _viewModel.desarquivarNota(notaEmEdicao);
            Navigator.of(context).pop();
          },
          child: const Text('Desarquivar'),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          onTap: () {
            _viewModel.apagarNota(notaEmEdicao);
            Navigator.of(context).pop();
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
            _viewModel.arquivarNota(notaEmEdicao);
            Navigator.of(context).pop();
          },
          child: const Text('Arquivar'),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          onTap: () {
            _viewModel.apagarNota(notaEmEdicao);
            Navigator.of(context).pop();
          },
          child: const Text(
            'Enviar para a lixeira',
            style: TextStyle(color: AppTheme.danger),
          ),
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotaViewModel>(
      builder: (context, viewModel, _) {
        final notaEmEdicao = viewModel.notaEmEdicao;
        final isCreating = notaEmEdicao == null;
        final isFavorita = notaEmEdicao?.isFavorita ?? false;

        return Scaffold(
          backgroundColor: AppTheme.paper,
          body: Stack(
            children: [
              // Conteúdo principal (scrollável)
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 120),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 28,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 720),
                        child: Column(
                          children: [
                            // Textarea do título (auto-height)
                            TextField(
                              controller: _titleController,
                              minLines: 1,
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: isCreating ? 'Título' : null,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                hintStyle: TextStyle(
                                  fontFamily: 'Bricolage Grotesque',
                                  fontSize: _clampFontSize(25, 3.2, 33),
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.02,
                                  color: AppTheme.faint,
                                ),
                              ),
                              style: TextStyle(
                                fontFamily: 'Bricolage Grotesque',
                                fontSize: _clampFontSize(25, 3.2, 33),
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.02,
                                height: 1.2,
                                color: AppTheme.ink,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Meta line: data + word count + caracteres
                            Row(
                              children: [
                                if (!isCreating)
                                  Text(
                                    _formatDate(notaEmEdicao.criadaEm),
                                    style: const TextStyle(
                                      fontFamily: 'Hanken Grotesk',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                      color: AppTheme.faint,
                                      fontFeatures: [FontFeature.tabularFigures()],
                                    ),
                                  ),
                                if (!isCreating) const SizedBox(width: 16),
                                Text(
                                  '${_getWordCount()} palavra${_getWordCount() == 1 ? '' : 's'}',
                                  style: const TextStyle(
                                    fontFamily: 'Hanken Grotesk',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.faint,
                                    fontFeatures: [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Divider
                            Container(height: 1, color: AppTheme.line),

                            const SizedBox(height: 24),

                            // Textarea de conteúdo (min-height 50vh)
                            TextField(
                              controller: _contentController,
                              minLines: 30,
                              maxLines: null,
                              decoration: InputDecoration(
                                hintText: isCreating
                                    ? 'Escreva sua nota aqui...'
                                    : null,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                hintStyle: const TextStyle(
                                  fontFamily: 'Hanken Grotesk',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  height: 1.78,
                                  color: AppTheme.faint,
                                ),
                              ),
                              style: const TextStyle(
                                fontFamily: 'Hanken Grotesk',
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                height: 1.78,
                                color: AppTheme.ink,
                              ),
                            ),

                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Header sticky (sobreposto)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    border: Border(
                      bottom: BorderSide(color: AppTheme.line, width: 1),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          // Back button com borda
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.line, width: 1),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back),
                              iconSize: 18,
                              color: AppTheme.ink,
                              onPressed: _saveAndClose,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Status line: "Nova nota" ou "Editar nota" + save indicator
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      isCreating ? 'Nova nota' : 'Editar nota',
                                      style: const TextStyle(
                                        fontFamily: 'Hanken Grotesk',
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.ink,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (_isSaving || _hasChanges)
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: _isSaving
                                              ? AppTheme.amber
                                              : AppTheme.danger,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _isSaving
                                      ? 'Salvando...'
                                      : _hasChanges
                                          ? 'Não salvo'
                                          : 'Salvo',
                                  style: TextStyle(
                                    fontFamily: 'Hanken Grotesk',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: _isSaving
                                        ? AppTheme.amber
                                        : _hasChanges
                                            ? AppTheme.danger
                                            : AppTheme.saved,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Botão favorita (apenas em edição)
                          if (!isCreating)
                            IconButton(
                              icon: Icon(
                                isFavorita ? Icons.star : Icons.star_border,
                                color: isFavorita ? AppTheme.amber : AppTheme.faint,
                              ),
                              iconSize: 18,
                              onPressed: () {
                                viewModel.toggleFavorita(notaEmEdicao);
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                            ),

                          // Botão info (popover)
                          IconButton(
                            icon: const Icon(Icons.info_outline),
                            iconSize: 18,
                            color: AppTheme.muted,
                            onPressed: () {
                              _showInfoPopover(context);
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            tooltip: 'Informações',
                          ),

                          // Botão opções
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            iconSize: 18,
                            color: AppTheme.card,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                            itemBuilder: (BuildContext context) {
                              return _buildContextMenuItems();
                            },
                          ),

                          const SizedBox(width: 12),

                          // Botão salvar (primário)
                          ElevatedButton.icon(
                            onPressed: _saveAndClose,
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Salvar'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _clampFontSize(double min, double vwPercent, double max) {
    final screenWidth = MediaQuery.of(context).size.width;
    final vwValue = screenWidth * (vwPercent / 100);
    return vwValue.clamp(min, max);
  }
}

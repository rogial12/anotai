import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../viewmodels/nota_viewmodel.dart';
import '../components/editor/editor_header.dart';
import '../styles/app_theme.dart';
import '../utils/formatters.dart';

/// EditorView é a tela onde o usuário cria e edita notas.
///
/// Comportamento:
/// - Se notaEmEdicao == null: modo criação (campos vazios)
/// - Se notaEmEdicao != null: modo edição (campos preenchidos com dados da nota)
///
/// Salvamento automático:
/// - A cada digitação, inicia um timer de 5 segundos
/// - Se o usuário parar de digitar por 5 segundos, a nota é salva automaticamente
/// - Se o usuário sair da tela antes do timer completar, força salvamento imediato
///
/// É um StatefulWidget porque precisa gerenciar os TextEditingController e o Timer.
class EditorView extends StatefulWidget {
  const EditorView({super.key});

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  // Controller para o campo de título (rastreia o texto digitado)
  late TextEditingController _titleController;

  // Controller para o campo de conteúdo (rastreia o texto digitado)
  late TextEditingController _contentController;

  // Referência ao ViewModel para acessar os dados e métodos
  late NotaViewModel _viewModel;

  // Timer para debounce de salvamento automático
  // Quando o usuário para de digitar por 5 segundos, o timer "queima" e salva
  Timer? _debounceTimer;

  /// initState: chamado quando o widget é criado
  ///
  /// Responsabilidades:
  /// 1. Recuperar o ViewModel do Provider
  /// 2. Criar os TextEditingController
  /// 3. Preencher os controllers com dados (se editando) ou deixar vazios (se criando)
  /// 4. Adicionar listeners aos controllers para detectar mudanças
  @override
  void initState() {
    super.initState();

    // Obtém o ViewModel do contexto (sem escutar mudanças, só leitura)
    _viewModel = Provider.of<NotaViewModel>(context, listen: false);

    // Recupera a nota que está sendo editada (null se está criando)
    final notaEmEdicao = _viewModel.notaEmEdicao;

    // Cria o controller do título
    // Se está editando, preenche com o título existente; senão, vazio ('')
    _titleController = TextEditingController(
      text: notaEmEdicao?.titulo ?? '',
    );

    // Cria o controller do conteúdo
    // Se está editando, preenche com o conteúdo existente; senão, vazio ('')
    _contentController = TextEditingController(
      text: notaEmEdicao?.conteudo ?? '',
    );

    // Adiciona listener ao title controller: chamado toda vez que o texto muda
    _titleController.addListener(_onTextChanged);

    // Adiciona listener ao content controller: chamado toda vez que o texto muda
    _contentController.addListener(_onTextChanged);
  }

  /// _onTextChanged: reinicia o debounce a cada digitação
  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 5), _saveAutomatically);
  }

  Future<void> _saveAutomatically() async {
    await _viewModel.salvarNota(
      titulo: _titleController.text,
      conteudo: _contentController.text,
    );
  }

  /// _saveAndClose: salva a nota imediatamente e fecha a tela
  ///
  /// Chamado quando:
  /// - Usuário clica no botão de check (salvar)
  /// - Usuário clica no FAB (salvar)
  /// - Usuário sai da tela (volta button no Android, por exemplo)
  ///
  /// Fluxo:
  /// 1. Cancela o timer de debounce (se houver um rodando)
  /// 2. Força salvamento imediato
  /// 3. Volta para a tela anterior (HomeView)
  Future<void> _saveAndClose() async {
    // Cancela o timer de debounce (se houve um rodando)
    // Isso garante que não vai salvar duas vezes
    _debounceTimer?.cancel();

    // Força o salvamento imediato (sem esperar 5 segundos)
    await _saveAutomatically();

    // Se o widget ainda está montado, navega de volta
    // (mounted evita erro se a tela foi destruída enquanto salvava)
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showInfoDialog(BuildContext context) {
    final nota = _viewModel.notaEmEdicao;
    if (nota == null) return;

    final totalText = '${_titleController.text} ${_contentController.text}';
    final words = wordCount(totalText);
    final chars = charCount(_titleController.text + _contentController.text);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(AppTheme.radiusMenu),
            boxShadow: AppTheme.shadowPopover,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Informações', style: AppTheme.sectionTitle),
              const SizedBox(height: 20),
              _infoRow('Criada em', formatDate(nota.criadaEm)),
              const SizedBox(height: 12),
              _infoRow('Última edição', formatDate(nota.atualizadaEm)),
              const SizedBox(height: 12),
              _infoRow('Palavras', '$words'),
              const SizedBox(height: 12),
              _infoRow('Caracteres', '$chars'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.meta),
        Text(value, style: AppTheme.notePreview.copyWith(color: AppTheme.ink)),
      ],
    );
  }

  /// _buildContextMenuItems: constrói a lista de opções do menu
  ///
  /// O menu muda baseado no estado da nota:
  /// - Se nota é comum: Arquivar, Enviar para lixeira
  /// - Se nota é arquivada: Desarquivar, Enviar para lixeira
  /// - Se nota está apagada: Restaurar, Excluir definitivamente
  ///
  /// É chamado pelo PopupMenuButton, que gerencia a posição automaticamente
  /// Se não há nota sendo editada (criando), retorna lista vazia
  ///
  /// Retorna:
  /// - Lista de PopupMenuEntry com as opções baseado no estado da nota
  List<PopupMenuEntry<String>> _buildContextMenuItems() {
    // Recupera a nota que está sendo editada
    final notaEmEdicao = _viewModel.notaEmEdicao;

    // Se não está editando (criando), retorna lista vazia (sem menu)
    if (notaEmEdicao == null) {
      return [];
    }

    // Item "Informações da nota" — sempre presente quando há nota salva
    final infoItem = PopupMenuItem<String>(
      onTap: () => _showInfoDialog(context),
      child: const Text('Informações da nota'),
    );

    if (notaEmEdicao.isApagada) {
      return <PopupMenuEntry<String>>[
        infoItem,
        const PopupMenuDivider(),
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
            style: TextStyle(color: Colors.red),
          ),
        ),
      ];
    } else if (notaEmEdicao.isArquivada) {
      return <PopupMenuEntry<String>>[
        infoItem,
        const PopupMenuDivider(),
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
            style: TextStyle(color: Colors.red),
          ),
        ),
      ];
    } else {
      return <PopupMenuEntry<String>>[
        infoItem,
        const PopupMenuDivider(),
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
            style: TextStyle(color: Colors.red),
          ),
        ),
      ];
    }
  }

  /// dispose: chamado quando o widget é destruído
  ///
  /// Responsabilidades:
  /// 1. Cancelar o timer (se houver um rodando)
  /// 2. Descartar os controllers (libera memória)
  /// 3. Chamar super.dispose()
  @override
  void dispose() {
    // Cancela o timer de debounce se houver um rodando
    _debounceTimer?.cancel();

    // Descarta o controller de título (libera memória)
    _titleController.dispose();

    // Descarta o controller de conteúdo (libera memória)
    _contentController.dispose();

    // Chama dispose da superclasse (importante!)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usa Consumer para escutar mudanças no ViewModel
    // Isso permite que o UI se reconstrua quando isFavorita muda
    return Consumer<NotaViewModel>(
      builder: (context, viewModel, _) {
        // Recupera a nota que está sendo editada (ou null se criando)
        final notaEmEdicao = viewModel.notaEmEdicao;

        final isFavorita = notaEmEdicao?.isFavorita ?? false;

        return Scaffold(
          backgroundColor: AppTheme.paper,
          floatingActionButton: FloatingActionButton(
            onPressed: _saveAndClose,
            backgroundColor: AppTheme.accent,
            foregroundColor: AppTheme.accentFg,
            tooltip: 'Salvar',
            child: const Icon(Icons.save_rounded),
          ),
          body: SafeArea(
            top: true,
            bottom: false,
            child: Column(
            children: [
              EditorHeader(
                title: notaEmEdicao?.titulo ?? '',
                isFavorita: isFavorita,
                onBack: () => Navigator.of(context).pop(),
                onToggleFavorita: () async {
                  if (notaEmEdicao != null) {
                    await viewModel.toggleFavorita(notaEmEdicao);
                  }
                },
                menuItems: _buildContextMenuItems(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    AppTheme.editorPaddingH,
                    AppTheme.editorPaddingTop,
                    AppTheme.editorPaddingH,
                    AppTheme.editorPaddingBottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'Título',
                          border: InputBorder.none,
                          hintStyle: AppTheme.editorTitle.copyWith(
                            color: AppTheme.faint,
                          ),
                        ),
                        style: AppTheme.editorTitle,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          hintText: 'Escreva sua nota...',
                          border: InputBorder.none,
                          hintStyle: AppTheme.editorBody.copyWith(
                            color: AppTheme.faint,
                          ),
                        ),
                        style: AppTheme.editorBody,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ),
        );
      },
    );
  }
}

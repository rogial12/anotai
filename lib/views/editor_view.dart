import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/nota.dart';
import '../viewmodels/nota_viewmodel.dart';

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
  bool _hasChanges = false; // Rastreia se houve mudanças não salvas

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<NotaViewModel>(context, listen: false);
    final notaEmEdicao = _viewModel.notaEmEdicao;

    // Inicializa controllers: se editando, preenche com dados; se criando, vazio
    _titleController = TextEditingController(
      text: notaEmEdicao?.titulo ?? '',
    );
    _contentController = TextEditingController(
      text: notaEmEdicao?.conteudo ?? '',
    );

    // Listeners para detectar mudanças no texto
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  // Chamado sempre que há digitação nos campos
  void _onTextChanged() {
    _hasChanges = true;

    // Cancela o timer anterior (usuário ainda está digitando)
    _debounceTimer?.cancel();

    // Inicia novo timer: salva automático após 5 segundos de inatividade
    _debounceTimer = Timer(const Duration(seconds: 5), _saveAutomatically);
  }

  // Salva a nota automaticamente
  Future<void> _saveAutomatically() async {
    if (!_hasChanges) return;

    final notaEmEdicao = _viewModel.notaEmEdicao;

    try {
      if (notaEmEdicao == null) {
        // Modo criação: cria uma nova nota
        await _viewModel.criarNota(
          titulo: _titleController.text,
          conteudo: _contentController.text,
        );
        // Após criar, atualiza _notaEmEdicao para a nota recém-criada
        // (útil se o usuário continuar editando)
        _viewModel.setNotaEmEdicao(
          _viewModel.notas.firstWhere(
            (n) => n.titulo == _titleController.text,
          ),
        );
      } else {
        // Modo edição: atualiza nota existente
        await _viewModel.editarNota(
          notaEmEdicao,
          titulo: _titleController.text,
          conteudo: _contentController.text,
        );
      }

      _hasChanges = false;
    } catch (e) {
      // Em caso de erro, poderia exibir um snackbar
      print('Erro ao salvar: $e');
    }
  }

  // Salva imediatamente ao sair da tela
  Future<void> _saveAndClose() async {
    _debounceTimer?.cancel();
    await _saveAutomatically();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    // Limpa resources
    _debounceTimer?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notaEmEdicao = _viewModel.notaEmEdicao;
    final isCreating = notaEmEdicao == null;
    final title = isCreating ? 'Nova nota' : 'Editar nota';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          // Botão salvar (força salvamento imediato)
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveAndClose,
            tooltip: 'Salvar e fechar',
          ),
          // Botão info (placeholder por enquanto)
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {},
            tooltip: 'Informações',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Campo de título
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Título',
                border: OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            // Campo de conteúdo (expansível)
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: 'Escreva sua nota...',
                  border: OutlineInputBorder(),
                  contentPadding: const EdgeInsets.all(12),
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
      // Botão flutuante para salvar (alternativa ao check do AppBar)
      floatingActionButton: FloatingActionButton(
        onPressed: _saveAndClose,
        tooltip: 'Salvar',
        child: const Icon(Icons.check),
      ),
    );
  }
}

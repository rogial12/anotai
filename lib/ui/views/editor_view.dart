import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../viewmodels/nota_viewmodel.dart';
import '../components/editor/editor_header.dart';
import '../styles/app_theme.dart';

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

  // Flag que rastreia se há mudanças não salvas
  bool _hasChanges = false;

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

  /// _onTextChanged: chamado quando há qualquer mudança no texto dos campos
  ///
  /// Fluxo:
  /// 1. Marca que há mudanças não salvas (_hasChanges = true)
  /// 2. Cancela o timer anterior (se houve um)
  /// 3. Inicia um novo timer de 5 segundos
  /// 4. Se o usuário continuar digitando, o timer será cancelado e reiniciado
  /// 5. Se o usuário parar de digitar por 5 segundos, o timer "explode" e salva
  void _onTextChanged() {
    // Marca que há mudanças não salvas
    _hasChanges = true;

    // Cancela o timer anterior se ainda estiver rodando
    // Isso significa que o usuário digitou novamente antes dos 5 segundos
    _debounceTimer?.cancel();

    // Inicia novo timer: após 5 segundos sem mudanças, salva automaticamente
    _debounceTimer = Timer(const Duration(seconds: 5), _saveAutomatically);
  }

  /// _saveAutomatically: salva a nota automaticamente (chamado pelo debounce timer)
  ///
  /// Fluxo:
  /// 1. Se não há mudanças, não faz nada (otimização)
  /// 2. Recupera a nota que está sendo editada
  /// 3. Se notaEmEdicao == null (criação): chama criarNota()
  /// 4. Se notaEmEdicao != null (edição): chama editarNota()
  /// 5. Marca _hasChanges = false (pois salvou)
  /// 6. Em caso de erro, imprime no console (TODO: exibir snackbar)
  Future<void> _saveAutomatically() async {
    // Se não há mudanças, não precisa salvar
    if (!_hasChanges) return;

    // Recupera a nota que está sendo editada (ou null se criando)
    final notaEmEdicao = _viewModel.notaEmEdicao;

    try {
      if (notaEmEdicao == null) {
        // Modo CRIAÇÃO: cria uma nova nota com os dados do formulário
        await _viewModel.criarNota(
          titulo: _titleController.text,
          conteudo: _contentController.text,
        );

        // Após criar, recupera a nota recém-criada e a define como _notaEmEdicao
        // Isso é útil porque se o usuário continuar editando, vai estar editando a nota criada
        _viewModel.setNotaEmEdicao(
          _viewModel.notas.firstWhere(
            (n) => n.titulo == _titleController.text,
          ),
        );
      } else {
        // Modo EDIÇÃO: atualiza a nota existente com os dados do formulário
        await _viewModel.editarNota(
          notaEmEdicao,
          titulo: _titleController.text,
          conteudo: _contentController.text,
        );
      }

      // Marca que as mudanças foram salvas (não há mais mudanças pendentes)
      _hasChanges = false;
    } catch (e) {
      // Em caso de erro, imprime no console (TODO: melhorar com snackbar ou tratamento real)
      print('Erro ao salvar: $e');
    }
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

  /// _showInfoBottomSheet: exibe uma bandeja na base da tela com informações da nota
  ///
  /// Mostra:
  /// - Data de criação (formatada como DD-MM-AAAA)
  ///
  /// Fluxo:
  /// 1. Recupera a nota sendo editada
  /// 2. Se for null (criando), não mostra nada
  /// 3. Se tiver nota, exibe um BottomSheet com os dados formatados
  void _showInfoBottomSheet(BuildContext context) {
    // Recupera a nota que está sendo editada
    final notaEmEdicao = _viewModel.notaEmEdicao;

    // Se não há nota (criando), não mostra a bandeja
    if (notaEmEdicao == null) {
      return;
    }

    // Formata a data de criação no padrão DD-MM-AAAA
    final dataFormatada =
        '${notaEmEdicao.criadaEm.day.toString().padLeft(2, '0')}-${notaEmEdicao.criadaEm.month.toString().padLeft(2, '0')}-${notaEmEdicao.criadaEm.year}';

    // Exibe a bandeja na base da tela
    showModalBottomSheet(
      context: context,
      // builder: constrói o conteúdo da bandeja
      builder: (BuildContext context) {
        return Padding(
          // Padding: espaçamento ao redor do conteúdo
          padding: const EdgeInsets.all(16),
          // Column: empilha widgets verticalmente
          child: Column(
            // mainAxisSize: deixar a coluna compacta (ocupar só o espaço necessário)
            mainAxisSize: MainAxisSize.min,
            // crossAxisAlignment: alinhar à esquerda
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título da bandeja de informações
              const Text(
                'Informações da nota',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Espaçamento
              const SizedBox(height: 16),
              // Data de criação
              Text(
                'Criada em: $dataFormatada',
                style: const TextStyle(fontSize: 16),
              ),
              // Espaçamento
              const SizedBox(height: 16),
              // Botão para fechar a bandeja
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Fecha a bandeja
                    Navigator.of(context).pop();
                  },
                  child: const Text('Fechar'),
                ),
              ),
            ],
          ),
        );
      },
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
      onTap: () => _showInfoBottomSheet(context),
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
          body: Column(
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
                onSave: _saveAndClose,
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
        );
      },
    );
  }
}

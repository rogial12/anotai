import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../viewmodels/nota_viewmodel.dart';

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

    if (notaEmEdicao.isApagada) {
      // Nota está na lixeira: opções para restaurar ou excluir definitivamente
      return <PopupMenuEntry<String>>[
        // Opção: Restaurar
        PopupMenuItem(
          onTap: () {
            // Restaura a nota da lixeira
            // Mantém isArquivada, então volta para o lugar certo
            _viewModel.restaurarNota(notaEmEdicao);
            // Fecha a EditorView e volta para HomeView
            Navigator.of(context).pop();
          },
          child: const Text('Restaurar'),
        ),
        // Separador visual
        const PopupMenuDivider(),
        // Opção: Excluir definitivamente (em vermelho)
        PopupMenuItem(
          onTap: () {
            // Exclui permanentemente do banco
            _viewModel.deletarPermanentemente(notaEmEdicao);
            // Fecha a EditorView e volta para HomeView
            Navigator.of(context).pop();
          },
          child: const Text(
            'Excluir definitivamente',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ];
    } else if (notaEmEdicao.isArquivada) {
      // Nota é arquivada: opções para desarquivar ou enviar para lixeira
      return <PopupMenuEntry<String>>[
        // Opção: Desarquivar
        PopupMenuItem(
          onTap: () {
            // Desarchiva a nota
            _viewModel.desarquivarNota(notaEmEdicao);
            // Fecha a EditorView e volta para HomeView
            Navigator.of(context).pop();
          },
          child: const Text('Desarquivar'),
        ),
        // Separador visual
        const PopupMenuDivider(),
        // Opção: Enviar para lixeira (em vermelho)
        PopupMenuItem(
          onTap: () {
            // Apaga a nota (move para lixeira)
            _viewModel.apagarNota(notaEmEdicao);
            // Fecha a EditorView e volta para HomeView
            Navigator.of(context).pop();
          },
          child: const Text(
            'Enviar para a lixeira',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ];
    } else {
      // Nota é comum (não arquivada, não apagada): opções para arquivar ou enviar para lixeira
      return <PopupMenuEntry<String>>[
        // Opção: Arquivar
        PopupMenuItem(
          onTap: () {
            // Arquiva a nota
            _viewModel.arquivarNota(notaEmEdicao);
            // Fecha a EditorView e volta para HomeView
            Navigator.of(context).pop();
          },
          child: const Text('Arquivar'),
        ),
        // Separador visual
        const PopupMenuDivider(),
        // Opção: Enviar para lixeira (em vermelho)
        PopupMenuItem(
          onTap: () {
            // Apaga a nota (move para lixeira)
            _viewModel.apagarNota(notaEmEdicao);
            // Fecha a EditorView e volta para HomeView
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

        // Determina se está criando (true) ou editando (false)
        final isCreating = notaEmEdicao == null;

        // Define o título do AppBar baseado no modo
        final title = isCreating ? 'Nova nota' : 'Editar nota';

        // Determina se o botão de favorita está ativo (apenas em modo edição)
        final isFavorita = notaEmEdicao?.isFavorita ?? false;

        // Scaffold: estrutura base da tela (AppBar, body, FAB, etc.)
        return Scaffold(
          // AppBar: barra no topo com título e botões de ação
          appBar: AppBar(
            // Título do AppBar (muda baseado no modo: "Nova nota" ou "Editar nota")
            title: Text(title),

            // actions: lista de botões no lado direito do AppBar
            actions: [
              // Botão de favorita (estrela)
              // Só funciona em modo edição (quando notaEmEdicao != null)
              if (!isCreating)
                IconButton(
                  // Ícone muda baseado em se é favorita ou não
                  icon: Icon(
                    isFavorita ? Icons.star : Icons.star_border,
                  ),
                  // Cor muda baseado em se é favorita ou não
                  color: isFavorita ? Colors.amber : null,
                  // Quando toca, inverte o estado de favorita
                  onPressed: () async {
                    // Chama o método do viewModel que inverte o estado
                    // await garante que a mudança é aplicada antes de continuar
                    await viewModel.toggleFavorita(notaEmEdicao);
                  },
                  tooltip: isFavorita
                      ? 'Remover de favoritos'
                      : 'Adicionar aos favoritos',
                ),

              // Botão de informações (ícone "i")
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  // Abre a bandeja de informações
                  _showInfoBottomSheet(context);
                },
                tooltip: 'Informações',
              ),

              // Botão de opções (três pontos verticais)
              // Usa PopupMenuButton que gerencia a posição e rebuild automaticamente
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                tooltip: 'Mais opções',
                // itemBuilder: constrói o menu baseado no estado da nota
                itemBuilder: (BuildContext context) {
                  return _buildContextMenuItems();
                },
              ),

              // Botão de salvar (check)
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: _saveAndClose,
                tooltip: 'Salvar e fechar',
              ),
            ],
          ),

          // Body: conteúdo principal (campos de texto)
          body: Padding(
            // Padding: espaçamento em torno do conteúdo
            padding: const EdgeInsets.all(16),
            // Column: empilha widgets verticalmente
            child: Column(
              children: [
                // Campo de título
                TextField(
                  // Usa o controller de título
                  controller: _titleController,
                  // Estilos e placeholder
                  decoration: InputDecoration(
                    hintText: 'Título',
                    border: OutlineInputBorder(),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  // Estilo do texto (maior e mais bold que o conteúdo)
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                // Espaçamento entre título e conteúdo
                const SizedBox(height: 16),

                // Campo de conteúdo (expansível para ocupar todo o espaço disponível)
                Expanded(
                  // Expanded: faz o widget ocupar o espaço restante
                  child: TextField(
                    // Usa o controller de conteúdo
                    controller: _contentController,
                    // Estilos e placeholder
                    decoration: InputDecoration(
                      hintText: 'Escreva sua nota...',
                      border: OutlineInputBorder(),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    // maxLines: null permite múltiplas linhas
                    maxLines: null,
                    // expands: true faz o TextField ocupar todo o espaço do Expanded
                    expands: true,
                    // textAlignVertical: top alinha o texto no topo (não fica centralizado)
                    textAlignVertical: TextAlignVertical.top,
                  ),
                ),
              ],
            ),
          ),

          // FAB: botão flutuante para salvar (alternativa ao botão no AppBar)
          floatingActionButton: FloatingActionButton(
            // Quando toca, salva e fecha
            onPressed: _saveAndClose,
            tooltip: 'Salvar',
            // Ícone de check (checkmark)
            child: const Icon(Icons.check),
          ),
        );
      },
    );
  }
}

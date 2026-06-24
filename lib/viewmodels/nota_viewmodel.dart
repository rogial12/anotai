import 'package:flutter/foundation.dart';
import '../models/nota.dart';
import '../repositories/nota_repository.dart';
import '../services/note_editor_service.dart';

/// NotaViewModel: gerencia o estado das notas do app
///
/// Responsabilidades:
/// 1. Manter a lista de notas em memória (_notas)
/// 2. Fornecer getters filtrados por estado (notas, favoritas, arquivadas, lixeira)
/// 3. Oferecer métodos para criar, editar, deletar, arquivar, favoritar
/// 4. Rastrear qual nota está sendo editada (_notaEmEdicao)
/// 5. Notificar a UI quando há mudanças (notifyListeners)
///
/// Estende ChangeNotifier: padrão do Flutter para estado reativo
class NotaViewModel extends ChangeNotifier {
  // Repositório: responsável por acessar/salvar dados no banco
  final NotaRepository _repository;

  // Serviço de edição: criação de nota vazia e salvamento
  final NoteEditorService _noteEditorService;

  // Lista completa de notas em memória (incluindo deletadas e arquivadas)
  List<Nota> _notas = [];

  // Rastreia qual nota está sendo editada
  Nota? _notaEmEdicao;

  // ===== CONSTRUTORES =====

  // Recebe repositório e serviços via injeção de dependência
  NotaViewModel(this._repository, {required NoteEditorService noteEditorService})
      : _noteEditorService = noteEditorService;

  // ===== GETTERS FILTRADOS =====

  /// Notas comuns (não arquivadas, não apagadas, não vazias)
  /// Exibidas na aba "Anotações"
  List<Nota> get notas => _notas.where((n) =>
      !n.isApagada &&
      !n.isArquivada &&
      (n.titulo.isNotEmpty || n.conteudo.isNotEmpty)).toList();

  /// Notas marcadas como favorita (não apagadas, não arquivadas, não vazias)
  /// Exibidas em uma aba "Favoritas" (futura)
  List<Nota> get favoritas => _notas.where((n) =>
      n.isFavorita &&
      !n.isApagada &&
      !n.isArquivada &&
      (n.titulo.isNotEmpty || n.conteudo.isNotEmpty)).toList();

  /// Notas arquivadas (não apagadas, não vazias)
  /// Exibidas na aba "Arquivo"
  List<Nota> get arquivadas => _notas.where((n) =>
      n.isArquivada &&
      !n.isApagada &&
      (n.titulo.isNotEmpty || n.conteudo.isNotEmpty)).toList();

  /// Notas apagadas (na lixeira)
  /// Exibidas na aba "Lixeira"
  List<Nota> get lixeira => _notas.where((n) => n.isApagada).toList();

  /// Getter para a nota sendo editada
  /// Retorna null se está criando nova nota
  Nota? get notaEmEdicao => _notaEmEdicao;

  // ===== MÉTODOS DE GERENCIAMENTO DE ESTADO =====

  /// Define qual nota está sendo editada
  /// Se nota == null, o modo é "criação"
  void setNotaEmEdicao(Nota? nota) {
    _notaEmEdicao = nota;
    notifyListeners();
  }

  // ===== MÉTODOS DE OPERAÇÃO =====

  /// carregarNotas: carrega todas as notas do repositório (banco de dados)
  ///
  /// Fluxo:
  /// 1. Chama repository.buscarTodas() (assíncrono)
  /// 2. Aguarda o resultado
  /// 3. Armazena em _notas
  /// 4. Notifica listeners para reconstruir a UI
  Future<void> carregarNotas() async {
    // Busca todas as notas do banco (inclui apagadas, arquivadas, etc.)
    _notas = await _repository.buscarTodas();
    // Notifica a UI para se reconstruir
    notifyListeners();
  }

  // Cria nota vazia via serviço, adiciona à lista e define como nota em edição
  Future<void> criarNotaVazia() async {
    final nota = await _noteEditorService.criarNotaVazia();
    _notas.add(nota);
    _notaEmEdicao = nota;
    notifyListeners();
  }

  // Salva título e conteúdo via serviço e notifica a UI
  Future<void> salvarNota({required String titulo, required String conteudo}) async {
    if (_notaEmEdicao == null) return;
    try {
      await _noteEditorService.salvarNota(
        _notaEmEdicao!,
        titulo: titulo,
        conteudo: conteudo,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao salvar nota: $e');
    }
  }

  /// apagarNota: move uma nota para a lixeira (soft delete)
  ///
  /// Parâmetro:
  /// - nota: nota a ser apagada
  ///
  /// Fluxo:
  /// 1. Marca nota.isApagada = true
  /// 2. IMPORTANTE: mantém isArquivada no seu estado anterior
  /// 3. Salva no banco
  /// 4. Notifica a UI (nota sai da aba atual, aparece na Lixeira)
  ///
  /// Nota: isso é "soft delete" — a nota não é excluída do banco, só marcada como apagada
  /// Ela entra no countdown de 30 dias antes de ser excluída permanentemente
  Future<void> apagarNota(Nota nota) async {
    // Marca como apagada (vai para lixeira)
    nota.isApagada = true;
    // isArquivada continua como era (pode ser true ou false)
    // Isso é importante para restauração: a nota lembra se era arquivada
    // Salva no banco
    await _repository.salvar(nota);
    // Notifica a UI
    notifyListeners();
  }

  /// restaurarNota: restaura uma nota da lixeira
  ///
  /// Parâmetro:
  /// - nota: nota a ser restaurada
  ///
  /// Fluxo:
  /// 1. Marca nota.isApagada = false
  /// 2. IMPORTANTE: mantém isArquivada no seu estado anterior
  /// 3. Salva no banco
  /// 4. Notifica a UI (nota volta para sua aba original)
  ///
  /// Exemplo:
  /// - Se nota.isArquivada == true: volta para aba "Arquivo"
  /// - Se nota.isArquivada == false: volta para aba "Anotações"
  Future<void> restaurarNota(Nota nota) async {
    // Marca como não apagada (sai da lixeira)
    nota.isApagada = false;
    // isArquivada mantém seu valor anterior
    // Salva no banco
    await _repository.salvar(nota);
    // Notifica a UI
    notifyListeners();
  }

  /// deletarPermanentemente: exclui uma nota definitivamente do banco (hard delete)
  ///
  /// Parâmetro:
  /// - nota: nota a ser excluída permanentemente
  ///
  /// Fluxo:
  /// 1. Remove a nota do banco via repository.deletar()
  /// 2. Remove a nota da lista em memória
  /// 3. Notifica a UI
  ///
  /// CUIDADO: isso é irreversível — a nota é excluída de verdade
  /// Só deve ser chamado quando o usuário confirma a exclusão permanente
  Future<void> deletarPermanentemente(Nota nota) async {
    // Chama o repositório para deletar de verdade do banco
    await _repository.deletar(nota.id);
    // Remove da lista em memória
    _notas.removeWhere((n) => n.id == nota.id);
    // Notifica a UI
    notifyListeners();
  }

  /// arquivarNota: move uma nota para o arquivo
  ///
  /// Parâmetro:
  /// - nota: nota a ser arquivada
  ///
  /// Fluxo:
  /// 1. Marca nota.isArquivada = true
  /// 2. Salva no banco
  /// 3. Notifica a UI (nota sai de "Anotações" e entra em "Arquivo")
  Future<void> arquivarNota(Nota nota) async {
    // Marca como arquivada
    nota.isArquivada = true;
    // Salva no banco
    await _repository.salvar(nota);
    // Notifica a UI
    notifyListeners();
  }

  /// desarquivarNota: remove uma nota do arquivo (volta para "Anotações")
  ///
  /// Parâmetro:
  /// - nota: nota a ser desarquivada
  ///
  /// Fluxo:
  /// 1. Marca nota.isArquivada = false
  /// 2. Salva no banco
  /// 3. Notifica a UI (nota sai de "Arquivo" e entra em "Anotações")
  Future<void> desarquivarNota(Nota nota) async {
    // Marca como não arquivada
    nota.isArquivada = false;
    // Salva no banco
    await _repository.salvar(nota);
    // Notifica a UI
    notifyListeners();
  }

  /// toggleFavorita: inverte o estado de favorita de uma nota
  ///
  /// Parâmetro:
  /// - nota: nota a ter o estado de favorita invertido
  ///
  /// Fluxo:
  /// 1. Inverte nota.isFavorita (true → false, false → true)
  /// 2. Salva no banco
  /// 3. Notifica a UI (icon da nota muda de estrela vazia/cheia)
  Future<void> toggleFavorita(Nota nota) async {
    // Inverte: se era favorita, deixa de ser; se não era, vira
    nota.isFavorita = !nota.isFavorita;
    // Salva no banco
    await _repository.salvar(nota);
    // Notifica a UI
    notifyListeners();
  }
}

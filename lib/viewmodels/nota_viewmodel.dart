import 'package:flutter/foundation.dart';
import '../models/nota.dart';
import '../repositories/nota_repository.dart';
import '../services/archive_service.dart';
import '../services/note_editor_service.dart';
import '../services/trash_service.dart';

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

  // Serviço de arquivo: arquivamento e desarquivamento
  final ArchiveService _archiveService;

  // Serviço de lixeira: soft delete, restauração e exclusão permanente
  final TrashService _trashService;

  // Lista completa de notas em memória (incluindo deletadas e arquivadas)
  List<Nota> _notas = [];

  // Rastreia qual nota está sendo editada
  Nota? _notaEmEdicao;

  // ===== CONSTRUTORES =====

  // Recebe repositório e serviços via injeção de dependência
  NotaViewModel(
    this._repository, {
    required NoteEditorService noteEditorService,
    required ArchiveService archiveService,
    required TrashService trashService,
  })  : _noteEditorService = noteEditorService,
        _archiveService = archiveService,
        _trashService = trashService;

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

  // Delega ao TrashService e notifica a UI
  Future<void> apagarNota(Nota nota) async {
    await _trashService.apagarNota(nota);
    notifyListeners();
  }

  // Delega ao TrashService e notifica a UI
  Future<void> restaurarNota(Nota nota) async {
    await _trashService.restaurarNota(nota);
    notifyListeners();
  }

  // Delega ao TrashService, remove da lista em memória e notifica a UI
  // Remover de _notas é responsabilidade do ViewModel — é estado, não persistência
  Future<void> deletarPermanentemente(Nota nota) async {
    await _trashService.deletarPermanentemente(nota);
    _notas.removeWhere((n) => n.id == nota.id);
    notifyListeners();
  }

  // Delega ao ArchiveService e notifica a UI
  Future<void> arquivarNota(Nota nota) async {
    await _archiveService.arquivarNota(nota);
    notifyListeners();
  }

  // Delega ao ArchiveService e notifica a UI
  Future<void> desarquivarNota(Nota nota) async {
    await _archiveService.desarquivarNota(nota);
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

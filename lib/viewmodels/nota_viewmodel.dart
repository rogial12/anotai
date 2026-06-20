import 'package:flutter/foundation.dart';
import '../models/nota.dart';
import '../repositories/nota_repository.dart';

class NotaViewModel extends ChangeNotifier {
  final NotaRepository _repository;
  List<Nota> _notas = [];

  NotaViewModel(this._repository);

  List<Nota> get notas =>
      _notas.where((n) => !n.estaApagada && !n.isArquivada).toList();

  List<Nota> get favoritas =>
      _notas.where((n) => n.isFavorita && !n.estaApagada && !n.isArquivada).toList();

  List<Nota> get arquivadas =>
      _notas.where((n) => n.isArquivada && !n.estaApagada).toList();

  List<Nota> get lixeira => _notas.where((n) => n.estaApagada).toList();

  Future<void> carregarNotas() async {
    _notas = await _repository.buscarTodas();
    notifyListeners();
  }

  Future<void> criarNota({required String titulo, required String conteudo}) async {
    final nota = Nota(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: titulo,
      conteudo: conteudo,
      criadaEm: DateTime.now(),
      atualizadaEm: DateTime.now(),
    );
    await _repository.salvar(nota);
    _notas.add(nota);
    notifyListeners();
  }

  Future<void> editarNota(Nota nota, {String? titulo, String? conteudo}) async {
    if (titulo != null) nota.titulo = titulo;
    if (conteudo != null) nota.conteudo = conteudo;
    nota.atualizadaEm = DateTime.now();
    await _repository.salvar(nota);
    notifyListeners();
  }

  Future<void> apagarNota(Nota nota) async {
    nota.apagadaEm = DateTime.now();
    await _repository.salvar(nota);
    notifyListeners();
  }

  Future<void> restaurarNota(Nota nota) async {
    nota.apagadaEm = null;
    await _repository.salvar(nota);
    notifyListeners();
  }

  Future<void> arquivarNota(Nota nota) async {
    nota.isArquivada = true;
    await _repository.salvar(nota);
    notifyListeners();
  }

  Future<void> toggleFavorita(Nota nota) async {
    nota.isFavorita = !nota.isFavorita;
    await _repository.salvar(nota);
    notifyListeners();
  }
}

import '../models/nota.dart';
import '../repositories/nota_repository.dart';

// Gerencia arquivamento e desarquivamento de notas.
class ArchiveService {
  // Repositório injetado via construtor
  final NotaRepository _repository;

  ArchiveService(this._repository);

  // Marca a nota como arquivada e persiste no banco.
  // isApagada não é alterado — uma nota arquivada pode ser apagada independentemente.
  Future<void> arquivarNota(Nota nota) async {
    nota.isArquivada = true;
    await _repository.salvar(nota);
  }

  // Remove a nota do arquivo e persiste no banco.
  // A nota volta para a aba "Anotações" (isArquivada = false, isApagada = false).
  Future<void> desarquivarNota(Nota nota) async {
    nota.isArquivada = false;
    await _repository.salvar(nota);
  }
}

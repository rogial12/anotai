import '../models/nota.dart';
import '../repositories/nota_repository.dart';

// Gerencia criação e salvamento de notas no editor.
// Encapsula a lógica de "sempre editando" — o editor nunca distingue criar de editar.
class NoteEditorService {
  final NotaRepository _repository;

  NoteEditorService(this._repository);

  // TODO: mover criarNotaVazia() do NotaViewModel
  // TODO: mover salvarNota() do NotaViewModel
}

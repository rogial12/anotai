import '../models/nota.dart';
import '../repositories/nota_repository.dart';

// Gerencia o ciclo de vida de notas apagadas: soft delete, restauração,
// exclusão permanente e futuramente o countdown de 30 dias.
class TrashService {
  final NotaRepository _repository;

  TrashService(this._repository);

  // TODO: mover apagarNota() do NotaViewModel
  // TODO: mover restaurarNota() do NotaViewModel
  // TODO: mover deletarPermanentemente() do NotaViewModel
  // TODO: implementar limparExpiradas() — exclui notas com >30 dias na lixeira
}

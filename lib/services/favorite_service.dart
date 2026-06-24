import '../models/nota.dart';
import '../repositories/nota_repository.dart';

// Gerencia o estado de favorita das notas.
// Futuramente: ordenação por favoritas, contagem, exportação seletiva, etc.
class FavoriteService {
  final NotaRepository _repository;

  FavoriteService(this._repository);

  // Inverte o estado de favorita e persiste no banco.
  Future<void> toggleFavorita(Nota nota) async {
    nota.isFavorita = !nota.isFavorita;
    await _repository.salvar(nota);
  }
}

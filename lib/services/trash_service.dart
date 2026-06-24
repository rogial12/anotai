import '../models/nota.dart';
import '../repositories/nota_repository.dart';

// Gerencia o ciclo de vida de notas apagadas: soft delete, restauração e exclusão permanente.
// Futuramente: limparExpiradas() para o countdown de 30 dias.
class TrashService {
  // Repositório injetado via construtor
  final NotaRepository _repository;

  TrashService(this._repository);

  // Move a nota para a lixeira (soft delete).
  // isArquivada não é alterado — a nota lembra se era arquivada para poder voltar ao lugar certo.
  Future<void> apagarNota(Nota nota) async {
    nota.isApagada = true;
    await _repository.salvar(nota);
  }

  // Restaura a nota da lixeira.
  // isArquivada mantém o valor anterior — se era arquivada, volta ao arquivo; senão, volta às anotações.
  Future<void> restaurarNota(Nota nota) async {
    nota.isApagada = false;
    await _repository.salvar(nota);
  }

  // Exclui a nota definitivamente do banco (hard delete, irreversível).
  // Apenas persiste a exclusão — remover da lista _notas em memória é responsabilidade do ViewModel.
  Future<void> deletarPermanentemente(Nota nota) async {
    await _repository.deletar(nota.id);
  }

  // TODO: implementar limparExpiradas() — exclui notas com mais de 30 dias na lixeira
}

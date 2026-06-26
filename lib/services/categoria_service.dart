import '../models/categoria.dart';
import '../repositories/categoria_repository.dart';

// Gerencia o ciclo de vida das categorias como entidade.
// NÃO gerencia a associação nota↔categoria — isso é responsabilidade do ViewModel,
// pois envolve salvar a Nota via NotaRepository.
class CategoriaService {
  final CategoriaRepository _repository;

  CategoriaService(this._repository);

  Future<List<Categoria>> buscarTodas() async {
    return _repository.buscarTodas();
  }

  // Cria uma nova categoria com nome fornecido pelo usuário e persiste.
  Future<Categoria> criar(String nome) async {
    final categoria = Categoria(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome.trim(),
    );
    await _repository.salvar(categoria);
    return categoria;
  }

  // Renomeia uma categoria existente. Por usar Option B (ID como chave),
  // as notas não precisam ser atualizadas — elas armazenam o ID, não o nome.
  Future<void> renomear(Categoria categoria, String novoNome) async {
    categoria.nome = novoNome.trim();
    await _repository.salvar(categoria);
  }

  // Deleta a categoria do repositório.
  // Quem chama é responsável por limpar categoriaIds nas notas afetadas.
  Future<void> deletar(String id) async {
    await _repository.deletar(id);
  }
}

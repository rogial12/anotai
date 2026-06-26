import '../models/categoria.dart';

// Interface para o repositório de categorias.
// Segue o mesmo contrato do NotaRepository: a lógica do app não sabe
// de onde os dados vêm (Hive hoje, possivelmente remoto no futuro).
abstract class CategoriaRepository {
  Future<List<Categoria>> buscarTodas();
  Future<void> salvar(Categoria categoria);
  Future<void> deletar(String id);
}

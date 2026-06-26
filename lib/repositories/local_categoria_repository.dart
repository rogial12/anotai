import 'package:hive/hive.dart';
import '../models/categoria.dart';
import 'categoria_repository.dart';

// Implementação Hive do CategoriaRepository.
// Armazena cada categoria como Map no box 'categorias', usando o id como chave.
class LocalCategoriaRepository implements CategoriaRepository {
  static const String _boxName = 'categorias';

  Box get _box => Hive.box(_boxName);

  @override
  Future<List<Categoria>> buscarTodas() async {
    return _box.values
        .map((map) => Categoria.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  @override
  Future<void> salvar(Categoria categoria) async {
    await _box.put(categoria.id, categoria.toMap());
  }

  @override
  Future<void> deletar(String id) async {
    await _box.delete(id);
  }
}

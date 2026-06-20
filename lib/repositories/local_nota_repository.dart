import 'package:hive/hive.dart';
import '../models/nota.dart';
import 'nota_repository.dart';

class LocalNotaRepository implements NotaRepository {
  static const String _boxName = 'notas';

  Box get _box => Hive.box(_boxName);

  @override
  Future<List<Nota>> buscarTodas() async {
    return _box.values
        .map((map) => Nota.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  @override
  Future<void> salvar(Nota nota) async {
    await _box.put(nota.id, nota.toMap());
  }

  @override
  Future<void> deletar(String id) async {
    await _box.delete(id);
  }
}

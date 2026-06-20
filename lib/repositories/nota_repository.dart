import '../models/nota.dart';

abstract class NotaRepository { //Interface para repositório de Notas. Flutter não tem uma declaração específica para interfaces.
  
  Future<List<Nota>> buscarTodas(); //Método para buscar notas. Retorna uma lista de objetos do tipo Notas
  Future<void> salvar(Nota nota);
  Future<void> deletar(String id);
}

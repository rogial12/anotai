import '../models/nota.dart';

// Filtra notas por título e conteúdo.
// Stateless: sem campos, sem dependências — cada chamada é independente.
class SearchService {
  // Retorna notas cujo título ou conteúdo contenha a query (case-insensitive).
  // Recebe a lista já pré-filtrada pelo ViewModel (sem apagadas, sem arquivadas, etc).
  List<Nota> buscar(List<Nota> notas, String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return notas;
    return notas.where((n) =>
      n.titulo.toLowerCase().contains(q) ||
      n.conteudo.toLowerCase().contains(q)
    ).toList();
  }
}

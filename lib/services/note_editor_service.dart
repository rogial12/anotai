import '../models/nota.dart';
import '../repositories/nota_repository.dart';

// Gerencia criação e salvamento de notas no editor.
// Encapsula a lógica de "sempre editando" — o editor nunca distingue criar de editar.
class NoteEditorService {
  // Repositório injetado via construtor — o serviço não sabe qual banco está por baixo
  final NotaRepository _repository;

  NoteEditorService(this._repository);

  // Cria uma nota vazia no banco e a retorna para o ViewModel.
  // Retorna a nota para que o ViewModel possa guardá-la em _notaEmEdicao —
  // o serviço não acessa estado da UI.
  Future<Nota> criarNotaVazia() async {
    final nota = Nota(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: '',
      conteudo: '',
      criadaEm: DateTime.now(),
      atualizadaEm: DateTime.now(),
    );
    await _repository.salvar(nota);
    return nota;
  }

  // Atualiza título e conteúdo de uma nota existente e persiste no banco.
  // Recebe a nota diretamente — quem decide qual nota editar é o ViewModel.
  Future<void> salvarNota(
    Nota nota, {
    required String titulo,
    required String conteudo,
  }) async {
    nota.titulo = titulo;
    nota.conteudo = conteudo;
    nota.atualizadaEm = DateTime.now();
    await _repository.salvar(nota);
  }
}

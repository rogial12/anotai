// Entidade Categoria — representa uma categoria criada pelo usuário.
//
// "Todos" e "Favoritas" são categorias built-in da UI, NÃO entidades Categoria.
// "Todos" = sem filtro; "Favoritas" = filtra por isFavorita.
// Apenas categorias personalizadas criadas pelo usuário viram objetos Categoria
// e são persistidas neste repositório.
class Categoria {
  final String id;
  String nome;

  Categoria({
    required this.id,
    required this.nome,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
    };
  }

  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['id'],
      nome: map['nome'],
    );
  }
}

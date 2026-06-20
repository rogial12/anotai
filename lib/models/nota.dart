class Nota {
  final String id; //'final' é usado para variáveis que nunca mudam após a instanciação do objeto. O 'id' é único para cada nota e não deve ser alterado.
  String titulo;
  String conteudo;
  final DateTime criadaEm; //Data de criação nunca muda após a instanciação da nota, por isso é 'final'.
  DateTime atualizadaEm;
  DateTime? apagadaEm; //Pode ser nulo, por isso é do tipo 'DateTime?' com o '?' no final.
  bool isFavorita;
  bool isArquivada;

  Nota({ //Método construtor em flutter
    required this.id,
    required this.titulo,
    required this.conteudo,
    required this.criadaEm,
    required this.atualizadaEm,
    this.apagadaEm,
    this.isFavorita = false,
    this.isArquivada = false,
  });

  bool get estaApagada => apagadaEm != null; //Getter que verifica se a nota foi apagada. se 'apagadaEm' for diferente de null, ela foi apagada em algum momento.

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'conteudo': conteudo,
      'criadaEm': criadaEm.toIso8601String(),
      'atualizadaEm': atualizadaEm.toIso8601String(),
      'apagadaEm': apagadaEm?.toIso8601String(),
      'isFavorita': isFavorita,
      'isArquivada': isArquivada,
    };
  }

  factory Nota.fromMap(Map<String, dynamic> map) {
    return Nota(
      id: map['id'],
      titulo: map['titulo'],
      conteudo: map['conteudo'],
      criadaEm: DateTime.parse(map['criadaEm']),
      atualizadaEm: DateTime.parse(map['atualizadaEm']),
      apagadaEm: map['apagadaEm'] != null ? DateTime.parse(map['apagadaEm']) : null,
      isFavorita: map['isFavorita'],
      isArquivada: map['isArquivada'],
    );
  }
}

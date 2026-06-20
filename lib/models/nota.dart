/// Modelo Nota: representa uma anotação no app
///
/// Estados da nota:
/// - isFavorita: marca a nota como favorita (estrela)
/// - isArquivada: marca a nota como arquivada (aba "Arquivo")
/// - isApagada: marca a nota como deletada (aba "Lixeira", countdown de 30 dias)
///
/// Importante: isApagada e isArquivada são INDEPENDENTES
/// Uma nota pode ser: comum, arquivada, apagada, ou apagada-mas-era-arquivada
class Nota {
  // ===== IDENTIFICAÇÃO =====
  // ID único da nota (nunca muda após criação)
  final String id;

  // ===== CONTEÚDO =====
  // Título da nota (mutável, pode ser editado)
  String titulo;

  // Conteúdo/corpo da nota (mutável, pode ser editado)
  String conteudo;

  // ===== TIMESTAMPS =====
  // Data de criação da nota (nunca muda após criação)
  final DateTime criadaEm;

  // Data da última atualização (muda cada vez que a nota é editada)
  DateTime atualizadaEm;

  // ===== ESTADOS =====
  // Favorita: marca a nota com estrela
  bool isFavorita;

  // Arquivada: nota está na pasta "Arquivo" (separada das notas comuns)
  bool isArquivada;

  // Apagada: nota está na "Lixeira" (será excluída permanentemente após 30 dias)
  // IMPORTANTE: isApagada é INDEPENDENTE de isArquivada
  // Se uma nota é apagada, ela vai para lixeira, mas LEMBRA se era arquivada
  // Ao restaurar, volta com isArquivada no mesmo estado que era antes
  bool isApagada;

  /// Construtor da Nota
  ///
  /// Parâmetros:
  /// - id: identificador único (obrigatório)
  /// - titulo: título da nota (obrigatório)
  /// - conteudo: corpo da nota (obrigatório)
  /// - criadaEm: data de criação (obrigatório)
  /// - atualizadaEm: data da última edição (obrigatório)
  /// - isFavorita: se é favorita (padrão: false)
  /// - isArquivada: se é arquivada (padrão: false)
  /// - isApagada: se está na lixeira (padrão: false)
  Nota({
    required this.id,
    required this.titulo,
    required this.conteudo,
    required this.criadaEm,
    required this.atualizadaEm,
    this.isFavorita = false,
    this.isArquivada = false,
    this.isApagada = false,
  });

  /// toMap: converte a nota em um mapa (para salvar no banco)
  ///
  /// Razão: O Hive (banco de dados local) armazena dados como Maps (dicionários)
  /// Essa função converte todos os campos da nota em pares chave-valor
  /// que o Hive consegue entender e guardar
  ///
  /// DateTime é convertido para String ISO8601 (formato universal)
  Map<String, dynamic> toMap() {
    return {
      // ID (string)
      'id': id,
      // Título (string)
      'titulo': titulo,
      // Conteúdo (string)
      'conteudo': conteudo,
      // Data de criação (string no formato ISO8601: "2026-06-20T10:30:00.000")
      'criadaEm': criadaEm.toIso8601String(),
      // Data de atualização (string no formato ISO8601)
      'atualizadaEm': atualizadaEm.toIso8601String(),
      // Estados (booleanos)
      'isFavorita': isFavorita,
      'isArquivada': isArquivada,
      'isApagada': isApagada,
    };
  }

  /// fromMap: constrói uma Nota a partir de um mapa (para recuperar do banco)
  ///
  /// Razão: Quando lê do Hive, os dados vêm como Maps
  /// Esse construtor factory (construtor alternativo) reconstrói a Nota
  /// a partir dos dados salvos no banco
  ///
  /// "factory" permite lógica customizada no construtor
  /// (não é um construtor normal, é um método estático que retorna uma instância)
  factory Nota.fromMap(Map<String, dynamic> map) {
    return Nota(
      // Recupera ID (string)
      id: map['id'],
      // Recupera título (string)
      titulo: map['titulo'],
      // Recupera conteúdo (string)
      conteudo: map['conteudo'],
      // Recupera data de criação: converte string ISO8601 de volta para DateTime
      criadaEm: DateTime.parse(map['criadaEm']),
      // Recupera data de atualização: converte string ISO8601 de volta para DateTime
      atualizadaEm: DateTime.parse(map['atualizadaEm']),
      // Recupera estados (booleanos)
      isFavorita: map['isFavorita'] ?? false,
      isArquivada: map['isArquivada'] ?? false,
      isApagada: map['isApagada'] ?? false,
    );
  }
}

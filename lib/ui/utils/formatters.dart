// Funções utilitárias puras: sem estado, sem widgets, só lógica auxiliar.

String formatDate(DateTime dt) {
  return '${dt.day} de ${_monthName(dt.month)} de ${dt.year}';
}

int wordCount(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return 0;
  return trimmed.split(RegExp(r'\s+')).length;
}

int charCount(String text) => text.length;

String _monthName(int month) {
  const months = [
    'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
    'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
  ];
  return months[month - 1];
}

class Language {
  final String code;
  final String name;
  final String flag;

  Language({
    required this.code,
    required this.name,
    required this.flag,
  });
}

class Vocabulary {
  final String word;
  final String translation;
  final String pronunciation;
  final String example;
  final String category;

  Vocabulary({
    required this.word,
    required this.translation,
    required this.pronunciation,
    required this.example,
    required this.category,
  });
}

final List<Language> supportedLanguages = [
  Language(code: 'es', name: 'Spanish', flag: '🇪🇸'),
  Language(code: 'fr', name: 'French', flag: '🇫🇷'),
  Language(code: 'de', name: 'German', flag: '🇩🇪'),
  Language(code: 'it', name: 'Italian', flag: '🇮🇹'),
  Language(code: 'pt', name: 'Portuguese', flag: '🇵🇹'),
]; 
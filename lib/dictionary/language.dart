enum Language { JAPANESE, ENGLISH }

extension LanguageExtension on Language {
  String get symbol {
    switch (this) {
      case Language.JAPANESE:
        return '和';
      case Language.ENGLISH:
        return '英';
    }
    throw new UnsupportedError('unknown value: $this');
  }
}

class DictionaryLanguage {
  static Map<Language, Map<Language, DictionaryLanguage>> _instances = {};

  static DictionaryLanguage of(Language from, Language to) {
    var p = _instances[from];
    if (p != null) {
      var q = p[to];
      if (q != null) {
        return q;
      }
    } else {
      _instances[from] = Map();
    }
    return _instances[from][to] = DictionaryLanguage._internal(from, to);
  }

  final Language from, to;

  DictionaryLanguage._internal(this.from, this.to);

  String get symbol =>
      from == Language.JAPANESE && to == Language.JAPANESE ? '国語' : from.symbol + to.symbol;
}

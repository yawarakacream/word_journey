import 'db_provider.dart';
import 'language.dart';

class Word {
  final String name;
  final String meaning;

  const Word(this.name, this.meaning);

  @override
  String toString() => 'Word[name=$name,meaning=$meaning]';
}

/// zero-indexed
abstract class Dictionary {
  final DictionaryLanguage lang;

  Dictionary(this.lang);

  Future<void> init();

  String get displayName => lang.symbol + '辞典';
  int get size;

  Future<int> getIndex(String key);
  Future<Word> getWord(int index);
}

class DBDictionary extends Dictionary {
  // データベースから単語を取ってくる際、前もって余計に _range 分だけ周りの単語も取っておく
  static final int _range = 64;

  final String _tableName;

  int _size;
  Map<int, Word> _words;

  DBDictionary(this._tableName, Language from, Language to)
      : super(DictionaryLanguage.of(from, to));

  @override
  Future<void> init() async {
    _size = await DictionaryDBProvider.instance.connection
        .rawQuery('SELECT COUNT(*) FROM $_tableName')
        .then((values) => values[0]['COUNT(*)']);
    _words = {};
  }

  @override
  int get size => _size;

  @override
  Future<int> getIndex(String key) async {
    int result = _words.keys.firstWhere((i) => _words[i].name == key, orElse: () => null);
    if (result == null) {
      result = await DictionaryDBProvider.instance.connection.rawQuery(
          'SELECT id FROM $_tableName WHERE key >= ? LIMIT 1',
          [key]).then((values) => values.isEmpty ? -1 : values[0]['id']);
    }
    return result;
  }

  @override
  Future<Word> getWord(int index) async {
    if (index < 0 || size <= index) {
      throw ArgumentError();
    }

    if (!_words.containsKey(index)) {
      var rows = await DictionaryDBProvider.instance.connection.rawQuery(
          'SELECT id,word,meaning FROM $_tableName WHERE id BETWEEN ? and ?',
          [index - _range, index + _range]);

      for (var row in rows) {
        _words[row['id']] = Word(row['word'], row["meaning"]);
      }
    }

    return _words[index];
  }
}

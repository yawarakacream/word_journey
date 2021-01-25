import 'package:word_journey/dictionary/dictionary.dart';
import 'package:word_journey/dictionary/language.dart';

class DictionaryContainer {
  static DictionaryContainer _instance;
  static DictionaryContainer get instance => _instance;
  DictionaryContainer._internal();

  static Future<void> init() async {
    if (_instance != null) {
      throw new UnsupportedError('_instance already exists');
    }
    _instance = DictionaryContainer._internal();
    await _instance.initDictionaries();
  }

  final List<Dictionary> dictionaries = [];
  final Set<DictionaryLanguage> languages = {};

  Future<void> initDictionaries() async {
    dictionaries.addAll([
      DBDictionary('en2ja_ejdict_hand', Language.ENGLISH, Language.JAPANESE),
      DBDictionary('en2en_opted', Language.ENGLISH, Language.ENGLISH),
    ]);
    languages.addAll(dictionaries.map((d) => d.lang));
    dictionaries.forEach((d) async => await d.init());
  }

  Dictionary getPrimaryDictionary(DictionaryLanguage lang) {
    //TODO
    return dictionaries.firstWhere((element) => element.lang == lang);
  }
}

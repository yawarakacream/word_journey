import 'package:word_journey/core/db_provider.dart';

class DictionaryDBProvider extends SqliteDatabaseProvider {
  static DictionaryDBProvider _instance;
  static DictionaryDBProvider get instance => _instance;
  DictionaryDBProvider._internal() : super(['assets', 'dictionaries.sqlite3']);

  static Future<void> init() async {
    if (instance != null) {
      throw new UnsupportedError('_instance already exists');
    }
    _instance = DictionaryDBProvider._internal();
    await _instance.open();
  }
}

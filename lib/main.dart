import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:word_journey/dictionary/container.dart';
import 'package:word_journey/dictionary/db_provider.dart';
import 'package:word_journey/route/root.dart';

final _name = 'word_journey';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await DictionaryDBProvider.init();
  await DictionaryContainer.init();

  runApp(WordJourney());
}

class WordJourney extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _name,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Root(),
    );
  }
}

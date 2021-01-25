import 'package:flutter/material.dart';
import 'package:word_journey/core/bottom_router_view.dart';
import 'package:word_journey/dictionary/container.dart';
import 'package:word_journey/route/dictionary.dart';

class Root extends RouterWidget {
  Root({Key key})
      : super([...DictionaryContainer.instance.languages.map((l) => DictionaryRoute(l))],
            key: key, resizeToAvoidBottomInset: false);
}

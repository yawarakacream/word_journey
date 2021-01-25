import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:word_journey/core/bottom_router_view.dart';
import 'package:word_journey/dictionary/container.dart';
import 'package:word_journey/dictionary/dictionary.dart';
import 'package:word_journey/dictionary/language.dart';

class DictionaryRoute extends RouteRecord {
  final DictionaryLanguage lang;

  DictionaryRoute(this.lang) : super(lang.symbol, Icons.book, _Body(lang));
}

class _Header extends StatelessWidget with PreferredSizeWidget {
  final DictionaryLanguage lang;

  const _Header(this.lang);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(Icons.settings),
      ),
      title: Text(lang.symbol + '辞典'),
      backgroundColor: Colors.black87,
      centerTitle: true,
      elevation: 0.0,
    );
  }
}

class _Body extends StatefulWidget with RouterListener {
  final DictionaryLanguage lang;
  _BodyState _state;

  _Body(this.lang);

  @override
  _BodyState createState() => _state = _BodyState();

  @override
  void onViewDisplayed() => _state?.onViewDisplayed();
}

class _BodyState extends State<_Body> {
  static String _currentText;

  GlobalKey<_BodyState> _key;
  GlobalKey<FormState> _formKey;

  Dictionary get _dic => DictionaryContainer.instance.getPrimaryDictionary(widget.lang);

  TextEditingController _formController;
  ItemScrollController _itemScrollController;
  int _currentIndex;

  @override
  void initState() {
    super.initState();

    _key = GlobalKey<_BodyState>();
    _formKey = GlobalKey<FormState>();

    _formController = TextEditingController();
    _itemScrollController = ItemScrollController();
    _currentIndex = null;
  }

  @override
  void didUpdateWidget(var oldWidget) {
    super.didUpdateWidget(oldWidget);
    jumpTo(_currentText, enableScroll: false);
    _formController.text = _currentText;
  }

  Future<void> jumpTo(String text, {enableScroll = true}) async {
    var index = await _dic.getIndex(text);
    if (enableScroll && _currentIndex != null && (index - _currentIndex).abs() < 50) {
      await _itemScrollController.scrollTo(index: index, duration: Duration(milliseconds: 100));
    } else {
      _itemScrollController.jumpTo(index: index);
    }

    setState(() {
      _currentText = text;
      _currentIndex = index;
    });
  }

  void onViewDisplayed() => jumpTo(_formController.value.text);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      resizeToAvoidBottomInset: false,
      appBar: _Header(widget.lang),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextFormField(
                  controller: _formController,
                  decoration: const InputDecoration(
                    hintText: 'Enter a word',
                  ),
                  onChanged: (text) async {
                    if (_itemScrollController.isAttached && text.isNotEmpty) {
                      jumpTo(text);
                    }
                  },
                ),
              ),
            ),
            Expanded(
              flex: 9,
              child: Visibility(
                visible: _currentIndex != null,
                maintainState: true,
                child: ScrollablePositionedList.separated(
                  itemScrollController: _itemScrollController,
                  itemCount: _dic.size,
                  itemBuilder: (context, index) => FutureBuilder(
                    future: _dic.getWord(index),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return ListTile();
                      }

                      var word = snapshot.data;
                      return ListTile(
                        title: Text(
                          word.name,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          word.meaning,
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    },
                  ),
                  separatorBuilder: (BuildContext context, int index) => Divider(
                    color: Colors.black12,
                    height: 1,
                    thickness: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // widget samples: https://flutter.dev/docs/development/ui/widgets
    );
  }
}

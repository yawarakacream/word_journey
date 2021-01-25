import 'package:flutter/material.dart';

class RouterWidget extends StatefulWidget {
  final List<RouteRecord> _routes;

  final double iconSize;
  final double selectedFontSize;
  final double unselectedFontSize;
  final bool resizeToAvoidBottomInset;

  const RouterWidget(this._routes,
      {Key key,
      this.iconSize = 24,
      this.selectedFontSize = 14,
      this.unselectedFontSize = 12,
      this.resizeToAvoidBottomInset = true})
      : super(key: key);

  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<RouterWidget> {
  final List<BottomNavigationBarItem> _barItems = [];

  int _currentIndex = 0;

  List<RouteRecord> get _routes => widget._routes;

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < _routes.length; i++) {
      _barItems.add(_createBarItem(i, i == _currentIndex));
    }
  }

  BottomNavigationBarItem _createBarItem(int index, bool activated) {
    return BottomNavigationBarItem(
      icon: Icon(
        _routes[index].icon,
        color: activated ? Colors.black87 : Colors.black26,
      ),
      label: _routes[index].label,
    );
  }

  void _onItemTapped(int index) {
    if (_currentIndex == index) {
      return;
    }
    setState(() {
      if (_routes[_currentIndex].body is RouterListener) {
        (_routes[_currentIndex].body as RouterListener).onViewLeft();
      }

      _barItems[_currentIndex] = _createBarItem(_currentIndex, false);
      _currentIndex = index;

      _barItems[_currentIndex] = _createBarItem(index, true);
      if (_routes[_currentIndex].body is RouterListener) {
        (_routes[_currentIndex].body as RouterListener).onViewDisplayed();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _routes[_currentIndex].body,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      bottomNavigationBar: BottomNavigationBar(
        iconSize: widget.iconSize,
        selectedFontSize: widget.selectedFontSize,
        unselectedFontSize: widget.unselectedFontSize,
        type: BottomNavigationBarType.fixed,
        items: _barItems,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

abstract class RouteRecord {
  final String label;
  final IconData icon;
  final Widget body;

  const RouteRecord(this.label, this.icon, this.body);
}

abstract class RouterListener {
  void onViewDisplayed() {}
  void onViewLeft() {}
}

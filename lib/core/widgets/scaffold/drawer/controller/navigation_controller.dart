import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum MenuDestination { home, dormitory }

final navigationController = NavigationController();

class NavigationController extends ChangeNotifier {
  MenuDestination _destination = MenuDestination.home;
  bool isHomePage = true;

  MenuDestination get destination => _destination;

  void navigateTo(MenuDestination destination) {
    if (_destination == destination) return;
    _destination = destination;
    notifyListeners();
  }
}

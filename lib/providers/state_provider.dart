import 'package:flutter/material.dart';

class StateProvider extends ChangeNotifier {
  bool isLoggedIn = false;
  String code = '+39';
  bool appleAvailable = false;

  changedCode(value) {
    code = value;
    notifyListeners();
  }

  changeAppleAvailable(value) {
    appleAvailable = value;
  }

  changeLoggedIn(bool value) {
    isLoggedIn = value;
    notifyListeners();
  }
}

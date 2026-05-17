import 'package:flutter/material.dart';

class AppLocale extends ChangeNotifier {
  AppLocale(this._code);

  String _code;

  String get code => _code;
  Locale get locale => Locale(_code);

  void setLocale(String code) {
    if (_code == code) return;
    _code = code;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isPasswordVisible = false;
  String _password = '';
  String _email = '';

  bool get isPasswordVisible => _isPasswordVisible;
  String get password => _password;
  String get email => _email;

  get error => null;

  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  signInWithEmailAndPassword(String trim, String text) {}
}

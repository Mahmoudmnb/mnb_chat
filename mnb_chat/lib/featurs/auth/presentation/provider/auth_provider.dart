import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mnb_chat/featurs/auth/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  Future<String> signUp() async {
    try {
      var auth = FirebaseAuth.instance;
      var user = await auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      return '';
    } catch (e) {
      return e.toString();
    }
  }

  bool? visibl = false;
  bool isSignIn = false;
  bool validate = true;
  bool _isLoding = false;
  bool _isButtonLinding = false;
  String _name = '';
  String _email = '';
  String _password = '';
  late UserModel user;
  // states
  get isButtonLoding => _isButtonLinding;
  get isLoding => _isLoding;

  void setButtonLoding(bool loding) {
    _isButtonLinding = loding;
    notifyListeners();
  }

  void setLodingState(bool loding) {
    _isLoding = loding;
    notifyListeners();
  }

  void changeValidate(bool isValidate) {
    validate = isValidate;
    notifyListeners();
  }

  void visableChangeSatate() async {
    visibl = !visibl!;
    notifyListeners();
  }

  void changeSignInOrSignUp() {
    isSignIn = !isSignIn;
    notifyListeners();
  }

  set setName(newName) {
    _name = newName;
    notifyListeners();
  }

  set setEmail(newEmail) {
    _email = newEmail;
    notifyListeners();
  }

  set setPassword(newPassword) {
    _password = newPassword;
    notifyListeners();
  }
}

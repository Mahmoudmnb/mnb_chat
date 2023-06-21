import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mnb_chat/core/internet_info.dart';
import 'package:mnb_chat/featurs/auth/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import '../../../../core/constant.dart';
import '../../../chat/presentaion/pages/home_page.dart';

class AuthProvider extends ChangeNotifier {
  //!              *********************************  variable  **************************************************
  //* this duratoin for toast
  int duration = 2;
  //* this is for color of email icon
  Color colorOfEmailValidateIcon = Colors.black;
  //* this to show password or hide it
  bool? visibl = false;
  void visableChangeSatate() async {
    visibl = !visibl!;
    notifyListeners();
  }

  //* this is to detect signIn or signUp
  bool isSignIn = false;
  void changeSignInOrSignUp() {
    isSignIn = !isSignIn;
    notifyListeners();
  }

  //* this is for validate textFields
  bool validate = true;
  void changeValidate(bool isValidate) {
    validate = isValidate;
    notifyListeners();
  }

  //* this is to show circular progess
  bool _isLoding = false;
  get isLoding => _isLoding;
  void setLodingState(bool loading) {
    _isLoding = loading;
    notifyListeners();
  }

  //* this is to show circular progess
  get isButtonLoading => _isButtonLoanding;
  bool _isButtonLoanding = false;
  void setButtonLoding(bool loading) {
    _isButtonLoanding = loading;
    notifyListeners();
  }

  //* this is for name and email and password
  String _name = '';
  String _email = '';
  String _password = '';
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

  //!                      *************************************    Methods   *************************************************
  //* this method to signUp
  signUp(BuildContext context) async {
    bool isError = false;
    ToastContext toastContext = ToastContext();
    toastContext.init(context);
    var auth = FirebaseAuth.instance;
    bool isConnected = await InternetInfo.isconnected();
    if (isConnected) {
      try {
        await auth.createUserWithEmailAndPassword(
            email: _email.trim(), password: _password.trim());
      } on FirebaseAuthException catch (e) {
        if (e.code == 'unknown') {
          Toast.show('please check your vpn if you live in a forbidden city',
              duration: duration);
          _isButtonLoanding = false;
          notifyListeners();
        }
        if (e.code == 'weak-password') {
          Toast.show('The password provided is too weak.', duration: 2);
        } else if (e.code == 'email-already-in-use') {
          Toast.show('The account already exists for that email.', duration: 2);
        }
        isError = true;
      } catch (e) {
        Toast.show('somthing went wrong please try again', duration: 2);
        _isButtonLoanding = false;
        isError = true;
        notifyListeners();
      }
      if (!isError) {
        String? token = await FirebaseMessaging.instance.getToken();
        await FirebaseFirestore.instance.collection('users').doc(_email).set({
          'name': _name,
          'email': _email,
          'password': _password,
          'token': token
        });
        Constant.currentUsre = UserModel(
            name: _name, email: _email, token: token!, password: _password);
        SharedPreferences db = await SharedPreferences.getInstance();
        db.setString('currentUser', json.encode(Constant.currentUsre.toJson()));
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => HomePage(
            user: UserModel(
                token: token, name: _name, email: _email, password: _password),
          ),
        ));
      }
    } else {
      isError = true;
      Toast.show('Check you internet connection', duration: 2);
    }
  }

  //* this method to signIn
  signIn(context) async {
    bool isError = false;
    UserCredential? user;
    ToastContext toastContext = ToastContext();
    toastContext.init(context);
    var auth = FirebaseAuth.instance;
    bool isConnected = await InternetInfo.isconnected();
    if (isConnected) {
      try {
        user = await auth.signInWithEmailAndPassword(
            email: _email.trim(), password: _password.trim());
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-email') {
          Toast.show(' invalid-email', duration: 2);
        } else if (e.code == 'unknown') {
          Toast.show('please check your vpn if you live in a forbidden city',
              duration: 2);
          _isButtonLoanding = false;
          notifyListeners();
        } else if (e.code == 'user-not-found') {
          Toast.show('No user found for that email.', duration: 2);
        } else if (e.code == 'wrong-password') {
          Toast.show('Wrong password provided for that user.', duration: 2);
        } else {
          print(e.code);
        }
        isError = true;
      } catch (e) {
        print(e);
        isError = true;
      }
      if (!isError) {
        String? token = await FirebaseMessaging.instance.getToken();
        Constant.currentUsre = UserModel(
            name: _name,
            email: user!.user!.email!,
            token: token!,
            password: _password);
        SharedPreferences db = await SharedPreferences.getInstance();
        db.setString('currentUser', json.encode(Constant.currentUsre.toJson()));
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => HomePage(
            user: UserModel(
                token: token, name: _name, email: _email, password: _password),
          ),
        ));
      }
    }
  }

//   signInWithGoogelAccount(context) async {
//     // GoogleSignIn().signOut();
//     bool isError = false;
//     UserCredential? user;
//     ToastContext toastContext = ToastContext();
//     toastContext.init(context);
//     bool isConnected = await InternetInfo.isconnected();
//     if (isConnected) {
//       try {
//         final GoogleSignInAccount? googleUser =
//             await GoogleSignIn().signIn().onError((error, stackTrace) {
//           Toast.show('something went wrong please try again');
//           return null;
//         });
//         // Obtain the auth details from the request
//         final GoogleSignInAuthentication? googleAuth =
//             await googleUser?.authentication;
// 
//         // Create a new credential
//         final credential = GoogleAuthProvider.credential(
//           accessToken: googleAuth?.accessToken,
//           idToken: googleAuth?.idToken,
//         );
//         // Once signed in, return the UserCredential
//         var s = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(googleUser!.email)
//             .get();
//         print(googleUser.email);
//         print(s.data());
//         if (s.data() != null) {
//           await FirebaseAuth.instance
//               .signInWithCredential(credential)
//               .then((value) async {
//             String? token = await FirebaseMessaging.instance.getToken();
//             Constant.currentUsre = UserModel(
//                 name: _name,
//                 email: user!.user!.email!,
//                 token: token!,
//                 password: _password);
//             SharedPreferences db = await SharedPreferences.getInstance();
//             db.setString(
//                 'currentUser', json.encode(Constant.currentUsre.toJson()));
//             Navigator.of(context).pushReplacement(MaterialPageRoute(
//               builder: (context) => HomePage(
//                 user: UserModel(
//                     token: token,
//                     name: _name,
//                     email: _email,
//                     password: _password),
//               ),
//             ));
//           });
//         } else {
//           Toast.show('there is no account with this email try to signUp',
//               duration: duration);
//           GoogleSignIn().signOut();
//         }
//       } catch (e) {
//         Toast.show('something went wrong please try again');
// 
//         print(e);
//       }
//     } else {
//       Toast.show('please check you internet connection');
//     }
//   }

  //* when email field change
  onTextEmailChange(String value) {
    if (value.isEmpty) {
      colorOfEmailValidateIcon = Colors.black;
    } else if (!value.contains('@') || !value.endsWith('.com')) {
      colorOfEmailValidateIcon = Colors.red;
    } else {
      colorOfEmailValidateIcon = Colors.green;
    }
    notifyListeners();
  }

  changePassword() async {
    var re = await FirebaseAuth.instance
        .sendPasswordResetEmail(email: 'Mahmoudmnb2000.2004@gmail.com')
        .onError((error, stackTrace) => print(error));
  }
}

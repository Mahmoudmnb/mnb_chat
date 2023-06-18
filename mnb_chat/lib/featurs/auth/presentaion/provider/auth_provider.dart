import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool success = true;
  Future<bool> signIn() async {
    // var a = FirebaseAuth.instance.createUserWithEmailAndPassword(
    //     email: 'mahmoud@gmail.com', password: 'password');
    // return true;
    print('start sign in');
    FirebaseAuth auth = FirebaseAuth.instance;
    String myNumber = '+963968108307';
    String seriatelNumber = '+963980573740';
    String abdNumber = '+963947276369';
    await auth.verifyPhoneNumber(
      timeout: const Duration(minutes: 1),
      forceResendingToken: 10,
      phoneNumber: seriatelNumber,
      verificationCompleted: (phoneAuthCredential) async {
        print('success $phoneAuthCredential');
        // await auth.signInWithCredential(phoneAuthCredential);
        // success = true;
      },
      verificationFailed: (error) {
        success = false;
        print('error$error');
      },
      codeSent: (verificationId, forceResendingToken) async {
        print('code $verificationId');
        // String smsCode = '123123';
        // // Create a PhoneAuthCredential with the code
        // PhoneAuthCredential credential = PhoneAuthProvider.credential(
        //     verificationId: verificationId, smsCode: smsCode);
        // var s = await auth.signInWithCredential(credential);
        // success = true;
      },
      codeAutoRetrievalTimeout: (verificationId) {
        success = false;
        print('time out$verificationId');
      },
    );

    return success;
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:todo/utils.dart';

class FirebaseAuthentication {
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential?>? signUpWithEmailAndPassword(String username,
      String email, String password, BuildContext context) async {
    try {
      UserCredential user = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      user.user?.updateDisplayName(username);

      print(user.user!.uid);

      return user;
    } on FirebaseAuthException catch (e) {
      Utils.flushBarErrorMessage(e.code.toString(), context, Colors.red);
      if (kDebugMode) {
        print(e);
      }

      return null;
    }
  }

  Future<UserCredential?>? signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      UserCredential user = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return user;
    } on FirebaseAuthException catch (e) {
      Utils.flushBarErrorMessage(e.code.toString(), context, Colors.red);
      if (kDebugMode) {
        print(e);
      }

      return null;
    }
  }
}

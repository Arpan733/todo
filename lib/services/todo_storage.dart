import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class ToDoStorage {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> makeUser(
      String username, String email, String uid, BuildContext context) async {
    try {
      Map<String, String> userdata = {
        'username': username,
        'email': email,
      };

      await firestore.collection('tododata').doc(uid).set(userdata);
    } catch (e) {
      Utils.flushBarErrorMessage(
        e.toString(),
        context,
        Colors.red,
      );
    }
  }

  Future<void> addTask({
    required String uid,
    required String title,
    required String description,
    required String tid,
    required int nid,
    required String dateTime,
    required BuildContext context,
  }) async {
    try {
      Map<String, dynamic> taskData = {
        'title': title,
        'description': description,
        'id': tid,
        'taskTime': dateTime,
        'nid': nid,
        'createdTime': DateTime.now().toString(),
      };

      await firestore
          .collection("tododata")
          .doc(uid)
          .collection("todo")
          .doc(tid)
          .set(taskData);
    } catch (e) {
      Utils.flushBarErrorMessage(
        e.toString(),
        context,
        Colors.red,
      );
    }
  }

  Future<void> editTask({
    required String title,
    required String description,
    required String tid,
    required int nid,
    required String uid,
    required String dateTime,
    required BuildContext context,
  }) async {
    try {
      Map<String, dynamic> taskData = {
        'title': title,
        'description': description,
        'id': tid,
        'nid': nid,
        'taskTime': dateTime,
        'createdTime': DateTime.now().toString(),
      };

      await firestore
          .collection("tododata")
          .doc(uid)
          .collection("todo")
          .doc(tid)
          .update(taskData);
    } catch (e) {
      Utils.flushBarErrorMessage(
        e.toString(),
        context,
        Colors.red,
      );
    }
  }

  Future<String> getUserField(
      String title, String uid, BuildContext context) async {
    try {
      DocumentSnapshot snapshot =
          await firestore.collection("tododata").doc(uid).get();

      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

        if (data != null && data.containsKey(title)) {
          String userData = data[title];
          return userData;
        } else {
          return title;
        }
      } else {
        return title;
      }
    } catch (e) {
      Utils.flushBarErrorMessage(
        e.toString(),
        context,
        Colors.red,
      );

      return title;
    }
  }

  Future<void> editField(String title, String description, String uid,
      BuildContext context) async {
    try {
      Map<String, String> taskData = {
        title: description,
      };

      await firestore.collection("tododata").doc(uid).update(taskData);
    } catch (e) {
      Utils.flushBarErrorMessage(
        e.toString(),
        context,
        Colors.red,
      );
    }
  }

  Future<String> getUrl(String uid) async {
    try {
      Reference storageReference = FirebaseStorage.instance.ref().child(uid);
      print(uid);

      // Get the list of items (files) in the folder
      ListResult result = await storageReference.list();

      // Get the first item (file) in the list
      Reference firstImageReference = result.items.first;

      // Get the download URL of the first image
      String imageUrl = await firstImageReference.getDownloadURL();

      return imageUrl;
    } catch (e) {
      return '';
    }
  }
}

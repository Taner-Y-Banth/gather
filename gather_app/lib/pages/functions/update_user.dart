import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UpdateUser {
  void updateUser(username, imageUrl, user) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    if (user != null) {
      firestore.collection('users').doc(user.uid).set({
        'username': username,
        'email': user.email,
        'photo_url': imageUrl,
      });
    } else {
      const SnackBar(content: Text('User is not signed in'));
    }
  }
}

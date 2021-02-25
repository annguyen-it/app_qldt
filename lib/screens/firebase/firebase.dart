import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class Firebase {
  final FirebaseMessaging _firebaseMessaging;

  Firebase(this._firebaseMessaging);

  Future initialise() async {
    if (Platform.isIOS) {
      _firebaseMessaging
          .requestNotificationPermissions(IosNotificationSettings());
    }

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume: $message');
      },
    );
  }

  Future<String> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}

class FirebaseScreen extends StatelessWidget {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Widget build(BuildContext context) {
    final firebase = Firebase(_firebaseMessaging);
    firebase.initialise();
    return Container();
  }
}

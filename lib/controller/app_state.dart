import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import '../model/communities.dart';
import '../model/exercises.dart';
import '../model/users.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;
  List<Communities> allCommunities = [];
  List<Communities> get allTheCommunities => allCommunities;

  // 초기화 메서드
  Future<void> init() async {
    await _auth.signOut();
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
        notifyListeners();
      } else {
        _loggedIn = false;
      }
      notifyListeners();
    });
  }
}

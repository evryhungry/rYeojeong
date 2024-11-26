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

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
        _fetchUserDetails(user.uid);
        notifyListeners();
      } else {
        _loggedIn = false;
        _currentUser = null; // 로그아웃 시 현재 유저 초기화
      }
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _fetchUserDetails(userCredential.user!.uid);

      _loggedIn = true;
      notifyListeners(); // 상태 변경 알림
    } catch (e) {
      print('Failed to login: $e');
      rethrow; // 에러를 다시 던져서 UI에서 처리하도록 합니다.
    }
  }


  // Firestore에서 유저 정보 가져오기
  Future<void> _fetchUserDetails(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        _currentUser = UserModel(
          uid: userData['uid'],
          name: userData['username'],
          email: userData['email'], 
          password: userData['password'],
        );
      }
    } catch (e) {
      print('Failed to fetch user details: $e');
      _currentUser = null;
    }
  }

  Future<void> saveExerciseData(double distance, int elapsedSeconds) async {
    if (_currentUser == null) {
      print('No user is logged in');
      return;
    }

    final exercise = Exercises(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: _currentUser!.uid,
      distance: distance,
      stopWatch: elapsedSeconds,
      created_at: DateTime.now(),
    );

    try {
      await _firestore.collection('exercises').doc(exercise.id).set({
        'id': exercise.id,
        'userId': exercise.userId,
        'distance': exercise.distance,
        'stopWatch': exercise.stopWatch,
        'created_at': Timestamp.fromDate(exercise.created_at),
      });
      print('Exercise data saved successfully');
    } catch (e) {
      print('Failed to save exercise data: $e');
    }
    notifyListeners();
  }


}

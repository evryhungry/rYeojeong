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

  int _streakDays = 0;
  int _totalExerciseCount = 0;
  int _thisMonthExerciseCount = 0;
  double _progress = 0.0;

  int get streakDays => _streakDays;
  int get totalExerciseCount => _totalExerciseCount;
  int get thisMonthExerciseCount => _thisMonthExerciseCount;
  double get progress => _progress;


  Map<DateTime, List<Exercises>> _events = {};
  Map<DateTime, List<Exercises>> get events => _events;

  List<Communities> allCommunities = [];
  List<Communities> get allTheCommunities => allCommunities;

  List<Exercises> exercises = [];

  // 초기화 메서드
  Future<void> init() async {
    await _auth.signOut();
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _loggedIn = true;
        _fetchUserDetails(user.uid);
        fetchExerciseData();
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

  // Post Exercise 
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
      notifyListeners();
    } catch (e) {
      print('Failed to save exercise data: $e');
    }
  }

  // Get List Exercise
  Future<void> fetchExerciseData() async {
    try {
      final snapshot = await _firestore.collection('exercises').get();

      DateTime now = DateTime.now();
      Map<DateTime, List<Exercises>> tempEvents = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        // created_at 필드 확인
        final createdAt = (data['created_at'] as Timestamp).toDate();
        // Exercises 모델 생성
        final exercise = Exercises(
          id: data['id'],
          userId: data['userId'],
          distance: data['distance'].toDouble(),
          stopWatch: data['stopWatch'],
          created_at: createdAt,
        );

        // 날짜별로 그룹화
        final eventDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
        if (!tempEvents.containsKey(eventDate)) {
          tempEvents[eventDate] = [];
        }
        tempEvents[eventDate]!.add(exercise);
      }

      _events = tempEvents;
      print("새로운 날짜 추가: $_events");
      _totalExerciseCount = snapshot.docs.length;
      _thisMonthExerciseCount = _events.entries
          .where((entry) => entry.key.month == now.month && entry.key.year == now.year)
          .length;

      _streakDays = _calculateStreakDays();
      _progress = _thisMonthExerciseCount / 30; // 월간 진행률 (30일 기준)

      notifyListeners();
    } catch (e) {
      print('Failed to fetch exercises: $e');
    }
    notifyListeners();
  }

  int _calculateStreakDays() {
    List<DateTime> dates = _events.keys.toList()..sort();
    int streak = 0;

    for (int i = dates.length - 1; i > 0; i--) {
      if (dates[i].difference(dates[i - 1]).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak + 1; // 오늘 포함
  }

  Future<void> loadExercises() async {
    try {
      final snapshot = await _firestore.collection('exercises').get();

      exercises = snapshot.docs.map((doc) {
        final data = doc.data();
        final createdAt = (data['created_at'] as Timestamp).toDate();

        return Exercises(
          id: data['id'],
          userId: data['userId'],
          distance: data['distance'].toDouble(),
          stopWatch: data['stopWatch'],
          created_at: createdAt,
        );
      }).toList();

      print('Loaded Exercises: $exercises');
      notifyListeners(); // 상태 변경 알림
    } catch (e) {
      print('Failed to load exercises: $e');
    }
  }


  double calculateDailyCalories(DateTime date) {
    // 날짜 정규화
    final normalizedDate = DateTime(date.year, date.month, date.day);
    print('All Exercises: $exercises');

    final filteredExercises = exercises.where((exercise) {
      final exerciseDate = DateTime(
        exercise.created_at.year,
        exercise.created_at.month,
        exercise.created_at.day,
      );
      return exerciseDate == normalizedDate;
    }).toList();

    print('Date: $normalizedDate, Filtered Exercises: $filteredExercises');

    return filteredExercises.fold(0.0, (total, exercise) => total + exercise.caloriesBurned);
  }


  Future<List<MapEntry<DateTime, double>>> getWeeklyCalories() async {
    if (exercises.isEmpty) {
      await loadExercises(); // 데이터가 없으면 로드
    }

    DateTime today = DateTime.now();
    return List.generate(7, (index) {
      DateTime date = DateTime(today.year, today.month, today.day).subtract(Duration(days: index));
      double calories = calculateDailyCalories(date);
      return MapEntry(date, calories);
    }).reversed.toList();
  }

}

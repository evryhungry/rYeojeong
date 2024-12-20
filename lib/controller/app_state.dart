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
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
        loadMyCommunities();
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

  String? getCurrentUserId() {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid; // 현재 유저의 uid 반환
    }
    return null; // 유저가 로그인하지 않은 경우
  } catch (e) {
    debugPrint('Error fetching current user ID: $e');
    return null; // 오류가 발생한 경우
  }
}

  Future<void> updateDescriptionById(int id, String newDescription) async {
    try {
      // Firestore에서 `id`로 문서 검색
      final querySnapshot = await FirebaseFirestore.instance
          .collection('communities')
          .where('id', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // 문서 ID 가져오기
        final docId = querySnapshot.docs.first.id;

        // Firestore 문서 업데이트
        await FirebaseFirestore.instance
            .collection('communities')
            .doc(docId)
            .update({'description': newDescription});

        debugPrint("Document with id: $id updated successfully!");
      } else {
        debugPrint("No document found with id: $id");
      }
    } catch (e) {
      debugPrint("Error updating document: $e");
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
      await fetchExerciseData();
      notifyListeners();
    } catch (e) {
      print('Failed to save exercise data: $e');
    }
    notifyListeners();
  }

  // Get List Exercise
  Future<void> fetchExerciseData() async {
    try {
      // 현재 로그인된 사용자 확인
      if (_currentUser == null) {
        print('No user is logged in');
        return;
      }

      // 현재 사용자에 해당하는 운동 데이터만 가져오기
      final snapshot = await _firestore
          .collection('exercises')
          .where('userId', isEqualTo: _currentUser!.uid) // 현재 사용자의 userId로 필터링
          .get();

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

      // 상태 업데이트
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

  Future<void> saveToCommunities(Map<String, dynamic> communityData) async {
    try {
      // 데이터를 Firestore에 추가하고 DocumentReference 반환
      final docRef = await FirebaseFirestore.instance
          .collection('communities')
          .add(communityData);

      // Firestore에 저장된 문서의 ID를 communityData에 추가
      await FirebaseFirestore.instance
          .collection('communities')
          .doc(docRef.id)
          .update({'documentId': docRef.id}); // 문서 ID 추가

      debugPrint('Document added with ID: ${docRef.id}');
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving community: $e');
    }
  }

    Future<List<MapEntry<DateTime, double>>> getWeeklyCalories() async {
    if (_currentUser == null) {
      print('No user is logged in');
      return [];
    }

    if (exercises.isEmpty) {
      await loadExercises(); // 데이터가 없으면 로드
    }

    DateTime today = DateTime.now();

    // 로그인된 사용자의 운동 데이터만 필터링
    final userExercises = exercises.where((exercise) => exercise.userId == _currentUser!.uid).toList();

    return List.generate(7, (index) {
      DateTime date = DateTime(today.year, today.month, today.day).subtract(Duration(days: index));
      double calories = _calculateDailyCaloriesForUser(userExercises, date);
      return MapEntry(date, calories);
    }).reversed.toList();
  }

  // 특정 날짜의 칼로리 계산 (로그인된 사용자 데이터만)
  double _calculateDailyCaloriesForUser(List<Exercises> userExercises, DateTime date) {
    // 날짜 정규화
    final normalizedDate = DateTime(date.year, date.month, date.day);

    final filteredExercises = userExercises.where((exercise) {
      final exerciseDate = DateTime(
        exercise.created_at.year,
        exercise.created_at.month,
        exercise.created_at.day,
      );
      return exerciseDate == normalizedDate;
    }).toList();

    // 특정 날짜의 칼로리를 합산
    return filteredExercises.fold(0.0, (total, exercise) => total + exercise.caloriesBurned);
  }

  Future<void> loadMyCommunities() async {
    try {
      allCommunities = await fetchMyCommunities();
      notifyListeners(); // 상태 변경 알림
    } catch (e) {
      debugPrint('Error loading communities: $e');
    }
  }

  Future<List<Communities>> fetchMyCommunities() async {
    if (_currentUser == null) {
      print('No user is logged in');
      return [];
    }

    try {
      // 현재 유저의 커뮤니티만 가져오기
      QuerySnapshot snapshot = await _firestore
          .collection('communities')
          .where('userId', isEqualTo: _currentUser!.uid) // 현재 유저의 userId로 필터링
          .get();

      List<Communities> communities = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Firebase Storage에서 이미지 URL 가져오기
        String photoUrl = '';
        try {
          photoUrl = await FirebaseStorage.instance.ref(data['photo']).getDownloadURL();
        } catch (e) {
          photoUrl = 'assets/images/default_community.png'; // 기본 이미지
          debugPrint('Failed to fetch photo URL: $e');
        }

        // 커뮤니티 객체 생성
        communities.add(Communities(
          id: data['id'],
          name: data['name'],
          photo: photoUrl,
          description: data['description'],
          likes: data['likes'],
          created_at: (data['created_at'] as Timestamp).toDate(),
          userId: data['userId'],
          documentId: doc.id,
        ));
      }

      return communities;
    } catch (e) {
      debugPrint('Error fetching communities: $e');
      return [];
    }
  }


  Stream<List<Communities>> fetchCommunities() {
    // Firestore 컬렉션의 실시간 스트림 + id 필드를 기준으로 내림차순 정렬
    final communityStream = _firestore
        .collection('communities')
        .orderBy('id', descending: true) // id를 기준으로 내림차순 정렬
        .snapshots();

    // Firestore 데이터를 `Communities` 리스트로 변환
    return communityStream.asyncMap((QuerySnapshot snapshot) async {
      List<Communities> communities = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        try {
          // Firebase Storage에서 이미지 URL 가져오기
          String photoUrl = await _storage.ref(data['photo']).getDownloadURL();

          communities.add(Communities(
            id: data['id'],
            name: data['name'],
            photo: photoUrl,
            description: data['description'],
            likes: data['likes'],
            created_at: (data['created_at'] as Timestamp).toDate(),
            userId: data['userId'],
            documentId: doc.id,
          ));
        } catch (e) {
          debugPrint('Error fetching photo URL: $e');
        }
      }
      return communities; // 최종적으로 변환된 리스트 반환
    });
  }



   Future<void> deleteCommunity(String communityId) async {
    try {
      await FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .delete();
      print('Community with ID $communityId deleted.');
      notifyListeners();
    } catch (e) {
      print('Error deleting community: $e');
    }
  }

}

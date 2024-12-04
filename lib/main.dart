import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re/model/communities.dart';
import 'package:re/pages/addCommunity.dart';
import 'package:re/pages/community.dart';
import 'package:re/pages/detailCommunity.dart';
import 'package:re/pages/exercise.dart';
import 'package:re/pages/home.dart';
import 'package:re/pages/login.dart';
import 'package:re/pages/signup.dart';
import 'pages/loading.dart'; // LoginPage가 정의된 파일을 import
import 'controller/app_state.dart';
import 'pages/animal.dart';
import 'package:re/pages/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase 초기화
  runApp(
    ChangeNotifierProvider(
      create: (_) => ApplicationState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "rYeojung",
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      initialRoute: '/login/loading',
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == '/community') {
          final Communities community = settings.arguments as Communities;
          return MaterialPageRoute(
            builder: (context) => DetailcommunityPage(community: community),
          );
        }
        return null; // 다른 경로 처리
      },
      routes: {
        '/login/loading': (context) => ImageSlider(),
        '/login': (context) => LoginPage(),
        '/login/signup': (context) => SignupPage(),
        '/': (context) => HomePage(),
        '/community': (context) => CommunityPage(),
        '/exercise': (context) => ExercisePage(),
        '/community/add': (context) => AddCommunityPage(),
        '/animal': (context) => AnimalListScreen(),
        '/profile': (context) => ProfileScreen(),
      },
    );
  }
}

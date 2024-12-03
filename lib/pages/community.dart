import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../model/communities.dart';
import 'cardview.dart';
import 'addCommunity.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  late Future<List<Communities>> _communitiesFuture;

  @override
  void initState() {
    super.initState();
    _loadCommunities(); // 초기 데이터 로드
  }

  // 커뮤니티 데이터를 로드하는 메서드
  void _loadCommunities() {
    setState(() {
      _communitiesFuture = _fetchCommunities();
    });
  }

  // Firestore에서 커뮤니티 데이터 가져오기
  Future<List<Communities>> _fetchCommunities() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('communities').get();

      List<Communities> communities = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Firebase Storage에서 URL 가져오기
        String photoUrl = await _storage.ref(data['photo']).getDownloadURL();

        communities.add(Communities(
            id: data['id'],
            name: data['name'],
            photo: photoUrl,
            description: data['description'],
            likes: data['likes'],
            created_at: (data['created_at'] as Timestamp).toDate(),
            userId: data['userId'],
            documentId: doc.id));
      }

      return communities;
    } catch (e) {
      debugPrint('Error fetching communities: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            semanticLabel: 'back',
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('커뮤니티'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.add,
              semanticLabel: 'add',
            ),
            onPressed: () {
              // AddCommunityPage로 이동
              Navigator.pushNamed(context, '/community/add');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Communities>>(
        future: _communitiesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            debugPrint('Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            debugPrint('No data found');
            return const Center(child: Text('No communities found'));
          }
          debugPrint('Data loaded: ${snapshot.data}');
          return CardView(communityList: snapshot.data!);
        },
      ),
    );
  }
}

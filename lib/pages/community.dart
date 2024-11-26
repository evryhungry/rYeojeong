import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../model/Communities.dart';
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

  // Firestore에서 커뮤니티 데이터 가져오기
  Future<List<Communities>> _fetchCommunities() async {
    QuerySnapshot snapshot = await _firestore.collection('communities').get();

    List<Communities> communities = [];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      print('Document ID: ${doc.id}');
      print('Data: $data');
      print('id: ${data['id']}, likes: ${data['likes']}');

      // Firebase Storage에서 URL 가져오기
      String photoUrl = await _storage
          .ref(data['photo']) // 예: 'pet1.png'
          .getDownloadURL();

      communities.add(Communities(
        id: data['id'],
        name: data['name'],
        photo: photoUrl, // URL 가져오기 완료
        description: data['description'],
        likes: data['likes'],
        created_at: (data['created_at'] as Timestamp).toDate(),
        userId: data['userId'],
      ));
    }

    return communities;
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
              Navigator.pushNamed(context, '/community/add');
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Communities>>(
        future: _fetchCommunities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print('No data found');
            return const Center(child: Text('No communities found'));
          }
          print('Data loaded: ${snapshot.data}');
          return CardView(communityList: snapshot.data!);
        },
      ),
    );
  }
}

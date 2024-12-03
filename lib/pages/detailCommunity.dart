import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/communities.dart';
import 'editCommunity.dart';
import '../model/communities.dart';

class DetailcommunityPage extends StatefulWidget {
  final Communities community;

  const DetailcommunityPage({super.key, required this.community});

  @override
  State<DetailcommunityPage> createState() => _DetailcommunityPageState();
}

class _DetailcommunityPageState extends State<DetailcommunityPage> {
  late Communities community;

  @override
  void initState() {
    super.initState();
    community = widget.community; // 초기 데이터 설정
  }

  Future<void> deleteCommunity(String communityId) async {
    // 데이터베이스에서 데이터 삭제 로직 구현
    // 예: await DatabaseService.deleteCommunity(communityId);
    // 실제 구현은 프로젝트의 데이터베이스 설정에 따라 변경
    print('Community with ID $communityId deleted.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("${community.name}님의 여정"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.edit,
              semanticLabel: 'edit',
            ),
            onPressed: () async {
              // EditCommunityPage로 이동하여 수정된 데이터 받기
              final updatedCommunity = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditCommunityPage(community: community),
                ),
              );

              // 수정된 데이터가 null이 아닐 경우 UI 업데이트
              if (updatedCommunity != null) {
                setState(() {
                  community = updatedCommunity;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.delete,
              semanticLabel: 'delete',
            ),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('삭제 확인'),
                    content: const Text('이 커뮤니티를 삭제하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('삭제'),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                try {
                  await FirebaseFirestore.instance
                      .collection('communities')
                      .doc(community.documentId) // 문서 ID 사용
                      .delete();
                  Navigator.pop(context); // 삭제 후 이전 화면으로 이동
                } catch (e) {
                  print('삭제 중 오류 발생: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('삭제 중 오류가 발생했습니다. 다시 시도해주세요.')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                community.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${community.created_at.year}-${community.created_at.month}-${community.created_at.day}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 250.0,
                child: Image.network(
                  community.photo,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported);
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              Text(
                community.description,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/communities.dart';
import 'editCommunity.dart';
import '../controller/app_state.dart'; // ApplicationState import

class DetailcommunityPage extends StatefulWidget {
  final Communities community;

  const DetailcommunityPage({super.key, required this.community});

  @override
  State<DetailcommunityPage> createState() => _DetailcommunityPageState();
}

class _DetailcommunityPageState extends State<DetailcommunityPage> {
  late Communities community;
  String? currentUserId; // 현재 로그인된 사용자 ID

  @override
  void initState() {
    super.initState();
    community = widget.community;
  }

  @override
  Widget build(BuildContext context) {
    final appstate = Provider.of<ApplicationState>(context, listen: false);
    final userId = appstate.getCurrentUserId();
    final isOwner = userId == community.userId;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("${community.name}님의 여정"),
        actions: isOwner
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final updatedCommunity = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditCommunityPage(community: community),
                      ),
                    );

                    if (updatedCommunity != null) {
                      setState(() {
                        community = updatedCommunity;
                      });
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('삭제 확인'),
                        content: const Text('당신의 여정에서 삭제하시겠습니까?'),
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
                      ),
                    );

                    if (confirm == true) {
                      try {
                        await appstate.deleteCommunity(community.documentId);
                        Navigator.pop(context);
                      } catch (e) {
                        print('삭제 중 오류 발생: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('삭제 중 오류가 발생했습니다. 다시 시도해주세요.')),
                        );
                      }
                    }
                  },
                ),
              ]
            : null, // 소유자가 아닐 경우 액션 버튼 숨기기
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

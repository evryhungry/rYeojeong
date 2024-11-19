import 'package:flutter/material.dart';

class Post {
  final String author;
  final String content;
  final DateTime timestamp;

  Post({required this.author, required this.content, required this.timestamp});
}

class AddcommunityPage extends StatefulWidget {
  const AddcommunityPage(
      {super.key, required Null Function(dynamic newPost) onPostAdded});

  @override
  State<AddcommunityPage> createState() => _AddcommunityPageState();
}

class _AddcommunityPageState extends State<AddcommunityPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('새 게시글 작성'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              // controller: _contentController,
              decoration: InputDecoration(
                labelText: '내용',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final newPost = Post(
                  author: '현재 사용자', // 실제 구현 시 사용자 정보 사용
                  content: "stt",
                  timestamp: DateTime.now(),
                );
                // onPostAdded(newPost);
                Navigator.pop(context);
              },
              child: Text('게시'),
            ),
          ],
        ),
      ),
    );
  }
}

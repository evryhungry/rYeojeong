import 'package:flutter/material.dart';
import 'package:re/pages/community.dart';

class Post {
  final String author;
  final String content;
  final DateTime timestamp;

  Post({required this.author, required this.content, required this.timestamp});
}

class DetailcommunityPage extends StatefulWidget {
  const DetailcommunityPage({super.key});

  @override
  State<DetailcommunityPage> createState() => _DetailcommunityPageState();
}

class _DetailcommunityPageState extends State<DetailcommunityPage> {
  late final Post post;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 상세'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.author,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              '${post.timestamp.year}-${post.timestamp.month}-${post.timestamp.day} ${post.timestamp.hour}:${post.timestamp.minute}',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(post.content),
          ],
        ),
      ),
    );
  }
}

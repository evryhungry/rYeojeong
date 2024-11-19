import 'package:flutter/material.dart';
import 'package:re/pages/addCommunity.dart';
import 'package:re/pages/detailCommunity.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  // 게시글 목록 데이터
  List<Post> posts = [
    // 예시 데이터
    Post(author: '사용자1', content: '첫 번째 게시글 내용', timestamp: DateTime.now()),
    Post(
        author: '사용자2',
        content: '두 번째 게시글 내용',
        timestamp: DateTime.now().subtract(Duration(hours: 1))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('커뮤니티'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // 새 게시글 작성 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AddcommunityPage(onPostAdded: (newPost) {
                          setState(() {
                            posts.insert(0, newPost);
                          });
                        })),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return ListTile(
            title: Text(post.author),
            subtitle: Text(post.content),
            trailing: Text(
              '${post.timestamp.hour}:${post.timestamp.minute}',
              style: TextStyle(fontSize: 12),
            ),
            onTap: () {
              // 게시글 상세 페이지로 이동
              //   Navigator.push(
              //     context,
              //   //   MaterialPageRoute(
              //   //       // builder: (context) => DetailcommunityPage(post: post)),
              //   // );
            },
          );
        },
      ),
    );
  }
}

class Post {
  final String author;
  final String content;
  final DateTime timestamp;

  Post({required this.author, required this.content, required this.timestamp});
}

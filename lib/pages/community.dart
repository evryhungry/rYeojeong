import 'package:flutter/material.dart';

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
    Post(author: '사용자2', content: '두 번째 게시글 내용', timestamp: DateTime.now().subtract(Duration(hours: 1))),
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
                MaterialPageRoute(builder: (context) => NewPostPage(onPostAdded: (newPost) {
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PostDetailPage(post: post)),
              );
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

class NewPostPage extends StatelessWidget {
  final Function(Post) onPostAdded;

  NewPostPage({required this.onPostAdded});

  final TextEditingController _contentController = TextEditingController();

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
              controller: _contentController,
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
                  content: _contentController.text,
                  timestamp: DateTime.now(),
                );
                onPostAdded(newPost);
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

class PostDetailPage extends StatelessWidget {
  final Post post;

  PostDetailPage({required this.post});

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

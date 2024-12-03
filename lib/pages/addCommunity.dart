import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddCommunityPage extends StatefulWidget {
  const AddCommunityPage({super.key});

  @override
  State<AddCommunityPage> createState() => _AddCommunityPageState();
}

class _AddCommunityPageState extends State<AddCommunityPage> {
  final TextEditingController _contentController = TextEditingController();
  XFile? image;
  String? username;

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          setState(() {
            username = userDoc.data()?['username'] ?? 'Unknown User';
          });
        }
      } catch (e) {
        debugPrint('Error fetching username: $e');
      }
    }
  }

  Future<void> uploadImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        image = pickedImage;
      });
    }
  }

  Future<String> uploadImageToStorage(XFile image) async {
    try {
      // 이미지 파일 이름만 생성
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      // Firebase Storage에 이미지 업로드
      final ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putFile(File(image.path));
      debugPrint('Image uploaded successfully: $fileName');
      return fileName; // 파일 이름만 반환
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return 'default.png'; // 실패 시 기본 이미지 사용
    }
  }

  Future<String> uploadDefaultImage() async {
    try {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/default.png';
      final byteData = await rootBundle.load('assets/default.png');

      final file = File(path);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      final ref = FirebaseStorage.instance.ref().child('default.png');
      await ref.putFile(file);
      debugPrint('Default image uploaded successfully: default.png');
      return 'default.png'; // 기본 파일 이름 반환
    } catch (e) {
      debugPrint('Error uploading default image: $e');
      return 'default.png';
    }
  }

  Future<int> getNextId() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('communities').get();
      return querySnapshot.docs.length + 1;
    } catch (e) {
      debugPrint('Error getting document count: $e');
      return 1;
    }
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
    } catch (e) {
      debugPrint('Error saving community: $e');
    }
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
        title: const Text('새로운 여정 작성'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            image != null
                ? Image.file(
                    File(image!.path),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 3,
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    // 기본 이미지 URL 생성
                    'https://firebasestorage.googleapis.com/v0/b/ryeojeong-5a430.firebasestorage.app/o/default.png?alt=media&token=a7e84f8e-3d6f-40a0-a927-90b66c68a397',
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 3,
                    fit: BoxFit.cover,
                  ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () async {
                  await uploadImage();
                },
                icon: const Icon(Icons.photo_camera),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: '내용',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  debugPrint('User not logged in');
                  return;
                }

                int nextId = await getNextId();
                String imageFileName;

                if (image == null) {
                  imageFileName = await uploadDefaultImage(); // default.png 업로드
                } else {
                  imageFileName =
                      await uploadImageToStorage(image!); // 선택된 이미지 업로드
                }

                final communityData = {
                  'description': _contentController.text,
                  'photo': imageFileName,
                  'created_at': DateTime.now(),
                  'id': nextId,
                  'likes': 0,
                  'name': username ?? 'Unknown User',
                  'userId': user.uid,
                };

                // 데이터 저장
                await saveToCommunities(communityData);
                Navigator.pop(context);
              },
              child: const Text(
                '여정 공유',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.orange,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/communities.dart';

class EditCommunityPage extends StatefulWidget {
  final Communities community;

  const EditCommunityPage({super.key, required this.community});

  @override
  State<EditCommunityPage> createState() => _EditCommunityPageState();
}

class _EditCommunityPageState extends State<EditCommunityPage> {
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _descriptionController =
        TextEditingController(text: widget.community.description);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> updateDescriptionById(int id, String newDescription) async {
    try {
      // Firestore에서 `id`로 문서 검색
      final querySnapshot = await FirebaseFirestore.instance
          .collection('communities')
          .where('id', isEqualTo: id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // 문서 ID 가져오기
        final docId = querySnapshot.docs.first.id;

        // Firestore 문서 업데이트
        await FirebaseFirestore.instance
            .collection('communities')
            .doc(docId)
            .update({'description': newDescription});

        debugPrint("Document with id: $id updated successfully!");
      } else {
        debugPrint("No document found with id: $id");
      }
    } catch (e) {
      debugPrint("Error updating document: $e");
    }
  }

  void _saveChanges() async {
    final updatedDescription = _descriptionController.text;

    // Firestore 데이터베이스 업데이트
    await updateDescriptionById(widget.community.id, updatedDescription);

    // 수정된 데이터를 반환하여 화면 상태 업데이트
    final updatedCommunity = widget.community.copyWith(
      description: updatedDescription,
    );

    Navigator.pop(context, updatedCommunity); // 수정된 데이터 전달
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
        title: Text("${widget.community.name}님의 게시글 수정"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.check, semanticLabel: 'save'),
            onPressed: _saveChanges, // 수정 내용 저장
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SizedBox(
            width: double.infinity,
            height: 250.0,
            child: Image.network(
              widget.community.photo,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported);
              },
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "게시글 수정",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            maxLines: 5,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "내용을 입력하세요",
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../model/Communities.dart';

class CardView extends StatelessWidget {
  const CardView({super.key, required this.communityList});

  final List<Communities> communityList;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: communityList.length,
      itemBuilder: (context, index) {
        final community = communityList[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 이미지 및 이름
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        community.photo, // Storage에서 가져온 URL (프로필 사진)
                      ),
                      radius: 20.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      community.name, // 사용자 이름
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              // 메인 이미지
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  community.photo, // Storage에서 가져온 메인 이미지
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported);
                  },
                ),
              ),
              // 하단 아이콘 및 동작
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            // 좋아요 버튼 동작
                          },
                          icon: const Icon(Icons.favorite_border),
                        ),
                        const SizedBox(width: 8.0),
                        IconButton(
                          onPressed: () {
                            // 댓글 버튼 동작
                          },
                          icon: const Icon(Icons.chat_bubble_outline),
                        ),
                        const SizedBox(width: 8.0),
                        IconButton(
                          onPressed: () {
                            // 공유 버튼 동작
                          },
                          icon: const Icon(Icons.share),
                        ),
                      ],
                    ),
                    // 슬라이드 인디케이터
                    Row(
                      children: [
                        _buildDot(active: true),
                        _buildDot(active: false),
                        _buildDot(active: false),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 슬라이드 인디케이터 점
  Widget _buildDot({required bool active}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Container(
        width: 8.0,
        height: 8.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? Colors.black : Colors.grey,
        ),
      ),
    );
  }
}

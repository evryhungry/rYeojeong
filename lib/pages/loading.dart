import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // 패키지 추가
import 'login.dart';

class ImageSlider extends StatefulWidget {
  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final PageController _pageController = PageController(); 

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController, // PageController 연결
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/first.png',
                        fit: BoxFit.contain, 
                      ),
                    ),
                    Center(
                      child: Image.asset(
                        'assets/second.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    Center(
                      child: Image.asset(
                        'assets/third.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // SmoothPageIndicator
          Positioned(
            bottom: 250, 
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController, 
                count: 3, 
                effect: ExpandingDotsEffect(
                  dotWidth: 8.0,
                  dotHeight: 8.0,
                  activeDotColor: theme.primaryColorLight,
                  dotColor: Colors.grey.shade300,
                ), 
              ),
            ),
          ),
          // ElevatedButton
          Positioned(
            bottom: 100, // 화면 아래로부터 30px 위
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColorLight,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                '여정 함께 떠나기',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white, // 텍스트 색상 설정
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w700 // 이탤릭체 설정
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

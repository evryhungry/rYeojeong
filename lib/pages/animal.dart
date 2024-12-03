import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:html/parser.dart'; // HTML 파싱 패키지

class AnimalListScreen extends StatefulWidget {
  @override
  _AnimalListScreenState createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends State<AnimalListScreen> {
  List<Map<String, String>> animals = []; // 동물 정보와 사진 데이터 리스트
  bool isLoading = true; // 로딩 상태 관리

  @override
  void initState() {
    super.initState();
    fetchAnimalData();
  }

  Future<void> fetchAnimalData() async {
    final infoApiKey = '634950614967757336334a4971434d'; // 동물 정보 API 키
    final photoApiKey = '596643614467757338354d6754614f'; // 동물 사진 API 키

    final infoEndpoint =
        'http://openapi.seoul.go.kr:8088/$infoApiKey/xml/TbAdpWaitAnimalView/1/48/';
    try {
      final infoResponse = await http.get(Uri.parse(infoEndpoint));

      if (infoResponse.statusCode == 200) {
        final document = xml.XmlDocument.parse(infoResponse.body);

        final rows = document.findAllElements('row');

        final animalList = rows.map((row) {
          final entranceDateElement = row.findElements('ENTRNC_DATE');
          final entranceDate = entranceDateElement.isNotEmpty
              ? entranceDateElement.first.text.trim() // 데이터 정리
              : 'Unknown'; // 기본값
          return {
            'animal_no': row.findElements('ANIMAL_NO').isNotEmpty
                ? row.findElements('ANIMAL_NO').first.text
                : 'Unknown',
            'name': row.findElements('NM').isNotEmpty
                ? row.findElements('NM').first.text
                : 'Unknown',
            'species': row.findElements('SPCS').isNotEmpty
                ? row.findElements('SPCS').first.text
                : 'Unknown',
            'age': row.findElements('AGE').isNotEmpty
                ? row.findElements('AGE').first.text
                : 'Unknown',
            'entrance_date': row.findElements('ENTRNC_DATE').isNotEmpty
                ? row.findElements('ENTRNC_DATE').first.text
                : 'Unknown',
            'introduction_content': row.findElements('INTRCN_CN').isNotEmpty
                ? row.findElements('INTRCN_CN').first.text
                : '없음',
            'photo_url': '',
          };
        }).toList();
        animalList.sort((a, b) {
          final dateA =
              DateTime.tryParse(a['entrance_date'] ?? '') ?? DateTime(9999);
          final dateB =
              DateTime.tryParse(b['entrance_date'] ?? '') ?? DateTime(9999);
          return dateA.compareTo(dateB); // 오래된 순으로 정렬
        });

        final photoEndpoint =
            'http://openapi.seoul.go.kr:8088/$photoApiKey/xml/TbAdpWaitAnimalPhotoView/1/500/';
        final photoResponse = await http.get(Uri.parse(photoEndpoint));

        if (photoResponse.statusCode == 200) {
          final photoDocument = xml.XmlDocument.parse(photoResponse.body);
          final photoRows = photoDocument.findAllElements('row');

          for (var animal in animalList) {
            final animalNo = animal['animal_no'];
            final matchingPhoto = photoRows.firstWhere(
              (photo) => photo.findElements('ANIMAL_NO').first.text == animalNo,
              orElse: () => xml.XmlElement(xml.XmlName('')),
            );

            if (matchingPhoto.children.isNotEmpty) {
              final photoUrlElement =
                  matchingPhoto.findElements('PHOTO_URL').firstOrNull;
              if (photoUrlElement != null) {
                animal['photo_url'] = photoUrlElement.text.startsWith('http')
                    ? photoUrlElement.text
                    : 'http://${photoUrlElement.text}';
              }
            }
          }
        }

        setState(() {
          animals = animalList;
          isLoading = false;
        });
      } else {
        print('동물 정보 API 호출 실패: ${infoResponse.statusCode}');
      }
    } catch (e) {
      print('오류 발생: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '여정을 함께하세요',
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true, // 제목을 중앙에 정렬
        leading: IconButton(
          icon: Icon(Icons.arrow_back), // 뒤로 가기 버튼
          onPressed: () {
            Navigator.pop(context); // 뒤로 가기 동작
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: animals.length,
              itemBuilder: (context, index) {
                final animal = animals[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      animal['photo_url'] != null &&
                              animal['photo_url']!.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AnimalDetailScreen(animal: animal),
                                  ),
                                );
                              },
                              child: Image.network(
                                animal['photo_url']!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(Icons.error, size: 100);
                                },
                              ),
                            )
                          : Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: Icon(Icons.image_not_supported, size: 100),
                            ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('이름: ${animal['name']}',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('종: ${animal['species']}',
                                style: TextStyle(fontSize: 16)),
                            Text('나이: ${animal['age']}',
                                style: TextStyle(fontSize: 16)),
                            Text('입소 날짜: ${animal['entrance_date']}',
                                style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class AnimalDetailScreen extends StatelessWidget {
  final Map<String, String> animal;

  AnimalDetailScreen({required this.animal});

  @override
  Widget build(BuildContext context) {
    // name 값에서 ()와 그 안의 내용을 제거
    final originalName = animal['name'] ?? 'Unknown';
    final cleanedName = originalName.replaceAll(RegExp(r'\s*\(.*?\)'), '');

    final rawHtml = animal['introduction_content'] ?? '없음';
    final document = parse(rawHtml);
    final plainText = document.body?.text ?? '없음'; // HTML을 텍스트로 변환

    return Scaffold(
      appBar: AppBar(
        title: Text('$cleanedName의 지난 여정'), // 정리된 이름으로 제목 표시
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (animal['photo_url'] != null && animal['photo_url']!.isNotEmpty)
              Center(
                child: Image.network(
                  animal['photo_url']!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error, size: 100);
                  },
                ),
              ),
            SizedBox(height: 20),
            Text('이름: $cleanedName', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('종: ${animal['species']}', style: TextStyle(fontSize: 18)),
            Text('나이: ${animal['age']}', style: TextStyle(fontSize: 18)),
            Text('입소 날짜: ${animal['entrance_date']}',
                style: TextStyle(fontSize: 18)),
            Divider(),
            Text(plainText, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

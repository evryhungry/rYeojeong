import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../model/communities.dart';
import '../controller/app_state.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appstate = Provider.of<ApplicationState>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("주간 여정"),
        backgroundColor: theme.primaryColorLight,
      ),
      body: FutureBuilder<List<Communities>>(
        future: appstate.fetchMyCommunities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final communities = snapshot.data ?? [];
          final weeklyCaloriesFuture = appstate.getWeeklyCalories();

          return FutureBuilder<List<MapEntry<DateTime, double>>>(
            future: weeklyCaloriesFuture,
            builder: (context, caloriesSnapshot) {
              if (caloriesSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (caloriesSnapshot.hasError) {
                return Center(child: Text('Error: ${caloriesSnapshot.error}'));
              }

              final weeklyData = caloriesSnapshot.data ?? [];
              final totalCalories = weeklyData.fold(
                0.0,
                (sum, entry) => sum + entry.value,
              );

              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // 그래프 영역
                  Container(
                    height: 300, // 고정된 높이 설정
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: BarChart(
                      BarChartData(
                        barGroups: weeklyData.map((entry) {
                          int index = weeklyData.indexOf(entry);
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: entry.value,
                                width: 14,
                                color: theme.primaryColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  "${value.toInt()} kcal",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                int index = value.toInt();
                                if (index >= 0 && index < weeklyData.length) {
                                  return Text(
                                    "${weeklyData[index].key.day}/${weeklyData[index].key.month}",
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  );
                                }
                                return const Text("");
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          drawHorizontalLine: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.withOpacity(0.2),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        borderData: FlBorderData(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 칼로리 소모량 텍스트
                  Column(
                    children: [
                      Text(
                        "일주일간 ${totalCalories.toStringAsFixed(1)} kcal",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "소모하셨습니다!",
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "매일 꾸준히 산책하면 건강에 더 좋아요 😊",
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // GridView로 커뮤니티 사진 표시
                  Container(
                    height: 300, // GridView의 고정 높이 설정
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(), // 내부 스크롤 비활성화
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
                      ),
                      itemCount: communities.length,
                      itemBuilder: (context, index) {
                        final community = communities[index];
                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              community.photo,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.image_not_supported);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

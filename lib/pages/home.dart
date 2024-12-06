import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../controller/app_state.dart';
import '../model/exercises.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _selectedIndex = 0;

  final List<String> _routes = [
    '/',
    '/community',
    '/exercise',
    '/animal',
    '/profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pushNamed(context, _routes[index]);
  }

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<ApplicationState>(context, listen: false);
    appState.fetchExerciseData().then((_) {
      setState(() {}); // UI 강제 갱신
    });
  }

  List<Exercises> _getEventsForDay(DateTime day) {
    final appState = Provider.of<ApplicationState>(context, listen: false);
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return appState.events[normalizedDay] ?? [];
  }

  String formatStopWatch(int totalSeconds) {
    int hours = totalSeconds ~/ 3600; // 시간 계산
    int minutes = (totalSeconds % 3600) ~/ 60; // 분 계산
    int seconds = totalSeconds % 60; // 초 계산

    // HH:mm:ss 형식으로 반환
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _showExerciseDetails(BuildContext context, DateTime selectedDay) {
    final exercises = _getEventsForDay(selectedDay);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 10, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${selectedDay.month}월 ${selectedDay.day}일 산책",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              if (exercises.isEmpty)
                Center(child: Text("운동 기록이 없습니다."))
              else
                ...exercises.map((exercise) => ListTile(
                      title: Text(
                        "거리: ${exercise.distance.toStringAsFixed(1)}km",
                        style: TextStyle(fontSize: 16),
                      ),
                      subtitle: Text(
                        "시간: ${formatStopWatch(exercise.stopWatch)}",
                      ),
                      leading: Icon(Icons.directions_walk),
                    )),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = Provider.of<ApplicationState>(context);

    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.menu),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 4, 16, 8),
          child: Column(
            children: [
              // 1. TableCalendar
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                  // 운동 기록 상세 창 표시
                  _showExerciseDetails(context, selectedDay);
                },
                calendarFormat: CalendarFormat.month,
                startingDayOfWeek: StartingDayOfWeek.monday,
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: theme.primaryColorLight,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: theme.primaryColorDark,
                    shape: BoxShape.circle,
                  ),
                  markersAutoAligned: true,
                  markerSizeScale: 0.2,
                ),
                eventLoader: _getEventsForDay,
              ),

              SizedBox(height: 20),

              // 2. Progress Indicator (운동 진행률)
              ProgressIndicatorWidget(progress: appState.progress),

              SizedBox(height: 20),

              // 3. 통계 위젯 (걸음수, 운동 시간)
              StatisticsWidget(
                streakDays: appState.streakDays,
                totalExerciseCount: appState.totalExerciseCount,
                thisMonthExerciseCount: appState.thisMonthExerciseCount,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: "Community"),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: "Exercise"),
          BottomNavigationBarItem(
              icon: Icon(Icons.family_restroom), label: "Yeojung"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ProgressIndicatorWidget extends StatelessWidget {
  final double progress;

  const ProgressIndicatorWidget({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 10, 16, 10),
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "운동 진행률",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          LinearProgressIndicator(
            minHeight: 10.0,
            value: progress, // 진행률
            backgroundColor: Colors.grey[500],
            color: Colors.yellow,
          ),
        ],
      ),
    );
  }
}

class StatisticsWidget extends StatelessWidget {
  final int streakDays;
  final int totalExerciseCount;
  final int thisMonthExerciseCount;

  const StatisticsWidget({
    required this.streakDays,
    required this.totalExerciseCount,
    required this.thisMonthExerciseCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16.0, 20, 16, 16),
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          StatisticColumn(label: "연속 출석일", value: "$streakDays 일"),
          StatisticColumn(label: "총 운동 횟수", value: "$totalExerciseCount 회"),
          StatisticColumn(label: "이번 달 운동", value: "$thisMonthExerciseCount 회"),
        ],
      ),
    );
  }
}

class StatisticColumn extends StatelessWidget {
  final String label;
  final String value;

  const StatisticColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

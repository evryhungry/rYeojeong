class Exercises {
  final String id;
  final String userId;
  final double distance;
  final int stopWatch;
  final DateTime created_at;
  
  static const double dogWeight = 13.0;
  static const double walkingCaloriesPerMinute = 0.03;


  const Exercises({
    required this.id,
    required this.userId,
    required this.distance,
    required this.created_at,
    required this.stopWatch,
  });

  double get caloriesBurned {
    double durationInHours = stopWatch / 3600.0; // 초를 시간으로 변환
    double speed = distance / durationInHours; // km/h로 계산

    // 속도에 따른 강도 계수 설정
    double intensityFactor;
    if (speed <= 4.0) {
      intensityFactor = 1.0; // 걷기
    } else if (speed <= 10.0) {
      intensityFactor = 1.5; // 가벼운 달리기
    } else {
      intensityFactor = 2.0; // 고강도 달리기
    }
    return walkingCaloriesPerMinute * dogWeight * (stopWatch / 60.0) * intensityFactor;
  }
}

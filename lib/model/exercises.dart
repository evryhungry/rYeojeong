class Exercises {
  final String id;
  final String userId;
  final double distance;
  final int stopWatch;
  final DateTime created_at;
  
  static const double dogWeight = 13.0;
  static const double walkingCaloriesPerMinute = 0.15;


  const Exercises({
    required this.id,
    required this.userId,
    required this.distance,
    required this.created_at,
    required this.stopWatch,
  });

  double get caloriesBurned {
    double durationInHours = stopWatch / 60.0; 
    double speed = distance / durationInHours * 1000; 

    // 속도에 따른 강도 계수 설정
    double intensityFactor;
    if (speed <= 4.0) {
      intensityFactor = 3.0; // 걷기
    } else if (speed <= 10.0) {
      intensityFactor = 6.0; // 가벼운 달리기
    } else {
      intensityFactor = 8.0; // 고강도 달리기
    }
    return walkingCaloriesPerMinute * dogWeight * (stopWatch / 60.0) * intensityFactor;
  }
}

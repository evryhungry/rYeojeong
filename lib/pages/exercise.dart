import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import '../controller/app_state.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({super.key});
  
  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  CameraPosition? _initialCameraPosition;
  Location location = Location();
  bool isRunning = false;
  Timer? _timer;
  int elapsedSeconds = 0;
  double totalDistance = 0.0;
  LatLng? previousPosition;


  @override
  // ㅊ초기상태
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  //초기 로컬 우치정보 허가 미허가., 초기 위치 본인 위치 설정
  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          print("User denied enabling location services.");
          return;
        }
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          print("User denied location permission.");
          return;
        }
      }
            

      LocationData currentLocation = await location.getLocation();
      print("Current Location: ${currentLocation.latitude}, ${currentLocation.longitude}");
      setState(() {
        _initialCameraPosition = CameraPosition(
          target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
          zoom: 16,
        );
      });
      
    } catch (e) {
      print('Failed to get location: $e');
    }
  }


  // 거리 정보 설정
  void _updateDistance(LocationData newLocation) {
    if (!isRunning) return;

    final currentPosition = LatLng(newLocation.latitude!, newLocation.longitude!);
    if (previousPosition != null) {
      final distance = _calculateDistance(
        previousPosition!.latitude,
        previousPosition!.longitude,
        currentPosition.latitude,
        currentPosition.longitude,
      );
      setState(() {
        totalDistance += distance;
      });
    }
    previousPosition = currentPosition;
  }

  // 거 계ㄴ 
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371; // 지구 반지름 (km)
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // 거리 반환 (km)
  }

  double _toRadians(double degree) => degree * pi / 180;
  // timer
  void _toggleTimer() {
    if (isRunning) {
      _timer?.cancel();
      setState(() {
        isRunning = false;
      });
    } else {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          elapsedSeconds++;
        });
      });
      setState(() {
        isRunning = true;
      });
    }
  }

  //정지 버튼 누릉시 리셋 데이타
  Future<void> _resetData() async {
    final appState = Provider.of<ApplicationState>(context, listen: false);
    await appState.saveExerciseData(
      totalDistance,
      elapsedSeconds,
    );

    _timer?.cancel();
    setState(() {
      isRunning = false;
      elapsedSeconds = 0;
      totalDistance = 0.0;
      previousPosition = null;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // 상단: 구글맵과 검색창
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _initialCameraPosition ??
                      CameraPosition(
                        target: LatLng(36.103839, 129.388732), // 기본값
                        zoom: 16.0,
                      ),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(color: theme.dividerColor , blurRadius: 10),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Hinted search text',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 하단: 거리 및 버튼
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 거리 정보
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        totalDistance.toStringAsFixed(1),
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '거리(km)',
                        style: TextStyle(fontSize: 14, color: theme.dividerColor),
                      ),
                    ],
                  ),
                  // 구분선
                  Container(
                    height: 40,
                    width: 1,
                    color: theme.dividerColor,
                  ),
                  // 버튼
                  Row(
                    children: [
                      IconButton(
                        onPressed: _toggleTimer,
                        icon: Icon(
                          isRunning ? Icons.pause : Icons.play_arrow,
                          size: 30,
                    
                        ),
                      ),
                      SizedBox(width: 10),
                      IconButton(
                        onPressed: _resetData,
                        icon: Icon(
                          Icons.stop,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  // 구분선
                  Container(
                    height: 40,
                    width: 1,
                    color: theme.dividerColor,
                  ),
                  // 시간 정보
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatTime(elapsedSeconds),
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '시간:분(h:m)',
                        style: TextStyle(fontSize: 14, color: theme.dividerColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

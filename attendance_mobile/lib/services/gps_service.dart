import 'dart:async';

import 'package:geolocator/geolocator.dart';
import '../core/utils/haversine.dart';
import '../core/utils/app_logger.dart';

class GpsService {
  // Xin quyền và lấy vị trí hiện tại
  Future<Position> getCurrentPosition() async {
    // Kiểm tra GPS có bật không
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('GPS chưa được bật. Vui lòng bật GPS và thử lại.');
    }

    // Kiểm tra quyền
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Quyền GPS bị từ chối.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Quyền GPS bị từ chối vĩnh viễn. Vui lòng vào Cài đặt để cấp quyền.');
    }

    // Lấy vị trí
    late final Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } on TimeoutException catch (e, st) {
      AppLogger.error('GpsService.getCurrentPosition', e, st);
      throw Exception(
        'Không lấy được vị trí GPS trong thời gian cho phép.\n'
        'Vui lòng ra khu vực thoáng, có tín hiệu GPS tốt hơn rồi thử lại.',
      );
    }

    // Kiểm tra Fake GPS
    if (position.isMocked) {
      throw Exception('Phát hiện vị trí giả. Không thể chấm công.');
    }

    return position;
  }

  // Tính khoảng cách tới công ty
  double calculateDistance({
    required double currentLat,
    required double currentLng,
    required double companyLat,
    required double companyLng,
  }) {
    return Haversine.calculateDistance(
      currentLat, currentLng,
      companyLat, companyLng,
    );
  }

  // Kiểm tra có trong bán kính không
  bool isWithinRadius({
    required double distance,
    required double radius,
  }) {
    return Haversine.isWithinRadius(distance, radius);
  }
}
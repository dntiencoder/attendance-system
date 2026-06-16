import 'dart:math';

class Haversine {
  static const double _earthRadius = 6371000; // mét

  // Tính khoảng cách giữa 2 tọa độ (mét)
  static double calculateDistance(
      double lat1, double lng1,
      double lat2, double lng2,
      ) {
    final dLat = _toRad(lat2 - lat1);
    final dLng = _toRad(lng2 - lng1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) *
            sin(dLng / 2) * sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return _earthRadius * c;
  }

  // Kiểm tra trong bán kính
  static bool isWithinRadius(double distance, double radius) {
    return distance <= radius;
  }

  static double _toRad(double deg) => deg * pi / 180;
}
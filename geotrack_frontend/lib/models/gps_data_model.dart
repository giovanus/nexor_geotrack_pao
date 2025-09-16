class GpsData {
  final String? id;
  final String deviceId;
  final double lat;
  final double lon;
  final DateTime timestamp;
  final bool? synced;
  final DateTime? createdAt;

  GpsData({
    this.id,
    required this.deviceId,
    required this.lat,
    required this.lon,
    required this.timestamp,
    this.synced,
    this.createdAt,
  });

  factory GpsData.fromJson(Map<String, dynamic> json) {
    return GpsData(
      id: json['id']?.toString(),
      deviceId: json['device_id'],
      lat: json['lat']?.toDouble() ?? 0.0,
      lon: json['lon']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(json['timestamp']),
      synced: json['synced'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'lat': lat,
      'lon': lon,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

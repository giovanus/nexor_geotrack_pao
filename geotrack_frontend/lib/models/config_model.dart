class Config {
  final int xParameter;
  final int yParameter;
  final String deviceId;

  Config({
    required this.xParameter,
    required this.yParameter,
    required this.deviceId,
  });

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      xParameter: json['x_parameter'],
      yParameter: json['y_parameter'],
      deviceId: json['device_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x_parameter': xParameter,
      'y_parameter': yParameter,
      'device_id': deviceId,
    };
  }
}

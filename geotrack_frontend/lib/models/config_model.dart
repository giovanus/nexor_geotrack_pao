class Config {
  final int xParameter;
  final int yParameter;

  Config({required this.xParameter, required this.yParameter});

  factory Config.fromJson(Map<String, dynamic> json) {
    return Config(
      xParameter: json['x_parameter'],
      yParameter: json['y_parameter'],
    );
  }
}

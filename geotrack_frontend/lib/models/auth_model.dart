// auth_model.dart
class LoginRequest {
  final String pin; // Changé de password à pin

  LoginRequest({required this.pin});

  Map<String, dynamic> toJson() {
    return {'pin': pin};
  }
}

class LoginResponse {
  final bool success;
  final String? token;
  final String? error;

  LoginResponse({required this.success, this.token, this.error});
}

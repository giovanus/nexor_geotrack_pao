import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geotrack_frontend/models/config_model.dart';
import 'package:geotrack_frontend/models/gps_data_model.dart';
import 'package:geotrack_frontend/utils/constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'storage_service.dart';

class ApiService {
  Future<String> _getApiUrl() async {
    return dotenv.get('API_BASE_URL', fallback: Constants.apiBaseUrl);
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService().getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Config> getConfig() async {
    try {
      final apiUrl = await _getApiUrl();
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$apiUrl/config/'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Config.fromJson(data);
      } else {
        throw Exception('Failed to load config: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load config: $e');
    }
  }

  Future<GpsData> sendGpsData(GpsData data) async {
    try {
      final apiUrl = await _getApiUrl();
      final headers = await _getHeaders();

      final body = {
        "device_id":
            data.deviceId, // Assure-toi que ce champ existe et est renseigné
        "lat": data.lat,
        "lon": data.lon,
        "timestamp": data.timestamp.toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('$apiUrl/data/'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return GpsData.fromJson(responseData);
      } else {
        throw Exception(
          'Failed to send GPS data: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Failed to send GPS data: $e');
    }
  }

  Future<List<GpsData>> getGpsData({String? deviceId}) async {
    try {
      final apiUrl = await _getApiUrl();
      final headers = await _getHeaders();

      final url =
          deviceId != null
              ? Uri.parse('$apiUrl/data/?device_id=$deviceId')
              : Uri.parse('$apiUrl/data/');

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => GpsData.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load GPS data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load GPS data: $e');
    }
  }
}

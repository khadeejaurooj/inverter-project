import 'package:dio/dio.dart';
import 'api_config.dart';
import '../../utils/shared_preferences_helper.dart';
import '../models/devices_list_model.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "${ApiConfig.baseUrl}/api/user",
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<List<DevicesListModel>> fetchDevices() async {
    String? token = await SharedPreferencesHelper.getToken();
    if (token == null) {
      throw Exception("Token not found!");
    }

    try {
      final response = await _dio.get(
        "/devices",
        options: Options(headers: {
          "Authorization": "Bearer $token",
        }),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => DevicesListModel.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load devices!");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}

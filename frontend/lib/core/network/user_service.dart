import 'package:dio/dio.dart';
import 'api_config.dart';
import '../../utils/shared_preferences_helper.dart';
import '../models/users_model.dart';

class UserService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "${ApiConfig.baseUrl}/api/auth",
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));

  Future<List<UsersModel>> fetchUsers() async {
    try {
      String? token = await SharedPreferencesHelper.getToken();
      if (token == null) throw Exception("Token not found");

      print("🔹 Token being sent: $token"); // Log token to debug

      final response = await _dio.get(
        "/getAllUser",
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );

      print("🔹 Response: ${response.data}"); // Log API response

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => UsersModel.fromJson(json)).toList();
      } else {
        throw Exception("Failed to fetch users");
      }
    } on DioException catch (e) {
      print("❌ API Error: ${e.response?.statusMessage ?? e.message}");
      throw Exception("API Error: ${e.response?.statusMessage ?? e.message}");
    }
  }
}

import 'package:dio/dio.dart';
import 'api_config.dart';
import '../models/signup_model.dart';

class SignupService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "${ApiConfig.baseUrl}/api/auth",
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
    headers: {
      "Content-Type": "application/json",
    },
  ));

  Future<String> signup(SignupModel user, String? token) async {
    try {
      Response response = await _dio.post(
        "/signup",
        data: user.toJson(),
        options: Options(headers: {
          if (token != null && token.isNotEmpty)
            "Authorization": "Bearer $token",
        }),
      );

      if (response.statusCode == 200) {
        return "Signup Successful";
      } else {
        return response.data["message"] ?? "Signup Failed";
      }
    } on DioException catch (e) {
      return e.response?.data["message"] ?? "N etwork Error: ${e.message}";
    }
  }
}

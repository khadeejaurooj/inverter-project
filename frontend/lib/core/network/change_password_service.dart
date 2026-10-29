import 'package:dio/dio.dart';
import 'api_config.dart';
import 'package:flutterproject/core/models/change_password_request_model.dart';

class ChangePasswordService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "${ApiConfig.baseUrl}/api/auth/",
    ),
  );

  Future<String> changePassword(
      ChangePasswordRequestModel request, String token) async {
    try {
      final response = await _dio.put(
        "changepassword",
        data: request.toJson(),
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      return response.data["message"];
    } catch (e) {
      throw Exception("Failed to change password");
    }
  }
}

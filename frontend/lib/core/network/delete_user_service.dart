import 'package:dio/dio.dart';
import 'api_config.dart';
import '../../utils/shared_preferences_helper.dart';
import '../models/delete_user_response_model.dart';

class DeleteUserService {
  final Dio _dio = Dio();
  final String baseUrl = "${ApiConfig.baseUrl}/api/auth";

  Future<DeleteUserResponseModel> deleteUser(int userId) async {
    try {
      String? token = await SharedPreferencesHelper.getToken();
      print("Token Retrieved: $token");

      Response response = await _dio.put(
        "$baseUrl/deleteUser",
        queryParameters: {"userId": userId, "activeUser": false},
        options: Options(
          headers: {"Authorization": "Bearer $token"},
          responseType: ResponseType.plain, // ✅ Forces Dio to accept plain text
        ),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Data: ${response.data}");

      // ✅ Handle plain text responses explicitly
      if (response.data is String) {
        return DeleteUserResponseModel(message: response.data.toString());
      } else if (response.data is Map<String, dynamic>) {
        return DeleteUserResponseModel.fromJson(response.data);
      } else {
        throw Exception("Unexpected response format: ${response.data}");
      }
    } catch (e) {
      if (e is DioException) {
        print("Dio Error: ${e.response?.statusCode}");
        print("Dio Error Data: ${e.response?.data}");
      }
      print("Exception: $e");
      throw Exception("Failed to delete user: $e");
    }
  }
}

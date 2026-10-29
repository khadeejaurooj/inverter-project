import 'package:dio/dio.dart';
import 'api_config.dart';
import '../models/login_model.dart';
import '../models/login_response_model.dart';

class SigninService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "${ApiConfig.baseUrl}/api/auth",
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
    headers: {
      "Content-Type": "application/json",
    },
  ));

  Future<LoginResponseModel?> login(LoginModel user) async {
    try {
      Response response = await _dio.post("/signin", data: user.toJson());

      if (response.statusCode == 200) {
        return LoginResponseModel.fromJson(response.data);
      } else {
        return null;
      }
    } on DioException catch (e) {
      return null;
    }
  }
}

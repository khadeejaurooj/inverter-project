import 'package:dio/dio.dart';
import 'api_config.dart';
import '../models/main_model.dart';

class MainServices {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: "${ApiConfig.baseUrl}/api/inverter",
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));

  Future<List<MainModel>?> getInverterData(String token) async {
    try {
      Response response = await _dio.get(
        "/getAllInverterData",
        queryParameters: {"macAddress": ApiConfig.defaultInverterMac},
        options: Options(headers: {
          "Authorization": "Bearer $token",
        }),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((json) => MainModel.fromJson(json)).toList();
      } else {
        return null;
      }
    } on DioException catch (e) {
      print("Error fetching inverter data: ${e.message}");
      return null;
    }
  }
}

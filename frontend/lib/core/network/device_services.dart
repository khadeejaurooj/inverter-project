import 'package:dio/dio.dart';
import 'api_config.dart';
import '../../utils/shared_preferences_helper.dart';

class DeviceServices {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10), // Timeout handling
    receiveTimeout: const Duration(seconds: 10),
  ));

  DeviceServices() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print("🌍 Sending Request: ${options.method} ${options.uri}");
        print("🔑 Headers: ${options.headers}");
        handler.next(options);
      },
      onResponse: (response, handler) {
        print("✅ Response Received: ${response.statusCode}");
        print("📩 Data: ${response.data}");
        handler.next(response);
      },
      onError: (DioException e, handler) {
        print("❌ Dio Error: ${e.type}");
        print("❌ Error Message: ${e.message}");
        print("❌ Response Status: ${e.response?.statusCode}");
        print("❌ Response Data: ${e.response?.data}");
        handler.next(e);
      },
    ));
  }

  Future<String> addDevice(String macAddress, String inverterName) async {
    String? token = await SharedPreferencesHelper.getToken();
    print("🔍 Token Retrieved: $token");

    if (token == null) return "Authorization token not found!";

    try {
      final url =
          "${ApiConfig.baseUrl}/api/auth/macaddress?macAddress=$macAddress&inverter_name=$inverterName";

      print("📤 Sending Request to API: $url");

      final response = await _dio.put(
        url,
        options: Options(headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        }),
      );

      print("✅ Response Status Code: ${response.statusCode}");
      print("✅ Response Data: ${response.data}");

      return response.data["message"] ?? "Device added successfully!";
    } on DioException catch (e) {
      print("❌ Dio Exception Type: ${e.type}");
      print("❌ Error Message: ${e.message}");
      print("❌ Response Status Code: ${e.response?.statusCode}");
      print("❌ Response Data: ${e.response?.data}");
      return e.response?.data["message"] ?? "Mac is not Unique";
    }
  }
}

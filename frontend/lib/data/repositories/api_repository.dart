import '../../core/network/api_service.dart';
import '../../core/models/devices_list_model.dart';

class ApiRepository {
  final ApiService _apiService;

  ApiRepository(this._apiService);

  Future<List<DevicesListModel>> getDevices() async {
    return await _apiService.fetchDevices();
  }
}

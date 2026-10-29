import '../repositories/api_repository.dart';
import '../../core/models/devices_list_model.dart';

class FetchDevicesUseCase {
  final ApiRepository _repository;

  FetchDevicesUseCase(this._repository);

  Future<List<DevicesListModel>> call() async {
    return await _repository.getDevices();
  }
}

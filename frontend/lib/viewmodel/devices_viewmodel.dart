import 'package:flutter/foundation.dart';
import '../core/models/devices_list_model.dart';
import '../data/usecases/fetch_devices_usecase.dart';

class DevicesViewModel extends ChangeNotifier {
  final FetchDevicesUseCase _fetchDevicesUseCase;

  List<DevicesListModel> _devices = [];
  bool _isLoading = false;
  String _errorMessage = '';

  DevicesViewModel(this._fetchDevicesUseCase);

  List<DevicesListModel> get devices => _devices;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchDevices() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _devices = await _fetchDevicesUseCase();
    } catch (e) {
      _errorMessage = "Failed to load devices: ${e.toString()}";
    }

    _isLoading = false;
    notifyListeners();
  }
}

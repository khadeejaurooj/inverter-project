import 'package:flutter/foundation.dart';
import '../data/usecases/add_device_usecase.dart';

class AddDeviceViewModel extends ChangeNotifier {
  final AddDeviceUseCase _addDeviceUseCase;

  AddDeviceViewModel(this._addDeviceUseCase);

  bool isLoading = false;
  String? message;

  void clearMessage() {
    message = null;
    notifyListeners();
  }

  Future<bool> addDevice(String macAddress, String inverterName) async {
    isLoading = true;
    message = null;
    notifyListeners();

    message = await _addDeviceUseCase(macAddress, inverterName);

    isLoading = false;
    notifyListeners();

    return message == "Device added successfully!";
  }
}

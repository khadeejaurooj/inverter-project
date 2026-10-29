import '../repositories/device_repository.dart';

class AddDeviceUseCase {
  final DeviceRepository _repository;

  AddDeviceUseCase(this._repository);

  Future<String> call(String macAddress, String inverterName) async {
    if (macAddress.isEmpty || inverterName.isEmpty) {
      return "Please enter all details!";
    }

    bool success = await _repository.addDevice(macAddress, inverterName);
    return success ? "Device added successfully!" : "Failed to add device!";
  }
}

import '../../core/network/device_services.dart';

class DeviceRepository {
  final DeviceServices _deviceServices;

  DeviceRepository(this._deviceServices);

  Future<bool> addDevice(String macAddress, String inverterName) async {
    String responseMessage =
        await _deviceServices.addDevice(macAddress, inverterName);
    return responseMessage == "Mac Added!"; // ✅ Fix: Match API Response
  }
}

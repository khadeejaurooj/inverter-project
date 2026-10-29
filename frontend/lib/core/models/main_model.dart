class MainModel {
  final int id;
  final double energyConsumed;
  final double genPower;
  final double pvVoltage;
  final double outputVoltage;
  final double outputCurrent;
  final String macAddress;
  final int error;
  final String deviceName;
  final String version;
  final String createdAt;

  MainModel({
    required this.id,
    required this.energyConsumed,
    required this.genPower,
    required this.pvVoltage,
    required this.outputVoltage,
    required this.outputCurrent,
    required this.macAddress,
    required this.error,
    required this.deviceName,
    required this.version,
    required this.createdAt,
  });

  factory MainModel.fromJson(Map<String, dynamic> json) {
    return MainModel(
      id: json["id"],
      energyConsumed: json["energy_consumed"].toDouble(),
      genPower: json["gen_power"].toDouble(),
      pvVoltage: json["pv_voltage"].toDouble(),
      outputVoltage: json["output_voltage"].toDouble(),
      outputCurrent: json["output_current"].toDouble(),
      macAddress: json["mac_address"],
      error: json["error"],
      deviceName: json["device_name"],
      version: json["version"],
      createdAt: json["createdAt"],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutterproject/views/add_device_screen.dart';
import 'package:provider/provider.dart';
import '../ui/app_bottom_nav.dart';
import '../ui/app_theme.dart';
import '../ui/form_widgets.dart';
import '../ui/widgets.dart';
import '../viewmodel/devices_viewmodel.dart';
import '../core/models/devices_list_model.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  _DeviceListScreenState createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DevicesViewModel>(context, listen: false).fetchDevices();
    });
  }

  void _showAddDevicesScreen() async {
    bool? deviceAdded = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddDeviceScreen()),
    );

    if (deviceAdded == true) {
      Provider.of<DevicesViewModel>(context, listen: false)
          .fetchDevices(); // Refresh devices list
    }
  }

  Future<void> _refresh() =>
      Provider.of<DevicesViewModel>(context, listen: false).fetchDevices();

  @override
  Widget build(BuildContext context) {
    final deviceViewModel = Provider.of<DevicesViewModel>(context);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("Inverter Devices")),
        bottomNavigationBar: const AppBottomNav(current: AppTab.devices),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddDevicesScreen,
          icon: const Icon(Icons.add_rounded),
          label: const Text("Add device",
              style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        body: _buildBody(deviceViewModel),
      ),
    );
  }

  Widget _buildBody(DevicesViewModel vm) {
    if (vm.isLoading && vm.devices.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.errorMessage.isNotEmpty) {
      return StateMessage(
        icon: Icons.cloud_off_rounded,
        color: AppColors.danger,
        title: "Couldn't load devices",
        message: vm.errorMessage,
        actionLabel: "Retry",
        onAction: _refresh,
      );
    }
    if (vm.devices.isEmpty) {
      return StateMessage(
        icon: Icons.memory_rounded,
        title: "No devices found",
        message: "Add your first inverter using its MAC address.",
        actionLabel: "Add device",
        onAction: _showAddDevicesScreen,
      );
    }

    // Latest device first.
    final devices = vm.devices.reversed.toList();
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surfaceHigh,
      onRefresh: _refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
        itemCount: devices.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 2),
              child: Text(
                "${devices.length} ${devices.length == 1 ? 'device' : 'devices'} connected",
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            );
          }
          return _DeviceCard(device: devices[index - 1]);
        },
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final DevicesListModel device;
  const _DeviceCard({required this.device});

  @override
  Widget build(BuildContext context) {
    final user = device.user;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBadge(
                  icon: Icons.memory_rounded,
                  color: AppColors.primary,
                  size: 46),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.inverterName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      device.macAddress,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Avatar(name: user.username, color: AppColors.voltage, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.username,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15)),
                          Text("User ID ${user.id}",
                              style: const TextStyle(
                                  color: AppColors.textMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                InfoRow(
                    icon: Icons.mail_outline_rounded,
                    label: "Email",
                    value: user.email),
                InfoRow(
                    icon: Icons.phone_outlined,
                    label: "Phone",
                    value: user.phone),
                InfoRow(
                    icon: Icons.location_on_outlined,
                    label: "Address",
                    value: user.address),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

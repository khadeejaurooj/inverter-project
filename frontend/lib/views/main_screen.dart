import 'package:flutter/material.dart';
import 'package:flutterproject/views/device_list_screen.dart';
import 'package:flutterproject/views/get_all_users_screen.dart';
import 'package:flutterproject/views/login_screen.dart';
import 'package:provider/provider.dart';
import '../core/models/main_model.dart';
import '../ui/app_bottom_nav.dart';
import '../ui/app_theme.dart';
import '../ui/widgets.dart';
import '../viewmodel/main_viewmodel.dart';
import '../views/delete_user_dialog.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<MainViewModel>(context, listen: false)
        .fetchInverterData(context));
  }

  Future<void> _refresh() =>
      Provider.of<MainViewModel>(context, listen: false)
          .fetchInverterData(context);

  @override
  Widget build(BuildContext context) {
    final mainViewModel = Provider.of<MainViewModel>(context);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              Image.asset("assets/splashicon.png", height: 30),
              const SizedBox(width: 10),
              const Text("Dashboard"),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'getAllUsers') {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GetAllUsersScreen()));
                } else if (value == 'deleteUser') {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DeleteUserDialog()));
                } else if (value == 'inverterDevices') {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DeviceListScreen()));
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'getAllUsers',
                  child: _MenuRow(Icons.people_alt_outlined, "Get All Users"),
                ),
                PopupMenuItem(
                  value: 'deleteUser',
                  child: _MenuRow(Icons.person_remove_outlined, "Delete User"),
                ),
                PopupMenuItem(
                  value: 'inverterDevices',
                  child: _MenuRow(Icons.memory_rounded, "Inverter Devices"),
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: const AppBottomNav(current: AppTab.dashboard),
        body: _buildBody(mainViewModel),
      ),
    );
  }

  Widget _buildBody(MainViewModel vm) {
    if (vm.isLoading && vm.latestInverter == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final latest = vm.latestInverter;
    if (latest == null) {
      return StateMessage(
        icon: Icons.cloud_off_rounded,
        title: "No data available",
        message: "We couldn't load the inverter readings. Check your "
            "connection and try again.",
        actionLabel: "Retry",
        onAction: _refresh,
      );
    }
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surfaceHigh,
      onRefresh: _refresh,
      child: _buildInverterDashboard(latest, vm.history),
    );
  }

  Widget _buildInverterDashboard(MainModel inverter, List<MainModel> history) {
    final prev = history.length >= 2 ? history[history.length - 2] : null;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        _HeroCard(inverter: inverter, history: history, previous: prev),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: StatTile(
                icon: Icons.solar_power_rounded,
                color: AppColors.voltage,
                label: "PV Voltage",
                value: fmt(inverter.pvVoltage),
                unit: Units.voltage,
                changePercent: percentChange(inverter.pvVoltage, prev?.pvVoltage),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatTile(
                icon: Icons.electric_bolt_rounded,
                color: AppColors.voltage,
                label: "Output Voltage",
                value: fmt(inverter.outputVoltage),
                unit: Units.voltage,
                changePercent:
                    percentChange(inverter.outputVoltage, prev?.outputVoltage),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatTile(
                icon: Icons.waves_rounded,
                color: AppColors.current,
                label: "Output Current",
                value: fmt(inverter.outputCurrent),
                unit: Units.current,
                changePercent:
                    percentChange(inverter.outputCurrent, prev?.outputCurrent),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatTile(
                icon: Icons.battery_charging_full_rounded,
                color: AppColors.power,
                label: "Energy Consumed",
                value: fmt(inverter.energyConsumed),
                unit: Units.energy,
                changePercent:
                    percentChange(inverter.energyConsumed, prev?.energyConsumed),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Device details",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              InfoRow(
                  icon: Icons.memory_rounded,
                  label: "Device",
                  value: inverter.deviceName),
              const Divider(),
              InfoRow(
                  icon: Icons.lan_outlined,
                  label: "MAC address",
                  value: inverter.macAddress,
                  mono: true),
              const Divider(),
              InfoRow(
                  icon: Icons.system_update_alt_rounded,
                  label: "Version",
                  value: inverter.version),
              const Divider(),
              InfoRow(
                  icon: Icons.tag_rounded,
                  label: "Reading ID",
                  value: "${inverter.id}"),
              const Divider(),
              InfoRow(
                  icon: Icons.schedule_rounded,
                  label: "Last updated",
                  value: formatTimestamp(inverter.createdAt)),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MenuRow(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Text(label),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final MainModel inverter;
  final List<MainModel> history;
  final MainModel? previous;

  const _HeroCard({
    required this.inverter,
    required this.history,
    required this.previous,
  });

  @override
  Widget build(BuildContext context) {
    final healthy = inverter.error == 0;
    final change = percentChange(inverter.genPower, previous?.genPower);

    return AppCard(
      padding: const EdgeInsets.all(20),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF17423A), AppColors.surface],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBadge(
                  icon: Icons.bolt_rounded, color: AppColors.primary, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inverter.deviceName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Version ${inverter.version}",
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              StatusChip(
                label: healthy ? "Healthy" : "Fault ${inverter.error}",
                color: healthy ? AppColors.primary : AppColors.danger,
                icon: healthy
                    ? Icons.check_circle_rounded
                    : Icons.warning_amber_rounded,
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            "Generated power",
            style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                fmt(inverter.genPower),
                style: const TextStyle(
                  fontSize: 46,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                  height: 1.05,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                Units.power,
                style: TextStyle(
                    color: AppColors.power,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (change != null)
                StatusChip(
                  label: "${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%",
                  color: change >= 0 ? AppColors.primary : AppColors.danger,
                  icon: change >= 0
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                ),
            ],
          ),
          if (history.length >= 2) ...[
            const SizedBox(height: 14),
            Sparkline(
              values: [for (final r in history) r.genPower],
              color: AppColors.power,
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Last ${history.length} readings",
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12),
                ),
                Text(
                  "Updated ${formatTimestamp(inverter.createdAt).split(', ').last}",
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

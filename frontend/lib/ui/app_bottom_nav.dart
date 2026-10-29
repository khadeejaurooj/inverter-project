import 'package:flutter/material.dart';
import '../views/device_list_screen.dart';
import '../views/get_all_users_screen.dart';
import '../views/main_screen.dart';
import 'app_theme.dart';

enum AppTab { dashboard, devices, users }

/// Bottom navigation shared by the three main screens. It uses the same
/// pushReplacement navigation the app already used.
class AppBottomNav extends StatelessWidget {
  final AppTab current;
  const AppBottomNav({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: NavigationBar(
        selectedIndex: current.index,
        onDestinationSelected: (i) {
          if (i == current.index) return;
          final Widget page = [
            const MainScreen(),
            const DeviceListScreen(),
            GetAllUsersScreen(),
          ][i];
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.memory_outlined),
            selectedIcon: Icon(Icons.memory_rounded),
            label: 'Devices',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_alt_rounded),
            label: 'Users',
          ),
        ],
      ),
    );
  }
}

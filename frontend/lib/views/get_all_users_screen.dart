import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/models/users_model.dart';
import '../ui/app_bottom_nav.dart';
import '../ui/app_theme.dart';
import '../ui/form_widgets.dart';
import '../ui/widgets.dart';
import '../viewmodel/user_viewmodel.dart';
import '../viewmodel/delete_user_viewmodel.dart';
import 'delete_user_dialog.dart';

class GetAllUsersScreen extends StatefulWidget {
  @override
  _GetAllUsersScreenState createState() => _GetAllUsersScreenState();
}

class _GetAllUsersScreenState extends State<GetAllUsersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => Provider.of<UserViewModel>(context, listen: false).fetchUsers());
  }

  Future<void> _refresh() =>
      Provider.of<UserViewModel>(context, listen: false).fetchUsers();

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);
    final deleteUserViewModel = Provider.of<DeleteUserViewModel>(context);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("All Users"),
          bottom: deleteUserViewModel.isLoading
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(3),
                  child: LinearProgressIndicator(minHeight: 3),
                )
              : null,
        ),
        bottomNavigationBar: const AppBottomNav(current: AppTab.users),
        body: _buildBody(userViewModel),
      ),
    );
  }

  Widget _buildBody(UserViewModel vm) {
    if (vm.isLoading && vm.users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.errorMessage != null) {
      return StateMessage(
        icon: Icons.cloud_off_rounded,
        color: AppColors.danger,
        title: "Couldn't load users",
        message: vm.errorMessage,
        actionLabel: "Retry",
        onAction: _refresh,
      );
    }
    if (vm.users.isEmpty) {
      return const StateMessage(
        icon: Icons.people_outline_rounded,
        title: "No users yet",
        message: "Registered users will show up here.",
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surfaceHigh,
      onRefresh: _refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        itemCount: vm.users.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 2),
              child: Text(
                "${vm.users.length} registered ${vm.users.length == 1 ? 'user' : 'users'}",
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            );
          }
          final user = vm.users[index - 1];
          return _UserCard(
            user: user,
            onDelete: () {
              showDialog(
                context: context,
                builder: (context) => DeleteUserDialog(userId: user.id),
              );
            },
          );
        },
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UsersModel user;
  final VoidCallback onDelete;
  const _UserCard({required this.user, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.role.toUpperCase().contains('ADMIN');
    final roleColor = isAdmin ? AppColors.power : AppColors.voltage;
    final roleLabel = isAdmin ? 'Admin' : 'User';
    final place =
        [user.city, user.country].where((s) => s.isNotEmpty).join(', ');

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
      child: Row(
        children: [
          Avatar(name: user.username, color: roleColor, size: 48),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.username,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusChip(label: roleLabel, color: roleColor),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
                if (place.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    place,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: "Delete user",
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.danger),
          ),
        ],
      ),
    );
  }
}

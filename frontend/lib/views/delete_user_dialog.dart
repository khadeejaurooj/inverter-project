import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ui/app_theme.dart';
import '../ui/widgets.dart';
import '../viewmodel/delete_user_viewmodel.dart';
import '../viewmodel/user_viewmodel.dart';
import 'get_all_users_screen.dart'; // Import your GetAllUsersScreen

class DeleteUserDialog extends StatelessWidget {
  /// Optional: pre-fills the ID (used by the delete button on each user row).
  final int? userId;

  DeleteUserDialog({this.userId});

  @override
  Widget build(BuildContext context) {
    TextEditingController idController =
        TextEditingController(text: userId?.toString() ?? '');

    return AlertDialog(
      backgroundColor: AppColors.surfaceHigh,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
        side: const BorderSide(color: AppColors.border),
      ),
      icon: const Center(
        child: IconBadge(
            icon: Icons.person_remove_rounded,
            color: AppColors.danger,
            size: 56),
      ),
      title: const Text("Delete User",
          style: TextStyle(fontWeight: FontWeight.w800)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Enter the ID of the user to delete:",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: idController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: "Enter User ID",
              prefixIcon: Icon(Icons.tag_rounded),
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel",
              style: TextStyle(color: AppColors.textSecondary)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () async {
            String userIdText = idController.text.trim();
            int? userId = int.tryParse(userIdText);

            if (userId != null) {
              await Provider.of<DeleteUserViewModel>(context, listen: false)
                  .deleteUser(userId);

              print("Delete request sent!");

              // Refresh the user list after deletion
              Provider.of<UserViewModel>(context, listen: false).fetchUsers();

              // Navigate back to the GetAllUsersScreen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GetAllUsersScreen()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Invalid ID! Enter a valid number.")),
              );
            }
          },
          child: const Text("Delete"),
        ),
      ],
    );
  }
}

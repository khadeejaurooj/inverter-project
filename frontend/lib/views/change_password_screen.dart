import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ui/app_theme.dart';
import '../ui/form_widgets.dart';
import '../ui/widgets.dart';
import '../utils/shared_preferences_helper.dart';
import '../viewmodel/change_password_viewmodel.dart';

class ChangePasswordScreen extends StatelessWidget {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("Change Password")),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  IconBadge(
                      icon: Icons.lock_reset_rounded,
                      color: AppColors.primary,
                      size: 48),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      "Choose a new password for your account. You'll use it the next time you sign in.",
                      style: TextStyle(
                          color: AppColors.textSecondary, height: 1.4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PasswordField(
                      controller: oldPasswordController,
                      hint: "Old Password",
                    ),
                    const SizedBox(height: 14),
                    PasswordField(
                      controller: newPasswordController,
                      hint: "New Password",
                    ),
                    const SizedBox(height: 14),
                    PasswordField(
                      controller: confirmPasswordController,
                      hint: "Confirm Password",
                    ),
                    const SizedBox(height: 18),
                    Consumer<ChangePasswordViewModel>(
                      builder: (context, viewModel, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (viewModel.errorMessage != null) ...[
                              MessageBanner(
                                  text: viewModel.errorMessage!, isError: true),
                              const SizedBox(height: 14),
                            ],
                            if (viewModel.successMessage != null) ...[
                              MessageBanner(text: viewModel.successMessage!),
                              const SizedBox(height: 14),
                            ],
                            ElevatedButton(
                              onPressed: viewModel.isLoading
                                  ? null
                                  : () async {
                                      final token = await SharedPreferencesHelper
                                              .getToken() ??
                                          "";
                                      viewModel.changePassword(
                                        oldPasswordController.text,
                                        newPasswordController.text,
                                        confirmPasswordController.text,
                                        token,
                                      );
                                    },
                              child: viewModel.isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.6,
                                          color: AppColors.onPrimary),
                                    )
                                  : const Text("Change Password"),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

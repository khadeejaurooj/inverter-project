import 'package:flutter/material.dart';
import 'package:flutterproject/views/change_password_screen.dart';
import 'package:flutterproject/views/signup_screen.dart';
import 'package:provider/provider.dart';
import '../ui/app_theme.dart';
import '../ui/form_widgets.dart';
import '../viewmodel/signin_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signinViewModel = Provider.of<SigninViewModel>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SignupScreen()),
            );
          },
        ),
      ),
      body: AuthBackground(
        child: CenteredScroll(
          children: [
            const AuthHeading(
              title: "Welcome back",
              subtitle: "Sign in to monitor your solar inverters",
            ),
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: usernameController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: "Enter username or email",
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  PasswordField(
                    controller: passwordController,
                    hint: "Enter password",
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChangePasswordScreen()),
                        );
                      },
                      child: const Text("Forgot password?"),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: signinViewModel.isLoading
                        ? null
                        : () {
                            signinViewModel.login(
                              username: usernameController.text,
                              password: passwordController.text,
                              context: context,
                            );
                          },
                    child: signinViewModel.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.6, color: AppColors.onPrimary),
                          )
                        : const Text("Log in"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Text("or continue with",
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 13)),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RoundIconButton(
                  child: Image.asset("assets/apple_logo.png",
                      height: 26, fit: BoxFit.contain),
                ),
                const SizedBox(width: 16),
                RoundIconButton(
                  child: Image.asset("assets/google_logo.png",
                      height: 26, fit: BoxFit.contain),
                ),
                const SizedBox(width: 16),
                const RoundIconButton(
                  child: Icon(Icons.fingerprint_rounded,
                      color: AppColors.textSecondary, size: 28),
                ),
              ],
            ),
            const SizedBox(height: 26),
            OutlinedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen()),
                );
              },
              child: const Text("Create new account"),
            ),
          ],
        ),
      ),
    );
  }
}

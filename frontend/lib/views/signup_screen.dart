import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ui/app_theme.dart';
import '../ui/form_widgets.dart';
import '../viewmodel/signup_viewmodel.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isChecked = false; // Checkbox state

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signupViewModel = Provider.of<SignupViewModel>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
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
      ),
      body: AuthBackground(
        child: CenteredScroll(
          children: [
            const AuthHeading(
              title: "Create your account",
              subtitle: "Track your solar generation in one place",
            ),
            GlassPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: firstNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            hintText: "First name",
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: lastNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            hintText: "Last name",
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: "Enter email address",
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  PasswordField(
                    controller: passwordController,
                    hint: "Enter password here",
                  ),
                  const SizedBox(height: 14),
                  PasswordField(
                    controller: confirmPasswordController,
                    hint: "Enter confirm password here",
                  ),
                  const SizedBox(height: 10),

                  // Terms and Conditions Checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _isChecked,
                        onChanged: (value) {
                          setState(() {
                            _isChecked = value!;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          "By signing up, you agree to our Terms, Privacy Policy, and Cookie Use.",
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12.5,
                              height: 1.35),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Signup Button (Disabled until checkbox is checked)
                  ElevatedButton(
                    onPressed: (_isChecked && !signupViewModel.isLoading)
                        ? () {
                            signupViewModel.signup(
                              username: firstNameController.text,
                              lastname: lastNameController.text,
                              email: emailController.text,
                              password: passwordController.text,
                              confirmPassword: confirmPasswordController.text,
                              context: context,
                            );
                          }
                        : null, // Disable button if unchecked
                    child: signupViewModel.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.6, color: AppColors.onPrimary),
                          )
                        : const Text("Sign Up"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: const Text(
                "Already have an account? Login",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 10),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

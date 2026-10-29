import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'widgets.dart';

/// Photo background with a navy wash, shared by the sign-in style screens.
class AuthBackground extends StatelessWidget {
  final Widget child;
  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset("assets/splashbg.png", fit: BoxFit.cover),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.bgTop.withValues(alpha: 0.80),
                AppColors.bgBottom.withValues(alpha: 0.96),
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Scrollable column that stays vertically centred when there is room.
class CenteredScroll extends StatelessWidget {
  final List<Widget> children;
  const CenteredScroll({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, box) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: box.maxHeight - 84),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Frosted panel that holds a form on top of the photo background.
class GlassPanel extends StatelessWidget {
  final Widget child;
  const GlassPanel({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

/// Password input with a working show / hide toggle.
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  const PasswordField(
      {super.key, required this.controller, required this.hint});

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _hidden,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          icon: Icon(_hidden
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined),
          onPressed: () => setState(() => _hidden = !_hidden),
        ),
      ),
    );
  }
}

/// Inline success / error message.
class MessageBanner extends StatelessWidget {
  final String text;
  final bool isError;
  const MessageBanner({super.key, required this.text, this.isError = false});

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.danger : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              size: 20,
              color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: color, fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

/// Circle with initials.
class Avatar extends StatelessWidget {
  final String name;
  final Color color;
  final double size;
  const Avatar(
      {super.key, required this.name, required this.color, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        initialsOf(name),
        style: TextStyle(
            color: color, fontWeight: FontWeight.w800, fontSize: size * 0.36),
      ),
    );
  }
}

/// Round outlined button used for the decorative social / biometric options.
class RoundIconButton extends StatelessWidget {
  final Widget child;
  const RoundIconButton({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

/// Page heading used on the sign-in style screens.
class AuthHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  const AuthHeading({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset("assets/splashicon.png", height: 84),
        const SizedBox(height: 22),
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.6)),
        const SizedBox(height: 6),
        Text(subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 15)),
        const SizedBox(height: 26),
      ],
    );
  }
}

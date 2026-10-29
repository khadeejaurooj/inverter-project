import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Deep navy gradient used behind every screen.
class AppBackground extends StatelessWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.bgTop, AppColors.bgBottom],
        ),
      ),
      child: child,
    );
  }
}

/// Rounded surface card with a hairline border.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(22);
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: gradient == null ? AppColors.surface : null,
          gradient: gradient,
          borderRadius: radius,
          border: Border.all(color: AppColors.border),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Small coloured status pill, e.g. "Healthy".
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusChip({super.key, required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
          ] else ...[
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Round icon badge with a tinted background.
class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const IconBadge({super.key, required this.icon, required this.color, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(size * 0.34),
      ),
      child: Icon(icon, color: color, size: size * 0.52),
    );
  }
}

/// One metric: icon, label, big value + unit and an optional trend.
class StatTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String unit;
  final double? changePercent;

  const StatTile({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.unit,
    this.changePercent,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconBadge(icon: icon, color: color, size: 38),
              if (changePercent != null) _Trend(changePercent!),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                    color: color, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Trend extends StatelessWidget {
  final double percent;
  const _Trend(this.percent);

  @override
  Widget build(BuildContext context) {
    final flat = percent.abs() < 0.05;
    final up = percent > 0;
    final color = flat
        ? AppColors.textMuted
        : (up ? AppColors.primary : AppColors.danger);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          flat
              ? Icons.remove_rounded
              : (up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded),
          size: 14,
          color: color,
        ),
        Text(
          '${percent.abs().toStringAsFixed(1)}%',
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

/// Smooth area sparkline for a series of readings.
class Sparkline extends StatelessWidget {
  final List<double> values;
  final Color color;
  final double height;

  const Sparkline({
    super.key,
    required this.values,
    this.color = AppColors.power,
    this.height = 90,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _SparkPainter(values, color)),
    );
  }
}

class _SparkPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  _SparkPainter(this.values, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs() < 1e-9 ? 1.0 : (maxV - minV);
    const padTop = 10.0, padBottom = 6.0, padSide = 4.0;
    final h = size.height - padTop - padBottom;
    final w = size.width - padSide * 2;

    final pts = <Offset>[
      for (var i = 0; i < values.length; i++)
        Offset(
          padSide + w * i / (values.length - 1),
          padTop + h * (1 - (values[i] - minV) / range),
        ),
    ];

    final line = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = pts[i], p1 = pts[i + 1];
      final cx = (p0.dx + p1.dx) / 2;
      line.cubicTo(cx, p0.dy, cx, p1.dy, p1.dx, p1.dy);
    }

    final area = Path.from(line)
      ..lineTo(pts.last.dx, size.height)
      ..lineTo(pts.first.dx, size.height)
      ..close();

    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0.0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round,
    );

    final last = pts.last;
    canvas.drawCircle(last, 7, Paint()..color = color.withValues(alpha: 0.25));
    canvas.drawCircle(last, 4, Paint()..color = color);
    canvas.drawCircle(last, 1.8, Paint()..color = AppColors.bgBottom);
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) =>
      old.values != values || old.color != color;
}

/// Centered message used for empty / error states.
class StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color color;

  const StateMessage({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.color = AppColors.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconBadge(icon: icon, color: color, size: 64),
            const SizedBox(height: 18),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.textSecondary, height: 1.4)),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: 22),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Label / value row with a leading icon, used in info cards.
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool mono;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: mono ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "24 Oct 2026, 4:05 PM" from an ISO-8601 timestamp.
String formatTimestamp(String iso) {
  final d = DateTime.tryParse(iso)?.toLocal();
  if (d == null) return iso;
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final mm = d.minute.toString().padLeft(2, '0');
  final ampm = d.hour >= 12 ? 'PM' : 'AM';
  return '${d.day} ${months[d.month - 1]} ${d.year}, $h12:$mm $ampm';
}

/// Two-letter initials for avatars.
String initialsOf(String name) {
  final parts =
      name.trim().split(RegExp(r'[\s_.\-]+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts[0][0] + parts[1][0]).toUpperCase();
}

/// Formats a reading: up to 2 decimals, no trailing zeros.
String fmt(double v) {
  final s = v.toStringAsFixed(2);
  return s.replaceFirst(RegExp(r'\.?0+$'), '');
}

/// Percentage change of [now] against [before]; null when it cannot be computed.
double? percentChange(double now, double? before) {
  if (before == null || before.abs() < 1e-9) return null;
  return (now - before) / before.abs() * 100;
}

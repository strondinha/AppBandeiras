import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.color = AppColors.surface,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.line),
    ),
    child: child,
  );
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color = AppColors.lime});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: TextStyle(
      color: color,
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.7,
    ),
  );
}

class Tag extends StatelessWidget {
  const Tag({
    super.key,
    required this.text,
    this.icon,
    this.color = AppColors.lime,
  });
  final String text;
  final IconData? icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: color.withValues(alpha: 0.2)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class Brand extends StatelessWidget {
  const Brand({super.key, this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.lime,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.flag_rounded,
          color: AppColors.background,
          size: 24,
        ),
      ),
      const SizedBox(width: 10),
      const Flexible(
        child: Text(
          'Flag Game',
          maxLines: 2,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
          ),
        ),
      ),
      if (!compact) ...[
        const SizedBox(width: 10),
        const Eyebrow('Atlas', color: AppColors.muted),
      ],
    ],
  );
}

class FlagImage extends StatelessWidget {
  const FlagImage({
    super.key,
    required this.asset,
    this.height = 180,
    this.revealName,
  });
  final String asset;
  final double height;
  final String? revealName;
  @override
  Widget build(BuildContext context) => Image.asset(
    asset,
    height: height,
    fit: BoxFit.contain,
    filterQuality: FilterQuality.high,
    semanticLabel: revealName == null
        ? 'Bandeira do país a identificar'
        : 'Bandeira de $revealName',
    errorBuilder: (_, _, _) => SizedBox(
      height: height,
      child: const Center(child: Text('Não foi possível exibir a bandeira.')),
    ),
  );
}

String clockLabel(int seconds) =>
    '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

String percentLabel(double accuracy) =>
    '${accuracy.toStringAsFixed(accuracy == accuracy.roundToDouble() ? 0 : 1).replaceAll('.', ',')}%';

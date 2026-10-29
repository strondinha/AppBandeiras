import 'package:flutter/material.dart';

import '../models/game_config.dart';
import '../theme/app_theme.dart';
import 'common.dart';
import 'question_prompt.dart';

class ModePicker extends StatelessWidget {
  const ModePicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final GameMode selected;
  final ValueChanged<GameMode> onChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Eyebrow('01 / Escolha seu desafio', color: AppColors.gold),
      const SizedBox(height: 8),
      Text(
        'Três jeitos de explorar o mundo.',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 16),
      LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 760;
          final width = wide
              ? (constraints.maxWidth - 24) / 3
              : constraints.maxWidth;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final mode in GameMode.values)
                SizedBox(width: width, child: _card(context, mode, wide)),
            ],
          );
        },
      ),
    ],
  );

  Widget _card(BuildContext context, GameMode mode, bool wide) {
    final active = selected == mode;
    final (icon, color, tag) = switch (mode) {
      GameMode.identify => (
        Icons.flag_outlined,
        AppColors.lime,
        'BANDEIRA → PAÍS',
      ),
      GameMode.matchFlag => (
        Icons.grid_view_rounded,
        AppColors.blue,
        'PAÍS → BANDEIRA',
      ),
      GameMode.reveal => (
        Icons.auto_awesome_rounded,
        AppColors.gold,
        'REVELAÇÃO EM MOSAICO',
      ),
    };
    return Semantics(
      selected: active,
      button: true,
      child: Material(
        color: active ? color.withValues(alpha: 0.1) : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: active ? color : AppColors.line,
            width: active ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          key: Key('mode-${mode.name}'),
          onTap: () => onChanged(mode),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 24),
                    const SizedBox(width: 10),
                    Expanded(child: Eyebrow(tag, color: color)),
                    const SizedBox(width: 6),
                    Icon(
                      active
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: active ? color : AppColors.muted,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  mode.label,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  mode.description,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                if (wide) ...[
                  const SizedBox(height: 16),
                  ExcludeSemantics(
                    child: SizedBox(
                      height: 65,
                      child: mode == GameMode.reveal
                          ? _preview(mode)
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              child: _preview(mode),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _preview(GameMode mode) => switch (mode) {
    GameMode.identify => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/flags/br.png',
          width: 78,
          height: 50,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 18),
        const Icon(
          Icons.arrow_forward_rounded,
          color: AppColors.muted,
          size: 18,
        ),
        const SizedBox(width: 18),
        const Tag(text: 'Brasil?', color: AppColors.lime),
      ],
    ),
    GameMode.matchFlag => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'JAPÃO',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 12),
        const Icon(
          Icons.arrow_forward_rounded,
          color: AppColors.muted,
          size: 18,
        ),
        const SizedBox(width: 12),
        for (final code in ['jp', 'ca', 'fr'])
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: Image.asset(
              'assets/flags/$code.png',
              width: 30,
              height: 24,
              fit: BoxFit.contain,
            ),
          ),
      ],
    ),
    GameMode.reveal => const Center(
      child: SizedBox(
        width: 110,
        child: SecretFlag(
          asset: 'assets/flags/br.png',
          revealedTiles: 5,
          height: 65,
        ),
      ),
    ),
  };
}

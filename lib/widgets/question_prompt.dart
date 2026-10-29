import 'package:flutter/material.dart';

import '../game/quiz_engine.dart';
import '../models/game_config.dart';
import '../theme/app_theme.dart';
import 'common.dart';

class QuestionPrompt extends StatelessWidget {
  const QuestionPrompt({
    super.key,
    required this.question,
    required this.mode,
    required this.revealedTiles,
    required this.number,
  });

  final Question question;
  final GameMode mode;
  final int revealedTiles;
  final int number;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height < 720 ? 140.0 : 190.0;
    return SurfaceCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        children: [
          Eyebrow('Rodada $number', color: AppColors.muted),
          const SizedBox(height: 18),
          if (mode == GameMode.matchFlag) ...[
            const Icon(
              Icons.travel_explore_rounded,
              color: AppColors.blue,
              size: 38,
            ),
            const SizedBox(height: 14),
            const Eyebrow('Destino da rodada', color: AppColors.blue),
            const SizedBox(height: 10),
            Text(
              question.answer.name,
              key: const Key('target-country'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(color: AppColors.blue),
            ),
            const SizedBox(height: 16),
            const Text(
              'Qual é a bandeira deste país?',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 6),
            const Text(
              'Compare as quatro imagens abaixo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 12),
            ),
          ] else ...[
            if (mode == GameMode.reveal)
              SecretFlag(
                key: ValueKey(question.answer.code),
                asset: question.answer.flag,
                revealedTiles: revealedTiles,
                height: height,
              )
            else
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: SizedBox(
                  key: ValueKey(question.answer.code),
                  width: double.infinity,
                  child: FlagImage(asset: question.answer.flag, height: height),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              mode == GameMode.reveal
                  ? 'Já reconheceu o país?'
                  : 'Qual país tem esta bandeira?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontSize: 21),
            ),
            const SizedBox(height: 6),
            Text(
              mode == GameMode.reveal
                  ? 'O mosaico revela novas partes a cada 1,5 segundo.'
                  : 'Escolha uma das quatro alternativas',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.muted, fontSize: 12),
            ),
            if (mode == GameMode.reveal) ...[
              const SizedBox(height: 14),
              Semantics(
                label: '$revealedTiles de 12 partes reveladas',
                child: LinearProgressIndicator(
                  value: revealedTiles / 12,
                  color: AppColors.gold,
                  backgroundColor: AppColors.raised,
                  minHeight: 3,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// O mosaico cobre a imagem real, preservando suas proporções e cores.
/// A ordem espalha as primeiras pistas em áreas diferentes da bandeira.
class SecretFlag extends StatelessWidget {
  const SecretFlag({
    super.key,
    required this.asset,
    required this.revealedTiles,
    this.height = 190,
  });
  final String asset;
  final int revealedTiles;
  final double height;
  static const revealOrder = [5, 2, 8, 0, 11, 6, 3, 9, 1, 10, 4, 7];

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: height * 1.6),
      child: AspectRatio(
        aspectRatio: 1.6,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: AppColors.background),
              ExcludeSemantics(
                child: Image.asset(
                  asset,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
              ExcludeSemantics(
                child: LayoutBuilder(
                  builder: (context, box) => Stack(
                    children: [
                      for (var tile = 0; tile < 12; tile++)
                        Positioned(
                          left: (tile % 4) * box.maxWidth / 4,
                          top: (tile ~/ 4) * box.maxHeight / 3,
                          width: box.maxWidth / 4 + 0.5,
                          height: box.maxHeight / 3 + 0.5,
                          child: AnimatedOpacity(
                            key: Key('secret-tile-$tile'),
                            opacity:
                                revealOrder.take(revealedTiles).contains(tile)
                                ? 0
                                : 1,
                            duration: const Duration(milliseconds: 250),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: tile.isEven
                                    ? AppColors.raised
                                    : AppColors.surface,
                                border: Border.all(
                                  color: AppColors.line,
                                  width: 0.5,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.question_mark_rounded,
                                  color: AppColors.muted,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

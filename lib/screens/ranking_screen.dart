import 'package:flutter/material.dart';

import '../models/country.dart';
import '../models/game_config.dart';
import '../models/game_result.dart';
import '../services/local_storage.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({
    super.key,
    required this.storage,
    required this.initialConfig,
  });
  final LocalStorage storage;
  final GameConfig initialConfig;
  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  late GameConfig _filter;
  bool _clearing = false;
  @override
  void initState() {
    super.initState();
    _filter = widget.initialConfig;
  }

  Future<void> _clear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Limpar todos os recordes?'),
        content: const Text(
          'Os resultados de todos os modos serão apagados deste dispositivo. Seu nome e suas configurações serão mantidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Limpar ranking'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _clearing = true);
    try {
      await widget.storage.clearScores();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível limpar o ranking. Tente novamente.',
            ),
          ),
        );
      }
    }
    if (mounted) setState(() => _clearing = false);
  }

  @override
  Widget build(BuildContext context) {
    final scores = widget.storage.leaderboard(_filter);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ranking local',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Limpar todos os recordes',
            onPressed: widget.storage.savedGames == 0 || _clearing
                ? null
                : _clear,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow(
                  'Seu próximo destino: o topo',
                  color: AppColors.gold,
                ),
                const SizedBox(height: 12),
                Text(
                  'Pequenos recordes.\nGrandes descobertas.',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Compare resultados com o mesmo modo, tempo, dificuldade e continente. Os 10 melhores de cada seleção ficam aqui.',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 24),
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<GameMode>(
                        isExpanded: true,
                        initialValue: _filter.gameMode,
                        decoration: const InputDecoration(
                          labelText: 'Modo de jogo',
                        ),
                        items: GameMode.values
                            .map(
                              (m) => DropdownMenuItem(
                                value: m,
                                child: Text(
                                  m.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (mode) {
                          if (mode != null) {
                            setState(
                              () => _filter = _filter.copyWith(gameMode: mode),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _filter.continent?.id ?? 'world',
                        decoration: const InputDecoration(
                          labelText: 'Continente',
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: 'world',
                            child: Text('Mundo todo'),
                          ),
                          ...Continent.values.map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.label),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(
                              () => _filter = value == 'world'
                                  ? _filter.copyWith(world: true)
                                  : _filter.copyWith(
                                      continent: Continent.fromId(value),
                                    ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: GameConfig.durations
                            .map(
                              (seconds) => ChoiceChip(
                                label: Text(
                                  GameConfig(durationSeconds: seconds)
                                      .durationLabel,
                                ),
                                labelStyle: TextStyle(
                                  color: _filter.durationSeconds == seconds
                                      ? AppColors.background
                                      : AppColors.text,
                                  fontWeight: FontWeight.w700,
                                ),
                                selected: _filter.durationSeconds == seconds,
                                onSelected: (_) => setState(
                                  () => _filter = _filter.copyWith(
                                    durationSeconds: seconds,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: Difficulty.values
                            .map(
                              (d) => ChoiceChip(
                                label: Text(d.label),
                                labelStyle: TextStyle(
                                  color: _filter.difficulty == d
                                      ? AppColors.background
                                      : AppColors.text,
                                  fontWeight: FontWeight.w700,
                                ),
                                selected: _filter.difficulty == d,
                                onSelected: (_) => setState(
                                  () =>
                                      _filter = _filter.copyWith(difficulty: d),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (scores.isEmpty)
                  const SizedBox(
                    width: double.infinity,
                    child: SurfaceCard(
                      padding: EdgeInsets.all(30),
                      child: Column(
                        children: [
                          Icon(
                            Icons.emoji_events_outlined,
                            color: AppColors.gold,
                            size: 48,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'O primeiro lugar está esperando.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Complete uma partida com esta seleção para entrar no ranking.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  for (var i = 0; i < scores.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _scoreRow(scores[i], i),
                    ),
                ],
                const SizedBox(height: 16),
                const Text(
                  'Desempate: maior precisão e, depois, partida mais recente. Recordes são locais e não sincronizam entre aparelhos.',
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _scoreRow(GameResult score, int index) {
    final date = score.playedAt.toLocal();
    final stamp =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    return SurfaceCard(
      padding: const EdgeInsets.all(17),
      color: index == 0 ? const Color(0xFF2B3027) : AppColors.surface,
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              '${index + 1}'.padLeft(2, '0'),
              style: TextStyle(
                color: index == 0 ? AppColors.gold : AppColors.muted,
                fontWeight: FontWeight.w800,
                fontSize: 21,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  score.config.player,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$stamp · ${percentLabel(score.accuracy)} de acertos',
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Text(
                '${score.correct}',
                style: const TextStyle(
                  color: AppColors.lime,
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                ),
              ),
              Text(
                score.correct == 1 ? 'ponto' : 'pontos',
                style: const TextStyle(fontSize: 10, color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

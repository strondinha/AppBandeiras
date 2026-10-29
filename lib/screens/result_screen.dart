import 'package:flutter/material.dart';

import '../models/game_result.dart';
import '../services/country_repository.dart';
import '../services/local_storage.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'game_screen.dart';
import 'ranking_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.result,
    required this.countries,
    required this.storage,
  });
  final GameResult result;
  final CountryRepository countries;
  final LocalStorage storage;
  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late bool _newRecord;
  bool _saving = true;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _newRecord =
        widget.result.correct > widget.storage.bestFor(widget.result.config);
    _save();
  }

  Future<void> _save() async {
    var saved = false;
    try {
      await widget.storage.saveResult(widget.result);
      saved = true;
    } catch (_) {
      saved = false;
    }
    if (mounted) {
      setState(() {
        _saved = saved;
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final mistakes = r.answers.where((a) => !a.isCorrect).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sua viagem em números',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.lime.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _newRecord
                        ? Icons.emoji_events_rounded
                        : Icons.outlined_flag_rounded,
                    size: 44,
                    color: AppColors.lime,
                  ),
                ),
                const SizedBox(height: 18),
                Eyebrow(
                  _newRecord
                      ? 'NOVO RECORDE NESTA SELEÇÃO'
                      : 'PARTIDA CONCLUÍDA',
                  color: _newRecord ? AppColors.gold : AppColors.lime,
                ),
                const SizedBox(height: 12),
                Text(
                  r.total == 0
                      ? 'A próxima é sua!'
                      : r.accuracy >= 80
                      ? 'Que viagem, ${r.config.player}!'
                      : 'Cada bandeira ensina!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  r.total == 0
                      ? 'Você não respondeu desta vez. Escolha um tempo maior e tente novamente.'
                      : 'O tempo acabou. Leve suas descobertas para a próxima partida.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    Tag(
                      text: r.config.gameMode.label,
                      icon: Icons.extension_outlined,
                    ),
                    Tag(text: r.config.regionLabel, icon: Icons.public_rounded),
                    Tag(text: r.config.difficulty.label, color: AppColors.gold),
                    Tag(
                      text: r.config.durationLabel,
                      icon: Icons.timer_outlined,
                      color: AppColors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                SurfaceCard(
                  child: Column(
                    children: [
                      const Eyebrow('Sua pontuação', color: AppColors.muted),
                      const SizedBox(height: 8),
                      Text(
                        '${r.correct}',
                        key: const Key('final-score'),
                        style: const TextStyle(
                          fontSize: 76,
                          color: AppColors.lime,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                          letterSpacing: -4,
                        ),
                      ),
                      Text(
                        r.correct == 1 ? 'ponto' : 'pontos',
                        style: const TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 24),
                      LayoutBuilder(
                        builder: (context, box) => Wrap(
                          spacing: 8,
                          runSpacing: 18,
                          children: [
                            _stat('Respondidas', '${r.total}', box.maxWidth),
                            _stat('Acertos', '${r.correct}', box.maxWidth),
                            _stat('Erros', '${r.errors}', box.maxWidth),
                            _stat(
                              'Precisão',
                              percentLabel(r.accuracy),
                              box.maxWidth,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.local_fire_department_outlined,
                            color: AppColors.gold,
                            size: 19,
                          ),
                          const SizedBox(width: 7),
                          Flexible(
                            child: Text(
                              'Melhor sequência: ${r.bestStreak} ${r.bestStreak == 1 ? 'acerto' : 'acertos'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  _saving
                      ? 'Guardando seu resultado...'
                      : _saved
                      ? 'Ranking atualizado neste dispositivo.'
                      : 'O resultado fica nesta sessão. Não foi possível gravar no dispositivo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _saving || _saved ? AppColors.muted : AppColors.gold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saving
                        ? null
                        : () =>
                              Navigator.of(context).pushReplacement<void, void>(
                                MaterialPageRoute(
                                  builder: (_) => GameScreen(
                                    config: r.config,
                                    countries: widget.countries,
                                    storage: widget.storage,
                                  ),
                                ),
                              ),
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Jogar novamente'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    key: const Key('back-to-menu'),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('Voltar ao menu principal'),
                  ),
                ),
                TextButton.icon(
                  onPressed: _saving
                      ? null
                      : () => Navigator.of(context).push<void>(
                          MaterialPageRoute(
                            builder: (_) => RankingScreen(
                              storage: widget.storage,
                              initialConfig: r.config,
                            ),
                          ),
                        ),
                  icon: const Icon(Icons.emoji_events_outlined, size: 19),
                  label: const Text('Conferir ranking'),
                ),
                if (mistakes.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Eyebrow('Uma descoberta para levar'),
                  ),
                  const SizedBox(height: 14),
                  for (final answer in mistakes.take(8))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SurfaceCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 62,
                              child: FlagImage(
                                asset: answer.country.flag,
                                height: 40,
                                revealName: answer.country.name,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    answer.country.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Você marcou: ${answer.selected.name}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (mistakes.length > 8)
                    const Text(
                      'Mostrando as primeiras 8 respostas para revisar.',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stat(String label, String value, double width) => SizedBox(
    width: width >= 480 ? (width - 24) / 4 : (width - 8) / 2,
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(color: AppColors.muted, fontSize: 11),
        ),
      ],
    ),
  );
}

import 'dart:async';

import 'package:flutter/material.dart';

import '../game/game_session.dart';
import '../game/quiz_engine.dart';
import '../models/country.dart';
import '../models/game_config.dart';
import '../models/game_result.dart';
import '../services/country_repository.dart';
import '../services/local_storage.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/question_prompt.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.config,
    required this.countries,
    required this.storage,
  });
  final GameConfig config;
  final CountryRepository countries;
  final LocalStorage storage;
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late GameSession _session;
  final _clock = Stopwatch();
  Timer? _timer;
  bool _finishing = false;
  bool _exitDialogOpen = false;
  bool _allowExit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _session = GameSession(
      config: widget.config,
      engine: QuizEngine(widget.countries.forConfig(widget.config)),
    );
    _clock.start();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) => _tick());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _tick();
  }

  void _tick() {
    if (!mounted || _finishing || _allowExit) return;
    setState(() => _session.synchronize(_clock.elapsed));
    if (_session.finished) _complete();
  }

  void _answer(Country country) {
    if (_finishing || _allowExit) return;
    setState(() => _session.answer(country.code, _clock.elapsed));
    if (_session.finished) _complete();
  }

  void _complete() {
    if (_finishing || !mounted) return;
    _finishing = true;
    _timer?.cancel();
    _clock.stop();
    final now = DateTime.now();
    final result = GameResult(
      id: '${now.microsecondsSinceEpoch}',
      config: widget.config,
      total: _session.answered,
      correct: _session.correct,
      bestStreak: _session.bestStreak,
      playedAt: now,
      answers: _session.answers,
    );
    // Fecha somente o diálogo desta partida, caso o prazo termine com ele aberto.
    if (_exitDialogOpen) Navigator.of(context).pop();
    Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          result: result,
          countries: widget.countries,
          storage: widget.storage,
        ),
      ),
    );
  }

  Future<void> _confirmExit() async {
    if (_exitDialogOpen || _finishing || _allowExit) return;
    _exitDialogOpen = true;
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sair da partida?'),
        content: const Text(
          'Esta partida não será salva. O cronômetro continua contando enquanto você decide.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Continuar jogando'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    _exitDialogOpen = false;
    if (leave == true && mounted && !_finishing) {
      _timer?.cancel();
      _clock.stop();
      setState(() => _allowExit = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _clock.stop();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lowTime = _session.remainingSeconds <= 10;
    final feedback = _session.feedback;
    return PopScope(
      canPop: _allowExit,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Sair da partida',
            onPressed: _confirmExit,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.config.gameMode.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${widget.config.regionLabel} · ${widget.config.durationLabel}',
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ],
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: lowTime
                    ? AppColors.error.withValues(alpha: 0.12)
                    : AppColors.raised,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 20,
                    color: lowTime ? AppColors.error : AppColors.lime,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    clockLabel(_session.remainingSeconds),
                    key: const Key('game-timer'),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: lowTime ? AppColors.error : AppColors.text,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              LinearProgressIndicator(
                value: _session.progress,
                minHeight: 3,
                backgroundColor: AppColors.raised,
                color: lowTime ? AppColors.error : AppColors.lime,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Tag(
                                text:
                                    '${_session.correct} ${_session.correct == 1 ? 'acerto' : 'acertos'}',
                                icon: Icons.check_circle_outline_rounded,
                              ),
                              const Spacer(),
                              Text(
                                'Respondidas: ${_session.answered}',
                                key: const Key('answered-count'),
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          QuestionPrompt(
                            question: _session.question,
                            mode: widget.config.gameMode,
                            revealedTiles: _session.revealedTiles,
                            number:
                                _session.answered + (feedback == null ? 1 : 0),
                          ),
                          const SizedBox(height: 18),
                          LayoutBuilder(
                            builder: (context, box) {
                              final columns =
                                  widget.config.gameMode ==
                                          GameMode.matchFlag ||
                                      box.maxWidth >= 600
                                  ? 2
                                  : 1;
                              final width =
                                  (box.maxWidth - (columns - 1) * 12) / columns;
                              return Wrap(
                                spacing: 12,
                                runSpacing: 10,
                                children: [
                                  for (
                                    var i = 0;
                                    i < _session.question.options.length;
                                    i++
                                  )
                                    SizedBox(
                                      width: width,
                                      child: _option(
                                        _session.question.options[i],
                                        i,
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 150),
                            child: SizedBox(
                              key: ValueKey(feedback),
                              width: double.infinity,
                              child: feedback == null
                                  ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Text(
                                        'Cada descoberta vale um ponto.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppColors.muted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color:
                                            (feedback.isCorrect
                                                    ? AppColors.lime
                                                    : AppColors.error)
                                                .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            feedback.isCorrect
                                                ? Icons.check_circle_rounded
                                                : Icons.info_outline_rounded,
                                            color: feedback.isCorrect
                                                ? AppColors.lime
                                                : AppColors.error,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              feedback.isCorrect
                                                  ? 'Isso! +1 ponto para sua viagem.'
                                                  : 'A resposta é ${feedback.country.name}.',
                                              style: TextStyle(
                                                color: feedback.isCorrect
                                                    ? AppColors.lime
                                                    : AppColors.error,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _option(Country country, int index) {
    final feedback = _session.feedback;
    final correct =
        feedback != null && country.code == _session.question.answer.code;
    final wrong =
        feedback != null &&
        !feedback.isCorrect &&
        country.code == feedback.selected.code;
    final color = correct
        ? AppColors.lime
        : wrong
        ? AppColors.error
        : AppColors.line;
    final isFlag = widget.config.gameMode == GameMode.matchFlag;
    final letter = String.fromCharCode(65 + index);
    final marker = Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.raised,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        letter,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 12,
          color: AppColors.muted,
        ),
      ),
    );
    final status = correct || wrong
        ? Icon(
            correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: color,
            size: 21,
          )
        : null;
    return Semantics(
      label: isFlag ? 'Bandeira $letter' : null,
      button: true,
      enabled: feedback == null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: correct || wrong
              ? color.withValues(alpha: 0.12)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: correct || wrong ? 1.5 : 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: Key('answer-${country.code}'),
            borderRadius: BorderRadius.circular(15),
            onTap: feedback == null && !_finishing
                ? () => _answer(country)
                : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: isFlag
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(children: [marker, const Spacer(), ?status]),
                        const SizedBox(height: 10),
                        ExcludeSemantics(
                          child: FlagImage(asset: country.flag, height: 80),
                        ),
                        if (feedback != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            country.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ],
                    )
                  : Row(
                      children: [
                        marker,
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            country.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: correct || wrong ? color : AppColors.text,
                            ),
                          ),
                        ),
                        if (status != null) ...[
                          const SizedBox(width: 6),
                          status,
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

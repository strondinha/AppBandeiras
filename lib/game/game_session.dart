import 'dart:math';

import '../models/game_config.dart';
import '../models/game_result.dart';
import 'quiz_engine.dart';

/// Regras independentes da interface: o relógio é fornecido pela tela.
class GameSession {
  GameSession({required this.config, required QuizEngine engine})
    : _engine = engine,
      question = engine.next();

  static const feedbackDuration = Duration(milliseconds: 850);
  final GameConfig config;
  final QuizEngine _engine;
  Question question;
  Duration _elapsed = Duration.zero;
  Duration? _answeredAt;
  Duration _questionStartedAt = Duration.zero;
  int get revealedTiles => feedback != null
      ? 12
      : min(
          12,
          3 + ((_elapsed - _questionStartedAt).inMilliseconds ~/ 1500) * 2,
        );
  final List<AnswerRecord> _answers = [];
  AnswerRecord? feedback;
  bool finished = false;
  int correct = 0;
  int streak = 0;
  int bestStreak = 0;

  int get answered => _answers.length;
  List<AnswerRecord> get answers => List.unmodifiable(_answers);
  int get remainingMilliseconds =>
      max(0, config.durationSeconds * 1000 - _elapsed.inMilliseconds);
  int get remainingSeconds => (remainingMilliseconds / 1000).ceil();
  double get progress =>
      remainingMilliseconds / (config.durationSeconds * 1000);

  void synchronize(Duration elapsed) {
    if (finished) return;
    if (elapsed > _elapsed) _elapsed = elapsed;
    if (remainingMilliseconds <= 0) {
      finished = true;
      return;
    }
    if (_answeredAt != null && _elapsed - _answeredAt! >= feedbackDuration) {
      feedback = null;
      _answeredAt = null;
      question = _engine.next();
      _questionStartedAt = _elapsed;
    }
  }

  bool answer(String countryCode, Duration elapsed) {
    synchronize(elapsed);
    if (finished || feedback != null) return false;
    final selected = question.options
        .where((c) => c.code == countryCode)
        .firstOrNull;
    if (selected == null) return false;
    final record = AnswerRecord(country: question.answer, selected: selected);
    _answers.add(record);
    feedback = record;
    _answeredAt = _elapsed;
    if (record.isCorrect) {
      correct++;
      streak++;
      bestStreak = max(bestStreak, streak);
    } else {
      streak = 0;
    }
    return true;
  }
}

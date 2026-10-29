import 'country.dart';
import 'game_config.dart';

class AnswerRecord {
  const AnswerRecord({required this.country, required this.selected});
  final Country country;
  final Country selected;
  bool get isCorrect => country.code == selected.code;
}

class GameResult {
  const GameResult({
    required this.id,
    required this.config,
    required this.total,
    required this.correct,
    required this.bestStreak,
    required this.playedAt,
    this.answers = const [],
  });

  final String id;
  final GameConfig config;
  final int total;
  final int correct;
  final int bestStreak;
  final DateTime playedAt;
  final List<AnswerRecord> answers;

  int get errors => total - correct;
  double get accuracy => total == 0 ? 0 : correct * 100 / total;

  Map<String, dynamic> toJson() => {
    'id': id,
    'config': config.toJson(),
    'total': total,
    'correct': correct,
    'bestStreak': bestStreak,
    'playedAt': playedAt.toIso8601String(),
  };

  factory GameResult.fromJson(Map<String, dynamic> json) {
    final total = json['total'] as int;
    final correct = json['correct'] as int;
    final streak = json['bestStreak'] as int;
    if (total < 0 ||
        correct < 0 ||
        correct > total ||
        streak < 0 ||
        streak > correct) {
      throw const FormatException('Pontuação inválida.');
    }
    return GameResult(
      id: json['id'] as String,
      config: GameConfig.fromJson(json['config'] as Map<String, dynamic>),
      total: total,
      correct: correct,
      bestStreak: streak,
      playedAt: DateTime.parse(json['playedAt'] as String),
    );
  }

  static int compare(GameResult a, GameResult b) {
    final points = b.correct.compareTo(a.correct);
    if (points != 0) return points;
    final accuracy = b.accuracy.compareTo(a.accuracy);
    if (accuracy != 0) return accuracy;
    return b.playedAt.compareTo(a.playedAt);
  }
}

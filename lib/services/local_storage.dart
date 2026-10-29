import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_config.dart';
import '../models/game_result.dart';

class LocalStorage {
  LocalStorage(this._preferences) {
    _load();
  }

  final SharedPreferences? _preferences;
  static const _settingsKey = 'atlas.settings.v1';
  static const _scoresKey = 'atlas.scores.v1';
  static const _perBucketLimit = 10;
  GameConfig settings = const GameConfig();
  final List<GameResult> _scores = [];
  bool get isPersistent => _preferences != null;

  void _load() {
    // Um registro danificado não impede o restante do jogo de abrir.
    try {
      final raw = _preferences?.getString(_settingsKey);
      if (raw != null) {
        settings = GameConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (_) {
      settings = const GameConfig();
    }
    try {
      final raw = _preferences?.getString(_scoresKey);
      if (raw == null) return;
      for (final item in jsonDecode(raw) as List<dynamic>) {
        try {
          final score = GameResult.fromJson(item as Map<String, dynamic>);
          if (!_scores.any((s) => s.id == score.id)) _scores.add(score);
        } catch (_) {
          continue;
        }
      }
    } catch (_) {
      _scores.clear();
    }
  }

  List<GameResult> leaderboard(GameConfig config) =>
      _scores.where((score) => score.config.bucket == config.bucket).toList()
        ..sort(GameResult.compare);

  int bestFor(GameConfig config) =>
      leaderboard(config).firstOrNull?.correct ?? 0;
  int get savedGames => _scores.length;

  Future<void> saveSettings(GameConfig config) async {
    settings = config;
    final saved = await _preferences?.setString(
      _settingsKey,
      jsonEncode(config.toJson()),
    );
    if (saved != true) {
      throw StateError('Não foi possível salvar as preferências.');
    }
  }

  Future<void> saveResult(GameResult result) async {
    if (!_scores.any((s) => s.id == result.id)) _scores.add(result);
    // Mantém dez resultados por combinação, sem apagar recordes de outros modos.
    final bucket = leaderboard(result.config);
    final discard = bucket.skip(_perBucketLimit).map((s) => s.id).toSet();
    _scores.removeWhere((s) => discard.contains(s.id));
    final saved = await _preferences?.setString(
      _scoresKey,
      jsonEncode(_scores.map((s) => s.toJson()).toList()),
    );
    if (saved != true) {
      throw StateError('O ranking ficará disponível apenas nesta sessão.');
    }
  }

  Future<void> clearScores() async {
    final removed = await _preferences?.remove(_scoresKey);
    if (removed != true) throw StateError('Não foi possível limpar o ranking.');
    _scores.clear();
  }
}

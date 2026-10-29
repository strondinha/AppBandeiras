import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flag_game_atlas/models/country.dart';
import 'package:flag_game_atlas/models/game_config.dart';
import 'package:flag_game_atlas/models/game_result.dart';
import 'package:flag_game_atlas/services/local_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  GameResult score(
    String id,
    int correct, {
    GameConfig config = const GameConfig(),
    int? total,
  }) => GameResult(
    id: id,
    config: config,
    total: total ?? correct,
    correct: correct,
    bestStreak: correct,
    playedAt: DateTime(
      2026,
      10,
      29,
    ).add(Duration(seconds: int.tryParse(id) ?? 0)),
  );

  test('Nome e configurações persistem ao reconstruir o serviço', () async {
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalStorage(prefs);
    const config = GameConfig(
      player: 'Caio',
      durationSeconds: 180,
      continent: Continent.africa,
      difficulty: Difficulty.easy,
    );
    await storage.saveSettings(config);
    final reloaded = LocalStorage(prefs).settings;
    expect(reloaded.toJson(), config.toJson());
  });

  test('Ranking persiste, ordena e mantém dez por combinação', () async {
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalStorage(prefs);
    for (var i = 0; i < 13; i++) {
      await storage.saveResult(score('$i', i));
    }
    const otherConfig = GameConfig(
      durationSeconds: 30,
      difficulty: Difficulty.easy,
      continent: Continent.oceania,
    );
    await storage.saveResult(score('other', 100, config: otherConfig));
    final reloaded = LocalStorage(prefs);
    expect(reloaded.leaderboard(const GameConfig()).length, 10);
    expect(reloaded.bestFor(const GameConfig()), 12);
    expect(reloaded.bestFor(otherConfig), 100);
    expect(reloaded.savedGames, 11);
  });

  test('Ranking não mistura duração, dificuldade ou continente', () async {
    final storage = LocalStorage(await SharedPreferences.getInstance());
    await storage.saveResult(score('1', 5));
    for (final other in [
      const GameConfig(durationSeconds: 30),
      const GameConfig(difficulty: Difficulty.easy),
      const GameConfig(continent: Continent.america),
    ]) {
      expect(storage.leaderboard(other), isEmpty);
    }
  });

  test('Mesmo resultado não é salvo duas vezes', () async {
    final storage = LocalStorage(await SharedPreferences.getInstance());
    final result = score('1', 2);
    await storage.saveResult(result);
    await storage.saveResult(result);
    expect(storage.savedGames, 1);
  });

  test('Empate usa precisão e depois data mais recente', () async {
    final storage = LocalStorage(await SharedPreferences.getInstance());
    await storage.saveResult(score('1', 5, total: 10));
    await storage.saveResult(score('2', 5, total: 7));
    await storage.saveResult(score('3', 5, total: 7));
    expect(storage.leaderboard(const GameConfig()).map((s) => s.id), [
      '3',
      '2',
      '1',
    ]);
  });

  test('Dados danificados não impedem a abertura do aplicativo', () async {
    SharedPreferences.setMockInitialValues({
      'atlas.settings.v1': '{invalid',
      'atlas.scores.v1': jsonEncode([
        {'invalid': true},
        score('1', 2).toJson(),
      ]),
    });
    final storage = LocalStorage(await SharedPreferences.getInstance());
    expect(storage.settings.durationSeconds, 60);
    expect(storage.savedGames, 1);
  });

  test('Limpar ranking mantém nome e configurações', () async {
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalStorage(prefs);
    await storage.saveSettings(const GameConfig(player: 'Caio'));
    await storage.saveResult(score('1', 2));
    await storage.clearScores();
    final reloaded = LocalStorage(prefs);
    expect(reloaded.savedGames, 0);
    expect(reloaded.settings.player, 'Caio');
  });

  test(
    'Sem armazenamento, resultado permanece em memória e falha é informada',
    () async {
      final storage = LocalStorage(null);
      expect(storage.isPersistent, isFalse);
      await expectLater(storage.saveResult(score('1', 2)), throwsStateError);
      expect(storage.bestFor(const GameConfig()), 2);
    },
  );
}

import 'dart:convert';
import 'dart:math';

import 'package:flag_game_atlas/game/game_session.dart';
import 'package:flag_game_atlas/game/quiz_engine.dart';
import 'package:flag_game_atlas/models/game_config.dart';
import 'package:flag_game_atlas/models/game_result.dart';
import 'package:flag_game_atlas/screens/game_screen.dart';
import 'package:flag_game_atlas/screens/home_screen.dart';
import 'package:flag_game_atlas/screens/ranking_screen.dart';
import 'package:flag_game_atlas/services/local_storage.dart';
import 'package:flag_game_atlas/theme/app_theme.dart';
import 'package:flag_game_atlas/widgets/common.dart';
import 'package:flag_game_atlas/widgets/question_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'catalog_test.dart' show loadCatalog;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final catalog = loadCatalog();
  late LocalStorage storage;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorage(await SharedPreferences.getInstance());
  });

  Widget app(Widget home) => MaterialApp(
    theme: buildTheme(),
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: home,
  );

  GameSession session(GameMode mode) => GameSession(
    config: GameConfig(gameMode: mode, durationSeconds: 30),
    engine: QuizEngine(catalog.countries, random: Random(44)),
  );

  for (final mode in GameMode.values) {
    test('Modo ${mode.name} preserva configuração ao salvar e ler JSON', () {
      final config = GameConfig(
        gameMode: mode,
        player: 'Teste',
        durationSeconds: 180,
        difficulty: Difficulty.easy,
      );
      expect(GameConfig.fromJson(config.toJson()).toJson(), config.toJson());
      expect(config.copyWith(durationSeconds: 300).gameMode, mode);
    });

    test('Modo ${mode.name} mantém pontos, bloqueio, avanço e tempo total', () {
      final game = session(mode);
      final code = game.question.answer.code;
      expect(game.answer(code, const Duration(seconds: 1)), isTrue);
      expect(game.answer(code, const Duration(milliseconds: 1050)), isFalse);
      expect(game.correct, 1);
      game.synchronize(const Duration(seconds: 2));
      final wrong = game.question.options.firstWhere(
        (c) => c.code != game.question.answer.code,
      );
      game.answer(wrong.code, const Duration(seconds: 3));
      expect(game.answered, 2);
      expect(game.correct, 1);
      expect(game.remainingSeconds, 27);
      game.synchronize(const Duration(seconds: 30));
      expect(game.finished, isTrue);
    });
  }

  test('Configuração antiga ou modo desconhecido abre no desafio de nomes', () {
    final old = const GameConfig().toJson()..remove('gameMode');
    expect(GameConfig.fromJson(old).gameMode, GameMode.identify);
    old['gameMode'] = 'unknown';
    expect(GameConfig.fromJson(old).gameMode, GameMode.identify);
  });

  test(
    'Mosaico abre partes, mostra tudo no feedback e reinicia na próxima rodada',
    () {
      final game = session(GameMode.reveal);
      expect(game.revealedTiles, 3);
      game.synchronize(const Duration(milliseconds: 1499));
      expect(game.revealedTiles, 3);
      game.synchronize(const Duration(milliseconds: 1500));
      expect(game.revealedTiles, 5);
      game.synchronize(const Duration(milliseconds: 3000));
      expect(game.revealedTiles, 7);
      game.answer(
        game.question.answer.code,
        const Duration(milliseconds: 3100),
      );
      expect(game.revealedTiles, 12);
      game.synchronize(const Duration(milliseconds: 3950));
      expect(game.revealedTiles, 3);
      expect(game.remainingMilliseconds, 26050);
      game.synchronize(const Duration(milliseconds: 11450));
      expect(game.revealedTiles, 12);
    },
  );

  GameResult score(String id, GameMode mode) => GameResult(
    id: id,
    config: GameConfig(gameMode: mode, player: id),
    total: 2,
    correct: 1,
    bestStreak: 1,
    playedAt: DateTime(2026),
  );

  test(
    'Ranking antigo é preservado; novos modos têm resultados independentes',
    () async {
      final old = score('Antigo', GameMode.identify).toJson();
      (old['config'] as Map<String, dynamic>).remove('gameMode');
      SharedPreferences.setMockInitialValues({
        'atlas.scores.v1': jsonEncode([old]),
      });
      final prefs = await SharedPreferences.getInstance();
      final service = LocalStorage(prefs);
      for (final mode in [GameMode.matchFlag, GameMode.reveal]) {
        await service.saveResult(score(mode.name, mode));
      }
      await service.saveSettings(const GameConfig(gameMode: GameMode.reveal));
      final restored = LocalStorage(prefs);
      expect(restored.settings.gameMode, GameMode.reveal);
      for (final mode in GameMode.values) {
        expect(restored.leaderboard(GameConfig(gameMode: mode)).length, 1);
      }
      expect(restored.leaderboard(const GameConfig()).single.id, 'Antigo');
    },
  );

  testWidgets(
    'Selecionar o modo inverso no menu abre o país com quatro bandeiras',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        app(HomeScreen(countries: catalog, storage: storage)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('mode-matchFlag')));
      await tester.ensureVisible(find.byKey(const Key('start-game')));
      await tester.tap(find.byKey(const Key('start-game')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Qual é a bandeira deste país?'), findsOneWidget);
      expect(find.byKey(const Key('target-country')), findsOneWidget);
      expect(find.byType(FlagImage), findsNWidgets(4));
      final prompt = tester.widget<QuestionPrompt>(find.byType(QuestionPrompt));
      expect(prompt.mode, GameMode.matchFlag);
      for (final option in prompt.question.options) {
        final button = find.byKey(Key('answer-${option.code}'));
        expect(
          find.descendant(of: button, matching: find.text(option.name)),
          findsNothing,
        );
      }
      await tester.ensureVisible(
        find.byKey(Key('answer-${prompt.question.answer.code}')),
      );
      await tester.tap(
        find.byKey(Key('answer-${prompt.question.answer.code}')),
      );
      await tester.pump();
      expect(find.text('Isso! +1 ponto para sua viagem.'), findsOneWidget);
      for (final option in prompt.question.options) {
        expect(
          find.descendant(
            of: find.byKey(Key('answer-${option.code}')),
            matching: find.text(option.name),
          ),
          findsOneWidget,
        );
      }
      await tester.pumpWidget(const SizedBox());
    },
  );

  for (final mode in [GameMode.matchFlag, GameMode.reveal]) {
    testWidgets(
      '${mode.name} em celular: pergunta, alternativas e feedback sem estouro',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          app(
            GameScreen(
              config: GameConfig(gameMode: mode),
              countries: catalog,
              storage: storage,
            ),
          ),
        );
        await tester.pump();
        final prompt = tester.widget<QuestionPrompt>(
          find.byType(QuestionPrompt),
        );
        if (mode == GameMode.reveal) {
          expect(
            tester.widget<SecretFlag>(find.byType(SecretFlag)).revealedTiles,
            3,
          );
        }
        await tester.ensureVisible(
          find.byKey(Key('answer-${prompt.question.answer.code}')),
        );
        await tester.tap(
          find.byKey(Key('answer-${prompt.question.answer.code}')),
        );
        await tester.pump();
        expect(find.text('Respondidas: 1'), findsOneWidget);
        if (mode == GameMode.reveal) {
          expect(
            tester.widget<SecretFlag>(find.byType(SecretFlag)).revealedTiles,
            12,
          );
        }
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets('Filtro do ranking troca o modo sem misturar resultados', (
    tester,
  ) async {
    await storage.saveResult(score('Clássico QA', GameMode.identify));
    await storage.saveResult(score('Inverso QA', GameMode.matchFlag));
    await tester.pumpWidget(
      app(RankingScreen(storage: storage, initialConfig: const GameConfig())),
    );
    await tester.pumpAndSettle();
    expect(find.text('Clássico QA'), findsOneWidget);
    expect(find.text('Inverso QA'), findsNothing);
    await tester.tap(find.byType(DropdownButtonFormField<GameMode>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(GameMode.matchFlag.label).last);
    await tester.pumpAndSettle();
    expect(find.text('Inverso QA'), findsOneWidget);
    expect(find.text('Clássico QA'), findsNothing);
  });
}

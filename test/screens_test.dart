import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flag_game_atlas/models/game_config.dart';
import 'package:flag_game_atlas/models/game_result.dart';
import 'package:flag_game_atlas/screens/game_screen.dart';
import 'package:flag_game_atlas/screens/home_screen.dart';
import 'package:flag_game_atlas/screens/ranking_screen.dart';
import 'package:flag_game_atlas/screens/result_screen.dart';
import 'package:flag_game_atlas/services/local_storage.dart';
import 'package:flag_game_atlas/theme/app_theme.dart';

import 'catalog_test.dart' show loadCatalog;

void main() {
  final catalog = loadCatalog();
  late LocalStorage storage;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorage(await SharedPreferences.getInstance());
  });
  Widget app(Widget child, {double scale = 1}) => MaterialApp(
    theme: buildTheme(),
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: child,
  );

  for (final size in [
    const Size(360, 800),
    const Size(768, 1024),
    const Size(832, 900),
    const Size(1440, 900),
  ]) {
    testWidgets('Menu responsivo em ${size.width.toInt()}px', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        app(HomeScreen(countries: catalog, storage: storage)),
      );
      await tester.pumpAndSettle();
      expect(find.text('Flag Game'), findsOneWidget);
      expect(find.text('Tempo total do jogo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Menu aceita texto ampliado sem estouro de layout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      app(HomeScreen(countries: catalog, storage: storage), scale: 1.5),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('Seleção de continente e tempo chega à partida', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      app(HomeScreen(countries: catalog, storage: storage)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('duration-30')));
    await tester.ensureVisible(find.byKey(const Key('continent-asia')));
    await tester.tap(find.byKey(const Key('continent-asia')));
    await tester.ensureVisible(find.byKey(const Key('start-game')));
    await tester.tap(find.byKey(const Key('start-game')));
    // A partida tem um Timer periódico; pumpAndSettle não espera seu término.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(GameScreen), findsOneWidget);
    expect(find.text('Qual é o país?'), findsOneWidget);
    expect(find.byKey(const Key('game-timer')), findsOneWidget);
    final answers = find.byWidgetPredicate(
      (widget) =>
          widget.key is ValueKey<String> &&
          (widget.key as ValueKey<String>).value.startsWith('answer-'),
    );
    expect(answers, findsNWidgets(4));
    await tester.ensureVisible(answers.first);
    await tester.tap(answers.first);
    await tester.pump();
    await tester.tap(answers.first);
    await tester.pump();
    expect(find.text('Respondidas: 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Resultado exibe totais e salva sem duplicar', (tester) async {
    final result = GameResult(
      id: 'widget-result',
      config: const GameConfig(player: 'Caio'),
      total: 5,
      correct: 3,
      bestStreak: 2,
      playedAt: DateTime(2026),
    );
    await tester.pumpWidget(
      app(ResultScreen(result: result, countries: catalog, storage: storage)),
    );
    await tester.pumpAndSettle();
    expect(find.text('60%'), findsOneWidget);
    expect(find.text('Respondidas'), findsOneWidget);
    expect(find.text('Acertos'), findsOneWidget);
    expect(find.text('Voltar ao menu principal'), findsOneWidget);
    expect(storage.bestFor(const GameConfig()), 3);
    await tester.pump();
    expect(storage.savedGames, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Ranking vazio orienta a concluir uma partida', (tester) async {
    await tester.pumpWidget(
      app(RankingScreen(storage: storage, initialConfig: const GameConfig())),
    );
    await tester.pumpAndSettle();
    expect(find.text('O primeiro lugar está esperando.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

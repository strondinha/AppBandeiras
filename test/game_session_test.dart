import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:flag_game_atlas/game/game_session.dart';
import 'package:flag_game_atlas/game/quiz_engine.dart';
import 'package:flag_game_atlas/models/country.dart';
import 'package:flag_game_atlas/models/game_config.dart';
import 'package:flag_game_atlas/models/game_result.dart';

void main() {
  final pool = List.generate(
    6,
    (i) => Country(
      code: 'C$i',
      name: 'País $i',
      continent: Continent.america,
      easy: true,
      flag: 'flag$i.png',
    ),
  );
  GameSession session({int seconds = 30}) => GameSession(
    config: GameConfig(durationSeconds: seconds),
    engine: QuizEngine(pool, random: Random(7)),
  );

  test('Começa com o tempo total e sem respostas', () {
    final game = session();
    expect(game.remainingSeconds, 30);
    expect(game.progress, 1);
    expect(game.answered, 0);
    expect(game.finished, isFalse);
  });

  test('Acerto vale exatamente um ponto e toque repetido não conta', () {
    final game = session();
    expect(
      game.answer(game.question.answer.code, const Duration(milliseconds: 100)),
      isTrue,
    );
    expect(
      game.answer(game.question.answer.code, const Duration(milliseconds: 110)),
      isFalse,
    );
    expect(game.correct, 1);
    expect(game.answered, 1);
    expect(game.feedback!.isCorrect, isTrue);
  });

  test('Erro conta como resposta e não tira pontos', () {
    final game = session();
    final wrong = game.question.options.firstWhere(
      (c) => c.code != game.question.answer.code,
    );
    expect(game.answer(wrong.code, const Duration(seconds: 1)), isTrue);
    expect(game.correct, 0);
    expect(game.answered, 1);
    expect(game.feedback!.isCorrect, isFalse);
  });

  test('Alternativa inexistente não modifica os totais', () {
    final game = session();
    expect(game.answer('ZZ', Duration.zero), isFalse);
    expect(game.answered, 0);
  });

  test('Feedback dura 850ms e depois avança automaticamente', () {
    final game = session();
    final previous = game.question.answer.code;
    game.answer(previous, const Duration(seconds: 1));
    game.synchronize(const Duration(milliseconds: 1849));
    expect(game.feedback, isNotNull);
    game.synchronize(const Duration(milliseconds: 1850));
    expect(game.feedback, isNull);
    expect(game.question.answer.code, isNot(previous));
    expect(game.remainingMilliseconds, 28150);
  });

  test('O cronômetro é total, sem reiniciar entre perguntas', () {
    final game = session();
    game.answer(game.question.answer.code, const Duration(seconds: 7));
    game.synchronize(const Duration(seconds: 9));
    expect(game.remainingSeconds, 21);
    expect(game.answered, 1);
    game.synchronize(const Duration(seconds: 30));
    expect(game.finished, isTrue);
  });

  for (final duration in GameConfig.durations) {
    test(
      'Encerra exatamente em $duration segundos e recusa respostas tardias',
      () {
        final game = session(seconds: duration);
        game.synchronize(Duration(milliseconds: duration * 1000 - 1));
        expect(game.finished, isFalse);
        expect(game.remainingSeconds, 1);
        expect(
          game.answer(game.question.answer.code, Duration(seconds: duration)),
          isFalse,
        );
        expect(game.finished, isTrue);
        expect(game.answered, 0);
        expect(game.remainingSeconds, 0);
      },
    );
  }

  test(
    'Último acerto antes do prazo conta mesmo se o feedback for interrompido',
    () {
      final game = session();
      game.answer(
        game.question.answer.code,
        const Duration(milliseconds: 29999),
      );
      game.synchronize(const Duration(seconds: 30));
      expect(game.correct, 1);
      expect(game.answered, 1);
      expect(game.finished, isTrue);
      game.answer(game.question.answer.code, const Duration(seconds: 31));
      expect(game.correct, 1);
    },
  );

  test(
    'Retorno após longo intervalo termina o jogo sem descontar só um tick',
    () {
      final game = session();
      game.synchronize(const Duration(seconds: 180));
      expect(game.finished, isTrue);
      expect(game.remainingMilliseconds, 0);
    },
  );

  test('Relógio atrasado não aumenta o tempo restante', () {
    final game = session();
    game.synchronize(const Duration(seconds: 10));
    game.synchronize(const Duration(seconds: 5));
    expect(game.remainingSeconds, 20);
  });

  test('Sequência de acertos reinicia após erro', () {
    final game = session();
    for (var i = 0; i < 2; i++) {
      game.answer(game.question.answer.code, Duration(seconds: i * 2));
      game.synchronize(Duration(seconds: i * 2 + 1));
    }
    final wrong = game.question.options.firstWhere(
      (c) => c.code != game.question.answer.code,
    );
    game.answer(wrong.code, const Duration(seconds: 5));
    expect(game.streak, 0);
    expect(game.bestStreak, 2);
    expect(game.answered, 3);
  });

  test('Sem resposta, resultado tem 0% em vez de divisão por zero', () {
    final result = GameResult(
      id: 'empty',
      config: const GameConfig(),
      total: 0,
      correct: 0,
      bestStreak: 0,
      playedAt: DateTime(2026),
    );
    expect(result.accuracy, 0);
    expect(result.errors, 0);
  });
}

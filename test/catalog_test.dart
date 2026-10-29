import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:flag_game_atlas/game/quiz_engine.dart';
import 'package:flag_game_atlas/models/country.dart';
import 'package:flag_game_atlas/models/game_config.dart';
import 'package:flag_game_atlas/services/country_repository.dart';

CountryRepository loadCatalog() => CountryRepository(
  (jsonDecode(File('assets/data/countries.json').readAsStringSync())
          as List<dynamic>)
      .map((row) => Country.fromJson(row as Map<String, dynamic>))
      .toList(),
);

void main() {
  final repository = loadCatalog();
  test('Catálogo contém 195 países e 195 imagens locais válidas', () {
    expect(repository.countries.length, 195);
    expect(repository.countries.map((c) => c.code).toSet().length, 195);
    expect(repository.countries.map((c) => c.name).toSet().length, 195);
    for (final country in repository.countries) {
      expect(country.name, isNotEmpty);
      final file = File(country.flag);
      expect(file.existsSync(), isTrue, reason: country.name);
      expect(file.readAsBytesSync().take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
    }
  });

  test('Cinco continentes têm a quantidade esperada de países', () {
    const counts = {
      Continent.africa: 54,
      Continent.america: 35,
      Continent.asia: 47,
      Continent.europe: 45,
      Continent.oceania: 14,
    };
    for (final entry in counts.entries) {
      expect(
        repository.forConfig(GameConfig(continent: entry.key)).length,
        entry.value,
      );
    }
  });

  for (final continent in [null, ...Continent.values]) {
    for (final difficulty in Difficulty.values) {
      test(
        'Perguntas e alternativas respeitam ${continent?.label ?? 'Mundo'} / ${difficulty.label}',
        () {
          final pool = repository.forConfig(
            GameConfig(continent: continent, difficulty: difficulty),
          );
          expect(pool.length, greaterThanOrEqualTo(4));
          final engine = QuizEngine(pool, random: Random(23));
          for (var i = 0; i < pool.length * 2; i++) {
            final question = engine.next();
            expect(question.options.length, 4);
            expect(question.options.map((c) => c.code).toSet().length, 4);
            expect(
              question.options
                  .where((c) => c.code == question.answer.code)
                  .length,
              1,
            );
            for (final option in question.options) {
              if (continent != null) expect(option.continent, continent);
              if (difficulty == Difficulty.easy) expect(option.easy, isTrue);
            }
          }
        },
      );
    }
  }

  test('Não repete bandeira antes de esgotar o ciclo nem na virada', () {
    final pool = repository.forConfig(
      const GameConfig(continent: Continent.oceania),
    );
    final engine = QuizEngine(pool, random: Random(1));
    String? previous;
    for (var cycle = 0; cycle < 12; cycle++) {
      final seen = <String>{};
      for (var i = 0; i < pool.length; i++) {
        final code = engine.next().answer.code;
        expect(code, isNot(previous));
        expect(seen.add(code), isTrue);
        previous = code;
      }
    }
  });

  test('Nível fácil é uma seleção menor com pelo menos quatro países por continente', () {
    expect(
      repository
          .forConfig(const GameConfig(difficulty: Difficulty.easy))
          .length,
      67,
    );
    expect(
      () => QuizEngine(repository.countries.take(3).toList()),
      throwsArgumentError,
    );
  });
}

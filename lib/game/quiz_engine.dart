import 'dart:math';

import '../models/country.dart';

class Question {
  const Question({required this.answer, required this.options});
  final Country answer;
  final List<Country> options;
}

class QuizEngine {
  QuizEngine(List<Country> countries, {Random? random})
    : _countries = List.unmodifiable(countries),
      _random = random ?? Random() {
    if (countries.map((c) => c.code).toSet().length < 4) {
      throw ArgumentError(
        'O jogo precisa de pelo menos quatro países diferentes.',
      );
    }
  }

  final List<Country> _countries;
  final Random _random;
  final List<Country> _bag = [];
  String? _lastCode;

  Question next() {
    // Um ciclo esgota o conjunto antes de sortear novamente qualquer bandeira.
    if (_bag.isEmpty) {
      _bag.addAll(_countries);
      _bag.shuffle(_random);
      if (_bag.last.code == _lastCode) {
        final first = _bag[0];
        _bag[0] = _bag.last;
        _bag[_bag.length - 1] = first;
      }
    }
    final answer = _bag.removeLast();
    _lastCode = answer.code;
    final distractors = _countries.where((c) => c.code != answer.code).toList()
      ..shuffle(_random);
    final options = [answer, ...distractors.take(3)]..shuffle(_random);
    return Question(answer: answer, options: List.unmodifiable(options));
  }
}

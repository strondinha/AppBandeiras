import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/country.dart';
import '../models/game_config.dart';

class CountryRepository {
  CountryRepository(List<Country> countries)
    : countries = List.unmodifiable(countries) {
    if (countries.map((c) => c.code).toSet().length != countries.length) {
      throw const FormatException('O catálogo contém países duplicados.');
    }
    for (final continent in Continent.values) {
      for (final difficulty in Difficulty.values) {
        if (forConfig(GameConfig(continent: continent, difficulty: difficulty))
                .length <
            4) {
          throw const FormatException(
            'São necessários quatro países por modo.',
          );
        }
      }
    }
  }

  final List<Country> countries;

  static Future<CountryRepository> load({AssetBundle? bundle}) async {
    final source = await (bundle ?? rootBundle).loadString(
      'assets/data/countries.json',
    );
    final list = jsonDecode(source) as List<dynamic>;
    return CountryRepository(
      list.map((row) => Country.fromJson(row as Map<String, dynamic>)).toList(),
    );
  }

  List<Country> forConfig(GameConfig config) => countries
      .where(
        (c) =>
            (config.continent == null || c.continent == config.continent) &&
            (config.difficulty == Difficulty.hard || c.easy),
      )
      .toList();
}

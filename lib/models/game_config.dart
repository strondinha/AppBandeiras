import 'country.dart';

enum Difficulty {
  easy('Fácil', 'Bandeiras mais conhecidas'),
  hard('Difícil', 'Todos os países do catálogo');

  const Difficulty(this.label, this.description);
  final String label;
  final String description;
}

enum GameMode {
  identify('Qual é o país?', 'Observe a bandeira e escolha o nome do país.'),
  matchFlag(
    'Encontre a bandeira',
    'Leia o nome do país e escolha uma das quatro bandeiras.',
  ),
  reveal(
    'Bandeira secreta',
    'Descubra o país enquanto a bandeira se revela em partes.',
  );

  const GameMode(this.label, this.description);
  final String label;
  final String description;
}

class GameConfig {
  const GameConfig({
    this.player = 'Jogador',
    this.gameMode = GameMode.identify,
    this.durationSeconds = 60,
    this.difficulty = Difficulty.hard,
    this.continent,
  });

  static const durations = [30, 60, 180, 300];
  final String player;
  final GameMode gameMode;
  final int durationSeconds;
  final Difficulty difficulty;
  final Continent? continent;

  String get regionLabel => continent?.label ?? 'Mundo todo';
  String get durationLabel => switch (durationSeconds) {
    30 => '30 s',
    60 => '1 min',
    180 => '3 min',
    300 => '5 min',
    _ => '$durationSeconds s',
  };

  // O recorde é comparado somente entre partidas com as mesmas regras.
  String get bucket =>
      '${gameMode.name}-${continent?.id ?? 'world'}-${difficulty.name}-$durationSeconds';

  GameConfig copyWith({
    String? player,
    GameMode? gameMode,
    int? durationSeconds,
    Difficulty? difficulty,
    Continent? continent,
    bool world = false,
  }) => GameConfig(
    player: player ?? this.player,
    gameMode: gameMode ?? this.gameMode,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    difficulty: difficulty ?? this.difficulty,
    continent: world ? null : (continent ?? this.continent),
  );

  Map<String, dynamic> toJson() => {
    'player': player,
    'gameMode': gameMode.name,
    'duration': durationSeconds,
    'difficulty': difficulty.name,
    'continent': continent?.id,
  };

  factory GameConfig.fromJson(Map<String, dynamic> json) {
    final rawName = (json['player'] as String? ?? '').trim();
    final name = rawName.isEmpty ? 'Jogador' : rawName;
    final duration = json['duration'];
    final continent = json['continent'];
    return GameConfig(
      gameMode:
          GameMode.values
              .where((m) => m.name == json['gameMode'])
              .firstOrNull ??
          GameMode.identify,
      player: name.length > 24 ? name.substring(0, 24) : name,
      durationSeconds: durations.contains(duration) ? duration as int : 60,
      difficulty: json['difficulty'] == 'easy'
          ? Difficulty.easy
          : Difficulty.hard,
      continent: continent == null
          ? null
          : Continent.fromId(continent as String),
    );
  }
}

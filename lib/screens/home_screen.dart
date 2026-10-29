import 'package:flutter/material.dart';

import '../models/country.dart';
import '../models/game_config.dart';
import '../services/country_repository.dart';
import '../services/local_storage.dart';
import '../theme/app_theme.dart';
import '../widgets/atlas_globe.dart';
import '../widgets/common.dart';
import '../widgets/mode_picker.dart';
import 'game_screen.dart';
import 'help_screen.dart';
import 'ranking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.countries, required this.storage});
  final CountryRepository countries;
  final LocalStorage storage;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GameConfig _config;
  late TextEditingController _name;
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    _config = widget.storage.settings;
    _name = TextEditingController(
      text: _config.player == 'Jogador' ? '' : _config.player,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    if (_starting) return;
    setState(() => _starting = true);
    FocusScope.of(context).unfocus();
    final name = _name.text.trim();
    final gameConfig = _config.copyWith(
      player: name.isEmpty ? 'Jogador' : name,
    );
    _config = gameConfig;
    try {
      await widget.storage.saveSettings(gameConfig);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'As preferências não puderam ser salvas. Você pode jogar normalmente.',
            ),
          ),
        );
      }
    }
    if (!mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => GameScreen(
          config: gameConfig,
          countries: widget.countries,
          storage: widget.storage,
        ),
      ),
    );
    if (mounted) setState(() => _starting = false);
  }

  Future<void> _ranking() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) =>
            RankingScreen(storage: widget.storage, initialConfig: _config),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 880;
          final compact = constraints.maxWidth < 520;
          final count = widget.countries.forConfig(_config).length;
          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1220),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 20 : 36,
                    24,
                    compact ? 20 : 36,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Brand(compact: compact)),
                          if (!compact)
                            TextButton.icon(
                              onPressed: _ranking,
                              icon: const Icon(
                                Icons.emoji_events_outlined,
                                size: 20,
                              ),
                              label: const Text('Ranking'),
                            )
                          else
                            IconButton(
                              tooltip: 'Ranking',
                              onPressed: _ranking,
                              icon: const Icon(Icons.emoji_events_outlined),
                            ),
                          IconButton(
                            tooltip: 'Como jogar',
                            onPressed: () => Navigator.of(context).push<void>(
                              MaterialPageRoute(
                                builder: (_) => const HelpScreen(),
                              ),
                            ),
                            icon: const Icon(
                              Icons.help_outline_rounded,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      ModePicker(
                        selected: _config.gameMode,
                        onChanged: (mode) => setState(
                          () => _config = _config.copyWith(gameMode: mode),
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 6, child: _hero(context, wide)),
                            const SizedBox(width: 32),
                            Expanded(flex: 4, child: _settings(context)),
                          ],
                        )
                      else ...[
                        _hero(context, wide),
                        const SizedBox(height: 24),
                        _settings(context),
                      ],
                      const SizedBox(height: 34),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Eyebrow(
                                  'Escolha sua rota',
                                  color: AppColors.gold,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Jogar por continente',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                          ),
                          if (!compact)
                            const Text(
                              'Um continente. Novas descobertas.',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      LayoutBuilder(
                        builder: (context, box) {
                          final columns = box.maxWidth >= 850
                              ? 5
                              : box.maxWidth >= 580
                              ? 3
                              : 2;
                          final width =
                              (box.maxWidth - (columns - 1) * 12) / columns;
                          return Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: Continent.values
                                .map(
                                  (continent) => SizedBox(
                                    width: width,
                                    child: _continent(continent),
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      SurfaceCard(
                        padding: const EdgeInsets.all(18),
                        color: _config.continent == null
                            ? const Color(0xFF21312B)
                            : AppColors.surface,
                        child: InkWell(
                          key: const Key('world-mode'),
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => setState(
                            () => _config = _config.copyWith(world: true),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.public_rounded,
                                color: AppColors.lime,
                                size: 30,
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Jogo aleatório',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 3),
                                    Text(
                                      'Todos os continentes na mesma viagem.',
                                      style: TextStyle(
                                        color: AppColors.muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                _config.continent == null
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                color: _config.continent == null
                                    ? AppColors.lime
                                    : AppColors.muted,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 18,
                        runSpacing: 10,
                        children: [
                          Text(
                            '$count bandeiras nesta seleção',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                          const Text(
                            'Feito para aprender, uma bandeira de cada vez.',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      if (!widget.storage.isPersistent)
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text(
                            'Armazenamento indisponível: os recordes ficam apenas nesta sessão.',
                            style: TextStyle(color: AppColors.gold),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );

  Widget _hero(BuildContext context, bool wide) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Tag(
        text: 'SEU PASSAPORTE PARA O MUNDO',
        icon: Icons.explore_outlined,
      ),
      const SizedBox(height: 20),
      Text(
        'O mundo em\numa bandeira.',
        style: Theme.of(context).textTheme.headlineLarge
            ?.copyWith(fontSize: wide ? 53 : 40),
      ),
      const SizedBox(height: 16),
      const Text(
        'Reconheça países, descubra novos lugares\ne desafie seu melhor resultado.',
        style: TextStyle(color: AppColors.muted, fontSize: 15, height: 1.65),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          const Expanded(child: AtlasGlobe()),
          if (wide) const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '195',
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lime,
                ),
              ),
              Text(
                'países',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              SizedBox(height: 22),
              Text(
                '05',
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w800,
                  color: AppColors.gold,
                ),
              ),
              Text(
                'continentes',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  Widget _settings(BuildContext context) => SurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: Eyebrow('02 / Prepare a partida')),
            const Icon(Icons.tune_rounded, color: AppColors.muted, size: 19),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          _config.gameMode.label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.lime,
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _name,
          maxLength: 24,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Seu nome ou apelido',
            hintText: 'Como podemos chamar você?',
            prefixIcon: Icon(Icons.person_outline_rounded),
            counterText: '',
          ),
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
        ),
        const SizedBox(height: 23),
        const Text(
          'Tempo total do jogo',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: GameConfig.durations
              .map(
                (seconds) => ChoiceChip(
                  key: Key('duration-$seconds'),
                  label: Text(
                    GameConfig(durationSeconds: seconds).durationLabel,
                  ),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: _config.durationSeconds == seconds
                        ? AppColors.background
                        : AppColors.text,
                  ),
                  selected: _config.durationSeconds == seconds,
                  onSelected: (_) => setState(
                    () => _config = _config.copyWith(durationSeconds: seconds),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 23),
        const Text(
          'Dificuldade',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<Difficulty>(
            segments: const [
              ButtonSegment(
                value: Difficulty.easy,
                label: Text('Fácil'),
                icon: Icon(Icons.wb_sunny_outlined, size: 16),
              ),
              ButtonSegment(
                value: Difficulty.hard,
                label: Text('Difícil'),
                icon: Icon(Icons.bolt_rounded, size: 16),
              ),
            ],
            selected: {_config.difficulty},
            showSelectedIcon: false,
            onSelectionChanged: (selected) => setState(
              () => _config = _config.copyWith(difficulty: selected.first),
            ),
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _config.difficulty.description,
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
        const SizedBox(height: 23),
        const Divider(height: 1),
        const SizedBox(height: 18),
        Row(
          children: [
            const Icon(Icons.near_me_outlined, color: AppColors.gold, size: 17),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _config.regionLabel,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              'Recorde: ${widget.storage.bestFor(_config)}',
              style: const TextStyle(color: AppColors.muted, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            key: const Key('start-game'),
            onPressed: _starting ? null : _play,
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(_starting ? 'Preparando...' : 'Começar partida'),
          ),
        ),
        const SizedBox(height: 10),
        const Center(
          child: Text(
            '4 alternativas • +1 ponto por acerto',
            style: TextStyle(fontSize: 10, color: AppColors.muted),
          ),
        ),
      ],
    ),
  );

  Widget _continent(Continent continent) {
    final selected = _config.continent == continent;
    final (icon, color) = switch (continent) {
      Continent.africa => (Icons.wb_sunny_outlined, AppColors.gold),
      Continent.america => (Icons.landscape_outlined, AppColors.lime),
      Continent.asia => (
        Icons.temple_buddhist_outlined,
        const Color(0xFFF5B3C2),
      ),
      Continent.europe => (Icons.account_balance_outlined, AppColors.blue),
      Continent.oceania => (Icons.waves_rounded, const Color(0xFF8FE0D5)),
    };
    final count = widget.countries
        .forConfig(_config.copyWith(continent: continent))
        .length;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? color.withValues(alpha: 0.12) : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: selected ? color : AppColors.line),
        ),
        child: InkWell(
          key: Key('continent-${continent.id}'),
          onTap: () =>
              setState(() => _config = _config.copyWith(continent: continent)),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 27),
                    const Spacer(),
                    Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.north_east_rounded,
                      size: 16,
                      color: selected ? color : AppColors.muted,
                    ),
                  ],
                ),
                const SizedBox(height: 23),
                Text(
                  continent.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count países',
                  style: const TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

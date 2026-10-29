import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';
import 'services/country_repository.dart';
import 'services/local_storage.dart';
import 'theme/app_theme.dart';
import 'widgets/common.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FlagGameApp());
}

class FlagGameApp extends StatelessWidget {
  const FlagGameApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Flag Game · Atlas',
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: const _StartupScreen(),
  );
}

class _Dependencies {
  const _Dependencies(this.countries, this.storage);
  final CountryRepository countries;
  final LocalStorage storage;
}

class _StartupScreen extends StatefulWidget {
  const _StartupScreen();
  @override
  State<_StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<_StartupScreen> {
  late Future<_Dependencies> _future;
  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_Dependencies> _load() async {
    final countriesFuture = CountryRepository.load();
    SharedPreferences? preferences;
    try {
      preferences = await SharedPreferences.getInstance();
    } catch (_) {
      preferences = null;
    }
    return _Dependencies(await countriesFuture, LocalStorage(preferences));
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_Dependencies>(
    future: _future,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return HomeScreen(
          countries: snapshot.data!.countries,
          storage: snapshot.data!.storage,
        );
      }
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Brand(),
                const SizedBox(height: 28),
                if (snapshot.hasError) ...[
                  const Text(
                    'Não foi possível carregar o catálogo de bandeiras.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => setState(() => _future = _load()),
                    child: const Text('Tentar novamente'),
                  ),
                ] else ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 18),
                  const Text(
                    'Preparando sua próxima descoberta...',
                    style: TextStyle(color: AppColors.muted),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    },
  );
}

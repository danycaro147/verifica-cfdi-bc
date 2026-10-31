// © 2026 BrainCode México Tech. Todos los derechos reservados.
import 'package:flutter/material.dart';

import 'app_state.dart';
import 'efos.dart';
import 'home.dart';
import 'theme.dart';
import 'welcome.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState()..load();
  EfosRepo.cargar().catchError((_) => ListaEfos('', '', {}));
  runApp(VerificaApp(state: state));
}

class VerificaApp extends StatelessWidget {
  final AppState state;
  final Widget? debugHome;
  const VerificaApp({super.key, required this.state, this.debugHome});

  @override
  Widget build(BuildContext context) => AppScope(
        state: state,
        child: ListenableBuilder(
          listenable: state,
          builder: (context, _) => MaterialApp(
            title: 'Verifica CFDI',
            debugShowCheckedModeBanner: false,
            theme: buildTheme(Brightness.light),
            darkTheme: buildTheme(Brightness.dark),
            themeMode: state.themeMode,
            home: debugHome ??
                (!state.loaded
                    ? const Scaffold(body: SizedBox())
                    : state.termsAccepted
                        ? const HomeShell()
                        : const WelcomeScreen()),
          ),
        ),
      );
}

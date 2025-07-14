// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myapp/Screens/Auth/LoginScreen/login_screen.dart';
import 'package:myapp/themes.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sua inicialização de localização está perfeita.
  await initializeDateFormatting('pt_BR', null);

  // Sua inicialização do Firebase está perfeita.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meu App de Reservas',
      debugShowCheckedModeBanner: false, // Adicionado para remover o banner de debug

      // E o novo sistema de temas foi adicionado:
      theme: AppTheme.lightTheme,       // Define o tema claro padrão
      darkTheme: AppTheme.darkTheme,    // Define o tema escuro
      themeMode: ThemeMode.system,      // Deixa o sistema operacional escolher o tema

      // --- Sua configuração de localização foi mantida intacta ---
      locale: const Locale('pt', 'BR'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      // -------------------------------------------------
      home: const LoginScreen(),
    );
  }
}

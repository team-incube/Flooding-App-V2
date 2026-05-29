import 'package:flutter/material.dart';

import 'package:flooding_v2/core/config/env.dart';
import 'package:flooding_v2/core/theme/config/dark_theme.dart';
import 'package:flooding_v2/core/theme/config/light_theme.dart';
import 'package:flooding_v2/feature/auth/presentation/pages/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load();
  runApp(
    MaterialApp(
      title: 'flooding_v2',
      debugShowCheckedModeBanner: false,
      theme: LightTheme.theme,
      darkTheme: DarkTheme.theme,
      themeMode: ThemeMode.system,
      home: const AuthGate(),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flooding_v2/core/config/env.dart';
import 'package:flooding_v2/core/route/route.dart';
import 'package:flooding_v2/core/theme/config/dark_theme.dart';
import 'package:flooding_v2/core/theme/config/light_theme.dart';
import 'package:flooding_v2/feature/auth/data/datasources/token_storage.dart';
import 'package:flooding_v2/feature/auth/data/user_service.dart';
import 'package:flooding_v2/feature/auth/presentation/auth_controller.dart';
import 'package:flooding_v2/feature/auth/presentation/blocs/me_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.load();

  final tokenStorage = TokenStorage();
  late final AuthController authController;

  final userService = UserService(
    tokenStorage: tokenStorage,
    onSessionExpired: () => authController.expireSession(),
  );
  final meBloc = MeBloc(userService);

  authController = AuthController(
    meBloc: meBloc,
    sessionValidator: userService,
    tokenStorage: tokenStorage,
  );
  await authController.bootstrap();

  runApp(FloodingApp(authController: authController, meBloc: meBloc));
}

class FloodingApp extends StatefulWidget {
  const FloodingApp({
    super.key,
    required this.authController,
    required this.meBloc,
  });

  final AuthController authController;
  final MeBloc meBloc;

  @override
  State<FloodingApp> createState() => _FloodingAppState();
}

class _FloodingAppState extends State<FloodingApp> {
  late final _router = createAppRouter(widget.authController);

  @override
  void dispose() {
    _router.dispose();
    widget.authController.dispose();
    widget.meBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MeBloc>.value(
      value: widget.meBloc,
      child: MaterialApp.router(
        title: 'flooding_v2',
        debugShowCheckedModeBanner: false,
        theme: LightTheme.theme,
        darkTheme: DarkTheme.theme,
        themeMode: ThemeMode.system,
        routerConfig: _router,
      ),
    );
  }
}

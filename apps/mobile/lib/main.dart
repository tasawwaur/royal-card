import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/state/player_state.dart';
import 'routing/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0D0505),
  ));
  runApp(
    // ── Global PlayerState — real wallet & profile shared across all screens
    ChangeNotifierProvider(
      create: (_) => PlayerState(),
      child: const TeenPattiGoldApp(),
    ),
  );
}

class TeenPattiGoldApp extends StatelessWidget {
  const TeenPattiGoldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teen Patti Gold',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.luxuryDarkTheme,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}

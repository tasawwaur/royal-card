import 'package:flutter/material.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/home/home_screen.dart';
import '../features/game/andar_bahar_room.dart';
import '../features/game/teen_patti_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/wallet/wallet_screen.dart';
import '../features/leaderboard/leaderboard_screen.dart';
import '../features/rewards/rewards_screen.dart';
import '../features/social/social_screen.dart';
import '../features/store/store_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/game/game_lobby_screen.dart';

class AppRoutes {
  static const String splash      = '/';
  static const String login       = '/login';
  static const String home        = '/home';
  static const String profile     = '/profile';
  static const String wallet      = '/wallet';
  static const String gameLobby   = '/game-lobby';
  static const String teenPatti   = '/teen-patti';
  static const String andarBahar  = '/andar-bahar';
  static const String leaderboard = '/leaderboard';
  static const String rewards     = '/rewards';
  static const String social      = '/social';
  static const String store       = '/store';
  static const String settings    = '/settings';

  static Map<String, WidgetBuilder> get routes => {
    splash:      (_) => const SplashScreen(),
    login:       (_) => const LoginScreen(),
    home:        (_) => const HomeScreen(),
    profile:     (_) => const ProfileScreen(),
    wallet:      (_) => const WalletScreen(),
    gameLobby:   (_) => const GameLobbyScreen(),
    teenPatti:   (_) => const TeenPattiScreen(),
    andarBahar:  (_) => const AndarBaharRoom(),
    leaderboard: (_) => const LeaderboardScreen(),
    rewards:     (_) => const RewardsScreen(),
    social:      (_) => const SocialScreen(),
    store:       (_) => const StoreScreen(),
    settings:    (_) => const SettingsScreen(),
  };
}

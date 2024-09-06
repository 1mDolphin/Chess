import 'package:chess/screens/public_game.dart';
import 'constants.dart';
import 'firebase_options.dart';
import 'providers/game_provider.dart';
import 'providers/auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_menu_screen.dart';
import 'screens/authentication/login_screen.dart';
import 'screens/authentication/sign_up_screen.dart';
import 'screens/game_screen.dart';
import 'screens/invite_friend_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
      ],
      child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'CHESS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 9, 60, 94),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(167, 9, 60, 94),
        ),
        useMaterial3: true,
      ),
      initialRoute: Constants.loginScreen,
      routes: {
        Constants.mainMenuScreen: (context) => const MainMenuScreen(),
        Constants.gameScreen: (context) =>  const GameScreen(),
        Constants.loginScreen: (context) => const LoginScreen(),
        Constants.signUpScreen: (context) => const SignUpScreen(),
        Constants.publicGame: (context) => const PublicGame(),
        Constants.inviteScreen: (context) => const InviteScreen(),
      },
    );
  }
}

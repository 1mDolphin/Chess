import 'package:chess/providers/game_provider.dart';
import 'package:chess/screens/game_screen.dart';
import 'package:chess/screens/invite_friend_screen.dart';
import 'package:chess/screens/public_game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen ({super.key});

  @override
  State<MainMenuScreen > createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  Widget build(BuildContext context) {
    final gameProvider = context.read<GameProvider>();


    return Scaffold(
      appBar: AppBar(
         title: const Text(
          "CHESS",
          style: TextStyle(
            color: Color.fromARGB(255, 226, 224, 224),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildGameType(
              label: 'Play vs AI',
              icon: Icons.computer,
              onTap: () {
                gameProvider.setVsComputer(value: true);
                Navigator.push(context,
                MaterialPageRoute(builder: (context) => const GameScreen()),
                );
              },
              iconColor: const Color.fromARGB(255, 213, 111, 56),
              textColor: const Color.fromARGB(255, 144, 128, 104),
            ),
            buildGameType(
              label: 'Play vs Friend',
              icon: Icons.handshake,
              onTap: () {
                gameProvider.setVsComputer(value: false);
                Navigator.push(context,
                MaterialPageRoute(builder: (context) => const InviteScreen(),),
                );
              },
              iconColor: const Color.fromARGB(255, 213, 111, 56),
              textColor: const Color.fromARGB(255, 144, 128, 104),
            ),
            buildGameType(
              label: 'Join a public game',
              icon: Icons.person,
              onTap: () {
                Navigator.push(context,
                MaterialPageRoute(builder: (context) => const PublicGame(),),
                );
              },
              iconColor: const Color.fromARGB(255, 213, 111, 56),
              textColor: const Color.fromARGB(255, 144, 128, 104),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildGameType({
  required String label,
  required IconData icon,
  required Function() onTap,
  Color? iconColor,
  Color? textColor,
}) {
  return Padding(
   padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 8.0),
    child: Card(
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 50,
                color: iconColor,
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

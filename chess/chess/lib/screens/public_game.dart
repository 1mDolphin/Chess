import 'package:chess/constants.dart';
import 'package:chess/providers/auth_provider.dart';
import 'package:chess/providers/game_provider.dart';
import 'package:chess/widgets/widgets.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class PublicGame extends StatefulWidget {
  const PublicGame({
    super.key,
  });

  @override
  State<PublicGame> createState() => _PublicGame();
}

class _PublicGame extends State<PublicGame> {
  PlayerColor playerColorGroup = PlayerColor.white;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Game'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 1,
                  child: PlayerColorButton(
                    title: 'Play as ${PlayerColor.white.name}',
                    value: PlayerColor.white,
                    groupValue: gameProvider.playerColor,
                    onChanged: (value) {
                      gameProvider.setPlayerColor(player: 0); // Pass the value
                    },
                  ),
                ),
                const SizedBox(height: 10),

                    SizedBox(
                      width: MediaQuery.of(context).size.width * 1,
                      child: PlayerColorButton(
                        title: 'Play as ${PlayerColor.black.name}',
                        value: PlayerColor.black,
                        groupValue: gameProvider.playerColor,
                        onChanged: (value) {
                          gameProvider.setPlayerColor(player: 1); // Pass the value
                        },
                      ),
                    ),

                const SizedBox(height: 20),
                gameProvider.isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: () {
                    // Navigate to game screen
                    playGame(gameProvider: gameProvider);
                  },
                  child: const Text('Play'),
                ),
                const SizedBox(height: 20),
                gameProvider.vsComputer
                    ? const SizedBox.shrink()
                    : Text(gameProvider.waitingText),
              ],
            ),
          );
        },
      ),
    );
  }


  void playGame({
    required GameProvider gameProvider,
  }) async {
    final userModel = context.read<AuthenticationProvider>().userModel;

    gameProvider.setIsLoading(value: true);


    gameProvider.searchPlayer(
      userModel: userModel!,
      onSuccess: () {
        if (gameProvider.waitingText == Constants.searchingPlayerText) {
          gameProvider.checkIfOpponentJoined(
            userModel: userModel,
            onSuccess: () {
              gameProvider.setIsLoading(value: false);
              Navigator.pushNamed(context, Constants.gameScreen);
            },
          );
        } else {
          gameProvider.setIsLoading(value: false);
          Navigator.pushNamed(context, Constants.gameScreen);
        }
      },
      onFail: (error) {
        gameProvider.setIsLoading(value: false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error))
        );
      },
    );
  }

}
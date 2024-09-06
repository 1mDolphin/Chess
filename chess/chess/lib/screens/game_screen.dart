import 'dart:math';

import 'package:chess/constants.dart';
import 'package:chess/models/user_model.dart';
import 'package:chess/providers/auth_provider.dart';
import 'package:chess/providers/game_provider.dart';
import 'package:chess/service/assets_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:squares/squares.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    final gameProvider = context.read<GameProvider>();
    gameProvider.resetGame(newGame: false);

    if (mounted) {
      letOtherPlayerPlayFirst();
    }

    super.initState();
  }

  Widget showOpponentsData({
    required GameProvider gameProvider,
    required UserModel userModel,
  }) {
    if (gameProvider.vsComputer) {
      return ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage(AssetsManager.aiIcon),
        ),
        title: const Text('AI'),
      );
    } else {
      String opponentName;

      if (userModel.uid == gameProvider.gameCreatorUid) {
        opponentName = 'Denis';
      } else {
        opponentName = 'Iryna';

      }

      return ListTile(
        leading: CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage(AssetsManager.userIcon1),
        ),
        title: Text(opponentName),
      );
    }
  }

  void letOtherPlayerPlayFirst() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final gameProvider = context.read<GameProvider>();

      if (gameProvider.vsComputer) {
        if (gameProvider.state.state == PlayState.theirTurn &&
            !gameProvider.aiThinking) {
          gameProvider.setAiThinking(true);

          await waitUntilReady();
        }
      } else {
        final userModel = context.read<AuthenticationProvider>().userModel;
        gameProvider.listenForGameChanges(
            context: context, userModel: userModel!);
      }
    });
  }

  void _onMove(Move move) async {
    final gameProvider = context.read<GameProvider>();
    bool result = gameProvider.makeSquaresMove(move);
    if (result) {
      gameProvider.setSquaresState().whenComplete(() async {
        if (gameProvider.player == Squares.white) {
          if (!gameProvider.vsComputer) {
            await gameProvider.playMoveAndSaveToFireStore(
              context: context,
              move: move,
              isWhitesMove: true,
            );
          }
        } else {
          if (!gameProvider.vsComputer) {
            await gameProvider.playMoveAndSaveToFireStore(
              context: context,
              move: move,
              isWhitesMove: false,
            );
          }
        }
      });
    }

    if (gameProvider.vsComputer) {
      if (gameProvider.state.state == PlayState.theirTurn &&
          !gameProvider.aiThinking) {
        gameProvider.setAiThinking(true);

        await Future.delayed(
            Duration(milliseconds: Random().nextInt(4750) + 250));
        gameProvider.game.makeRandomMove();
        gameProvider.setAiThinking(false);
        gameProvider.setSquaresState();
      }
    }

    await Future.delayed(const Duration(seconds: 1));
    checkGameOverListener();
  }

  Future<void> waitUntilReady() async {
    {
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  Future<void> _deleteRunningGame(GameProvider gameProvider) async {
    try {
      gameProvider.resetGameData();

      await FirebaseFirestore.instance
          .collection(Constants.runningGames)
          .doc(gameProvider.gameId)
          .delete();
    } catch (e) {
      print('Error deleting running game: $e');
    }
  }

  void checkGameOverListener() {
    final gameProvider = context.read<GameProvider>();

    gameProvider.gameOverListerner(
      context: context,
      onNewGame: () {
        gameProvider.resetGame(newGame: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userModel = context.read<AuthenticationProvider>().userModel;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final gameProvider = context.read<GameProvider>();
            _deleteRunningGame(gameProvider);
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "CHESS",
          style: TextStyle(
            color: Color.fromARGB(255, 226, 224, 224),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          return Column(
            children: [
              gameProvider.vsComputer
                  ? ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage(AssetsManager.aiIcon),
                      ),
                      title: const Text('AI'),
                    )
                  : showOpponentsData(
                      gameProvider: gameProvider,
                      userModel: userModel!,
                    ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: BoardController(
                  state: gameProvider.flipBoard
                      ? gameProvider.state.board.flipped()
                      : gameProvider.state.board,
                  playState: gameProvider.state.state,
                  pieceSet: PieceSet.merida(),
                  theme: BoardTheme.brown,
                  moves: gameProvider.state.moves,
                  onMove: _onMove,
                  onPremove: _onMove,
                  markerTheme: MarkerTheme(
                    empty: MarkerTheme.dot,
                    piece: MarkerTheme.corners(),
                  ),
                  promotionBehaviour: PromotionBehaviour.autoPremove,
                ),
              ),
              ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage(AssetsManager.userIcon1),
                ),
                title: Text(userModel!.name),
              ),
              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: () {
                  gameProvider.resetGame(newGame: false);
                  Navigator.pop(context);
                },
                child: const Text('Restart'),
              ),
              OutlinedButton(
                onPressed: () async {
                  await _deleteRunningGame(gameProvider);
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(
                      context, Constants.mainMenuScreen);
                },
                child: const Text('Exit'),
              ),
            ],
          );
        },
      ),
    );
  }
}

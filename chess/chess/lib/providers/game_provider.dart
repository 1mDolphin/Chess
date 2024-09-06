import 'dart:async';
import 'package:chess/constants.dart';
import 'package:chess/main.dart';
import 'package:chess/models/game_model.dart';
import 'package:chess/models/user_model.dart';
import 'package:chess/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:squares/squares.dart';
import 'package:bishop/bishop.dart' as bishop;
import 'package:square_bishop/square_bishop.dart';
import 'package:uuid/uuid.dart';

class GameProvider extends ChangeNotifier {
  late bishop.Game _game =
      bishop.Game(variant: bishop.Variant.standard());
  late SquaresState _state = SquaresState.initial(0);
  bool _aiThinking = false;
  bool _flipBoard = false;
  bool _vsComputer = false;
  bool _isLoading = false;
  int _player = Squares.white;
  PlayerColor _playerColor = PlayerColor.white;
  String _gameId = '';

  String get gameId => _gameId;

  bishop.Game get game => _game;

  SquaresState get state => _state;

  bool get aiThinking => _aiThinking;

  bool get flipBoard => _flipBoard;

  int get player => _player;

  PlayerColor get playerColor => _playerColor;

  bool get vsComputer => _vsComputer;

  bool get isLoading => _isLoading;

  final FirebaseFirestore firebaseFirestore =
      FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  getPositionFen() {
    return game.fen;
  }

  void resetGame({required bool newGame}) {
    if (newGame) {
      if (_player == Squares.white) {
        _player = Squares.black;
      } else {
        _player = Squares.white;
      }
      notifyListeners();
    }

    _game = bishop.Game(variant: bishop.Variant.standard());
    _state = game.squaresState(_player);
  }

  bool makeSquaresMove(Move move) {
    bool result = game.makeSquaresMove(move);
    notifyListeners();
    return result;
  }

  bool makeStringMove(String bestMove) {
    bool result = game.makeMoveString(bestMove);
    notifyListeners();
    return result;
  }

  Future<void> setSquaresState() async {
    _state = game.squaresState(player);
    notifyListeners();
  }

  void makeRandomMove() {
    _game.makeRandomMove();
    notifyListeners();
  }

  void flipTheBoard() {
    _flipBoard = !_flipBoard;
    notifyListeners();
  }

  void setAiThinking(bool value) {
    _aiThinking = value;
    notifyListeners();
  }

  // set vs computer
  void setVsComputer({required bool value}) {
    _vsComputer = value;
    notifyListeners();
  }

  void setIsLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  void setGameId(String id) {
    _gameId = id;
    notifyListeners();
  }

  void setPlayerColor({required int player}) {
    _player = player;
    _playerColor = player == Squares.white
        ? PlayerColor.white
        : PlayerColor.black;
    notifyListeners();
  }

  void gameOverListerner({
    required BuildContext context,
    required Function onNewGame,
  }) {
    if (game.gameOver) {
      if (gameStreamSubScription != null) {
        gameStreamSubScription!.cancel();
      }

      if (context.mounted) {
        gameOverDialog(
          context: context,
          onNewGame: onNewGame,
        );
      }

      updateGameOverStatus();
    }
  }

  void updateGameOverStatus() async {
    try {
      await firebaseFirestore
          .collection(Constants.runningGames)
          .doc(gameId)
          .collection(Constants.game)
          .doc(gameId)
          .update({
        Constants.isGameOver: true,
        Constants.winnerId: game.winner == 0 ? gameCreatorUid : userId,
      });
    } catch (e) {
      print('Error updating game over status: $e');
    }
  }

  void gameOverDialog({
    required BuildContext context,
    required Function onNewGame,
  }) {
    String resultToShow = '';
    if (game.winner == 0) {
      resultToShow = 'White wins';
    } else if (game.winner == 1) {
      resultToShow = 'Black wins';
    } else if (game.stalemate) {
      resultToShow = 'Ups! Stalemate!';
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: Text(
                'Game Over \n $resultToShow',
                textAlign: TextAlign.center,
              ),
              content: Text(
                resultToShow,
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    resetGameData();
                    Navigator.pop(context);

                    Navigator.pushNamed(context, Constants.mainMenuScreen);
                  },
                  child: const Text(
                    'Close',
                    style: TextStyle(
                        color: Color.fromARGB(255, 163, 158, 158)),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    onNewGame();
                  },
                  child: const Text(
                    'New game',
                    style: TextStyle(
                        color: Color.fromARGB(255, 82, 151, 255)),
                  ),
                ),
              ],
            ));
  }

  String _waitingText = '';

  String get waitingText => _waitingText;

  setWaitingText() {
    _waitingText = '';
    notifyListeners();
  }

  Future searchPlayer({
    required UserModel userModel,
    required Function() onSuccess,
    required Function(String) onFail,
  }) async {
    try {
      final availableGames = await firebaseFirestore
          .collection(Constants.availableGames)
          .get();

      if (availableGames.docs.isNotEmpty) {
        final List<DocumentSnapshot> gamesList = availableGames.docs
            .where((element) => element[Constants.isPlaying] == false)
            .toList();

        if (gamesList.isEmpty) {
          _waitingText = Constants.searchingPlayerText;
          notifyListeners();

          createNewGameInFireStore(
            userModel: userModel,
            onSuccess: onSuccess,
            onFail: onFail,
          );
        } else {
          _waitingText = Constants.joiningGameText;
          notifyListeners();

          final selectedGame = gamesList.first;
          final selectedGameId = selectedGame[Constants.gameId] as String?;


          if (selectedGameId == null || selectedGameId.isEmpty) {
            onFail("Invalid game ID");
            return;
          }

          joinGame(
            game: selectedGame,
            gameId: selectedGameId,
            userModel: userModel,
            onSuccess: onSuccess,
            onFail: onFail,

          );
        }
      } else {
        _waitingText = Constants.searchingPlayerText;
        notifyListeners();

        createNewGameInFireStore(
          userModel: userModel,
          onSuccess: onSuccess,
          onFail: onFail,
        );
      }
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      onFail(e.toString());
    }
  }

  void createNewGameInFireStore({
    required UserModel userModel,
    required Function onSuccess,
    required Function(String) onFail,
  }) async {
    _gameId = const Uuid().v4();
    notifyListeners();


    try {
      await firebaseFirestore
          .collection(Constants.availableGames)
          .doc(userModel.uid)
          .set({
        Constants.uid: '',
        Constants.name: '',
        Constants.gameCreatorUid: userModel.uid,
        Constants.gameCreatorName: userModel.name,
        Constants.isPlaying: false,
        Constants.gameId: _gameId,
        Constants.dateCreated:
            DateTime.now().microsecondsSinceEpoch.toString(),
      });



      listenForInvitations(userModel);
      onSuccess();
    } on FirebaseException catch (e) {
      onFail(e.toString());
    }
  }

  String _gameCreatorUid = '';
  String _gameCreatorName = '';
  String _userId = '';
  String _userName = '';

  String get gameCreatorUid => _gameCreatorUid;

  String get gameCreatorName => _gameCreatorName;

  String get userId => _userId;

  String get userName => _userName;

  Future<void> joinGame({
    required String gameId,
    required DocumentSnapshot<Object?> game,
    required UserModel userModel,
    required Function() onSuccess,
    required Function(String) onFail,
  }) async {
    try {


      if (gameId.isEmpty) {
        onFail("Game ID is empty");
        return;
      }

      final myGame = await firebaseFirestore
          .collection(Constants.availableGames)
          .doc(userModel.uid)
          .get();

      _gameCreatorUid = game[Constants.gameCreatorUid];
      _gameCreatorName = game[Constants.gameCreatorName];
      _userId = userModel.uid;
      _userName = userModel.name;
      _gameId = game[Constants.gameId];
      notifyListeners();

      if (myGame.exists) {
        await myGame.reference.delete();
      }

      final gameModel = GameModel(
        gameId: gameId,
        gameCreatorUid: _gameCreatorUid,
        userId: userId,
        positionFen: getPositionFen(),
        winnerId: '',
        whitsCurrentMove: '',
        blacksCurrentMove: '',
        boardState: state.board.flipped().toString(),
        playState: PlayState.ourTurn.name.toString(),
        isWhitesTurn: true,
        isGameOver: false,
        pendingStatus: Constants.acceptedStatus,
        squareState: state.player,
        moves: state.moves.toList(),
      );

      await firebaseFirestore
          .collection(Constants.runningGames)
          .doc(gameId)
          .collection(Constants.game)
          .doc(gameId)
          .set(gameModel.toMap());

      await firebaseFirestore
          .collection(Constants.runningGames)
          .doc(gameId)
          .set({
        Constants.gameCreatorUid: gameCreatorUid,
        Constants.gameCreatorName: gameCreatorName,
        Constants.userId: userId,
        Constants.userName: userName,
        Constants.isPlaying: true,
        Constants.dateCreated:
            DateTime.now().microsecondsSinceEpoch.toString(),
      });

      _gameId = gameId;
      setPlayerColor(player: 0);
      notifyListeners();

      await setGameDataAndSettings(game: game, userModel: userModel);

      onSuccess();
    } on FirebaseException catch (e) {
      onFail(e.toString());
    }
  }

  StreamSubscription? isPlayingStreamSubSubscription;
  StreamSubscription<QuerySnapshot>? _invitationListener;

  void listenForInvitations(UserModel currentUser) {
    _invitationListener?.cancel();

    FirebaseFirestore.instance
        .collection(Constants.availableGames)
        .where(Constants.userId, isEqualTo: currentUser.uid)
        .where(Constants.pendingStatus,
            isEqualTo: Constants.waitingStatus)
        .snapshots()
        .listen(
      (snapshot) {
        for (var doc in snapshot.docs) {
          _showInvitationDialog(doc);
        }
      },
    );
  }

  void _showInvitationDialog(DocumentSnapshot invitation) {
    showDialog(
      context: MyApp.navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
        title: const Text('Game Invitation'),
        content: Text(
            '${invitation[Constants.gameCreatorName]} has invited you to play.'),
        actions: [
          TextButton(
            onPressed: () =>
                _respondToInvitation(invitation, false, context),
            child: const Text('Decline'),
          ),
          TextButton(
            onPressed: () =>
                _respondToInvitation(invitation, true, context),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _invitationListener?.cancel();
    super.dispose();
  }

  void checkIfOpponentJoined({
    required UserModel userModel,
    required Function() onSuccess,
  }) async {
    isPlayingStreamSubSubscription = firebaseFirestore
        .collection(Constants.availableGames)
        .doc(userModel.uid)
        .snapshots()
        .listen((event) async {
      if (event.exists) {
        final DocumentSnapshot game = event;

        if (game[Constants.isPlaying]) {
          isPlayingStreamSubSubscription!.cancel();
          await Future.delayed(const Duration(milliseconds: 100));
          _gameCreatorUid = game[Constants.gameCreatorUid];
          _gameCreatorName = game[Constants.gameCreatorName];
          _userId = game[Constants.uid] ?? userModel.uid;  // Use uid if userId doesn't exist
          _userName = game[Constants.name] ?? userModel.name;

          setPlayerColor(player: 0);
          notifyListeners();

          onSuccess();
          navigateToGameScreen();
        }
      }
    });
  }

  void checkIfOpponentJoinedToPrivateGame({
    required UserModel userModel,
    required Function() onSuccess,
  }) async {
    isPlayingStreamSubSubscription = firebaseFirestore
        .collection(Constants.availableGames)
        .doc(userModel.uid)
        .snapshots()
        .listen((event) async {
      if (event.exists) {
        final DocumentSnapshot game = event;

        if (game[Constants.isPlaying]) {
          isPlayingStreamSubSubscription!.cancel();
          await Future.delayed(const Duration(milliseconds: 100));
          _gameCreatorUid = game[Constants.gameCreatorUid];
          _gameCreatorName = game[Constants.gameCreatorName];
          _userId = game[Constants.userId];
          _userName = game[Constants.userName];

          setPlayerColor(player: 0);
          notifyListeners();

          onSuccess();
          navigateToGameScreen();
        }
      }
    });
  }

  void _respondToInvitation(DocumentSnapshot invitation,
      bool accepted, BuildContext context) async {
    if (accepted) {
      try {
        UserModel currentUser = Provider.of<AuthenticationProvider>(
            MyApp.navigatorKey.currentContext!,
            listen: false)
            .userModel!;

        await invitation.reference.update({
          Constants.pendingStatus: Constants.acceptedStatus,
          Constants.isPlaying: true,
        });

        final gameId = invitation[Constants.gameId] as String;
        await joinGame(
          gameId: gameId,
          game: invitation,
          userModel: currentUser,
          onSuccess: () {
            Navigator.of(context).pop();
            navigateToGameScreen();
          },
          onFail: (error) {
            ScaffoldMessenger.of(MyApp.navigatorKey.currentContext!)
                .showSnackBar(
              SnackBar(content: Text('Failed to join game: $error')),
            );
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(MyApp.navigatorKey.currentContext!)
            .showSnackBar(
          SnackBar(content: Text('Failed to join game: $e')),
        );
      }
    } else {
      try {
        await invitation.reference.update({
          Constants.pendingStatus: Constants.declinedStatus,
        });
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(MyApp.navigatorKey.currentContext!)
            .showSnackBar(
          SnackBar(content: Text('Failed to decline invitation: $e')),
        );
      }
    }
  }


  void navigateToGameScreen() {
    Navigator.pushReplacementNamed(
        MyApp.navigatorKey.currentContext!, Constants.gameScreen);
  }

  Future<void> setGameDataAndSettings({
    required DocumentSnapshot<Object?> game,
    required UserModel userModel,
  }) async {
    final opponentsGame = firebaseFirestore
        .collection(Constants.availableGames)
        .doc(game[Constants.gameCreatorUid]);

    await opponentsGame.update({
      Constants.isPlaying: true,
      Constants.uid: userModel.uid,
      Constants.name: userModel.name,
    });

    setPlayerColor(player: 1);
    notifyListeners();
  }

  bool _isWhitesTurn = true;
  String blacksMove = '';
  String whitesMove = '';

  bool get isWhitesTurn => _isWhitesTurn;

  StreamSubscription? gameStreamSubScription;

  Future<void> listenForGameChanges({
    required BuildContext context,
    required UserModel userModel,
  }) async {

    CollectionReference gameCollectionReference = firebaseFirestore
        .collection(Constants.runningGames)
        .doc(gameId)
        .collection(Constants.game);

    gameStreamSubScription = gameCollectionReference.snapshots().listen((event) {
      if (event.docs.isNotEmpty) {
        final DocumentSnapshot game = event.docs.first;

        if (game[Constants.isGameOver] == true) {
          gameOverDialog(
            context: context,
            onNewGame: () {
              // Handle new game logic
            },
          );
          return;
        }

        if (game[Constants.gameCreatorUid] == userModel.uid) {
          if (game[Constants.isWhitesTurn]) {
            _isWhitesTurn = true;

            if (game[Constants.blacksCurrentMove] != blacksMove) {
              try {
                Move convertedMove = convertMoveStringToMove(
                  moveString: game[Constants.blacksCurrentMove],
                );

                bool result = makeSquaresMove(convertedMove);
                if (result) {
                  setSquaresState().whenComplete(() {
                    gameOverListerner(context: context, onNewGame: () {});
                  });
                }
              } catch (e) {
                print('Error processing move: $e');
              }
            }
            notifyListeners();
          }
        } else {
          _isWhitesTurn = false;

          if (game[Constants.whitsCurrentMove] != whitesMove) {
            try {
              Move convertedMove = convertMoveStringToMove(
                moveString: game[Constants.whitsCurrentMove],
              );
              bool result = makeSquaresMove(convertedMove);

              if (result) {
                setSquaresState().whenComplete(() {
                  gameOverListerner(context: context, onNewGame: () {});
                });
              }
            } catch (e) {
              print('Error processing move: $e');
            }
          }
          notifyListeners();
        }
      }
    });
  }

  void resetGameData() {
    _playerColor = PlayerColor.white; // Reset to default player color
    _game = bishop.Game(variant: bishop.Variant.standard()); // Reset the game
    _state = SquaresState.initial(Squares.white); // Reset the squares state
    notifyListeners(); // Notify UI to update if necessary
  }


  Move convertMoveStringToMove({required String moveString}) {
    List<String> parts = moveString.split('-');

    int from = int.parse(parts[0]);
    int to = int.parse(parts[1].split('[')[0]);

    String? promo;
    String? piece;
    if (moveString.contains('[')) {
      String extras = moveString.split('[')[1].split(']')[0];
      List<String> extraList = extras.split(',');
      promo = extraList[0];
      if (extraList.length > 1) {
        piece = extraList[1];
      }
    }

    return Move(
      from: from,
      to: to,
      promo: promo,
      piece: piece,
    );
  }

  Future<void> playMoveAndSaveToFireStore({
    required BuildContext context,
    required Move move,
    required bool isWhitesMove,
  }) async {
    if (isWhitesMove) {
      await firebaseFirestore
          .collection(Constants.runningGames)
          .doc(gameId)
          .collection(Constants.game)
          .doc(gameId)
          .update({
        Constants.positionFen: getPositionFen(),
        Constants.whitsCurrentMove: move.toString(),
        Constants.moves: FieldValue.arrayUnion([move.toString()]),
        Constants.isWhitesTurn: false,
        Constants.playState: PlayState.theirTurn.name.toString(),
      });

      Future.delayed(const Duration(milliseconds: 100));
    } else {
      await firebaseFirestore
          .collection(Constants.runningGames)
          .doc(gameId)
          .collection(Constants.game)
          .doc(gameId)
          .update({
        Constants.positionFen: getPositionFen(),
        Constants.blacksCurrentMove: move.toString(),
        Constants.moves: FieldValue.arrayUnion([move.toString()]),
        Constants.isWhitesTurn: true,
        Constants.playState: PlayState.ourTurn.name.toString(),
      });

      Future.delayed(const Duration(milliseconds: 100));
    }
  }
}

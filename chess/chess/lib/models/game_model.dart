import 'package:chess/constants.dart';
import 'package:squares/squares.dart';

class GameModel {
  String gameId;
  String gameCreatorUid;
  String userId;
  String positionFen;
  String winnerId;
  String whitsCurrentMove;
  String blacksCurrentMove;
  String boardState;
  String playState;
  bool isWhitesTurn;
  bool isGameOver;
  String pendingStatus;
  int squareState;
  List<Move> moves;

  GameModel({
    required this.gameId,
    required this.gameCreatorUid,
    required this.userId,
    required this.positionFen,
    required this.winnerId,
    required this.whitsCurrentMove,
    required this.blacksCurrentMove,
    required this.boardState,
    required this.playState,
    required this.isWhitesTurn,
    required this.isGameOver,
    required this.pendingStatus,
    required this.squareState,
    required this.moves,
  });

  Map<String, dynamic> toMap() {
    return {
      Constants.gameId: gameId,
      Constants.gameCreatorUid: gameCreatorUid,
      Constants.userId: userId,
      Constants.positionFen: positionFen,
      Constants.winnerId: winnerId,
      Constants.whitsCurrentMove: whitsCurrentMove,
      Constants.blacksCurrentMove: blacksCurrentMove,
      Constants.boardState: boardState,
      Constants.playState: playState,
      Constants.isWhitesTurn: isWhitesTurn,
      Constants.isGameOver: isGameOver,
      Constants.pendingStatus: pendingStatus,
      Constants.squareState: squareState,
      Constants.moves: moves,
    };
  }

  factory GameModel.fromMap(Map<String, dynamic> map) {
    return GameModel(
      gameId: map[Constants.gameId] ?? '',
      gameCreatorUid: map[Constants.gameCreatorUid] ?? '',
      userId: map[Constants.userId] ?? '',
      positionFen: map[Constants.positionFen] ?? '',
      winnerId: map[Constants.winnerId] ?? '',
      whitsCurrentMove: map[Constants.whitsCurrentMove] ?? '',
      blacksCurrentMove: map[Constants.blacksCurrentMove] ?? '',
      boardState: map[Constants.boardState] ?? '',
      playState: map[Constants.playState] ?? '',
      isWhitesTurn: map[Constants.isWhitesTurn] ?? false,
      isGameOver: map[Constants.isGameOver] ?? false,
      pendingStatus: map[Constants.pendingStatus] ?? '',
      squareState: map[Constants.squareState] ?? 0,
      moves: List<Move>.from(map[Constants.moves] ?? []),
    );
  }
}
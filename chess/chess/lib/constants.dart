class Constants {
  static const String mainMenuScreen = '/mainMenu';
  static const String gameScreen = '/game';
  static const String loginScreen = '/login';
  static const String signUpScreen = '/signUp';
  static const String inviteScreen = '/inviteScreen';
  static const String publicGame = '/publicGame';

  static const String uid = 'uid';
  static const String name = 'name';
  static const String email = 'email';
  static const String createdAt = 'createdAt';

  static const String users = 'users';

  static const String userModel = 'userModel';
  static const String isSignedIn = 'isSingedIn';


  static const String availableGames = 'availableGames';
  static const String gameCreatorUid = 'gameCreatorUid';
  static const String gameCreatorName = 'gameCreatorName';
  static const String isPlaying = 'isPlaying';
  static const String gameId = 'gameId';
  static const String dateCreated = 'dateCreated';

  static const String pendingStatus = 'pending';
  static const String waitingStatus = 'waiting';
  static const String acceptedStatus = 'accepted';
  static const String declinedStatus = 'declined';

  static const String waitingForInviteStatus = 'waitingForInviteStatus';




  static const String userId = 'userId';
  static const String positionFen = 'positionFen';
  static const String winnerId = 'winnerId';
  static const String whitsCurrentMove = 'whitsCurrentMove';
  static const String blacksCurrentMove = 'blacksCurrentMove';
  static const String boardState = 'boardState';
  static const String playState = 'playState';
  static const String isWhitesTurn = 'isWhitesTurn';
  static const String isGameOver = 'isGameOver';
  static const String squareState = 'squareState';
  static const String moves = 'moves';

  static const String runningGames = 'runningGames';
  static const String game = 'game';

  static const String userName = 'userName';


  static const String searchingPlayerText =  'Searching for player, please wait...';
  static const String joiningGameText = 'Joining game, please wait...';
}

enum PlayerColor {
  white,
  black,
}

enum SignType {
  emailAndPassword,

}
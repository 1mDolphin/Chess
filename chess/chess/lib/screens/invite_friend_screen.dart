import 'package:chess/main.dart';
import 'package:chess/providers/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chess/providers/auth_provider.dart';
import 'package:chess/models/user_model.dart';
import 'package:chess/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class InviteScreen extends StatefulWidget {
  const InviteScreen({super.key});

  @override
  _InviteScreenState createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  late Stream<QuerySnapshot> _usersStream;

  @override
  void initState() {
    super.initState();
    final currentUser =
        Provider.of<AuthenticationProvider>(context, listen: false)
            .userModel;
    _usersStream = FirebaseFirestore.instance
        .collection(Constants.users)
        .where(Constants.uid, isNotEqualTo: currentUser!.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite Players'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            children:
                snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              UserModel user = UserModel.fromMap(data);
              return ListTile(
                title: Text(user.name),
                subtitle: Text(user.email),
                trailing: ElevatedButton(
                  onPressed: () => invitePlayer(user),
                  child: const Text('Invite'),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void invitePlayer(UserModel invitee) async {

    final currentUser =
        Provider.of<AuthenticationProvider>(context, listen: false)
            .userModel!;
    final gameProvider =
        Provider.of<GameProvider>(context, listen: false);

    gameProvider.setIsLoading(value: true);

    try {
      String gameId = const Uuid().v4();

      await FirebaseFirestore.instance
          .collection(Constants.availableGames)
          .doc(currentUser.uid)
          .set({
        Constants.gameCreatorUid: currentUser.uid,
        Constants.gameCreatorName: currentUser.name,
        Constants.userId: invitee.uid,
        Constants.userName: invitee.name,
        Constants.isPlaying: false,
        Constants.gameId: gameId,
        Constants.pendingStatus: Constants.waitingStatus,
        Constants.dateCreated:
            DateTime.now().microsecondsSinceEpoch.toString(),
      });

      gameProvider.setGameId(gameId);
      gameProvider.listenForInvitations(currentUser);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invitation sent to ${invitee.name}')),
      );

      gameProvider.checkIfOpponentJoinedToPrivateGame(
        userModel: currentUser,
        onSuccess: () async {
          await _onInvitationAccepted(
              gameId: gameId, userModel: currentUser);

          gameProvider.setIsLoading(value: false);
          Navigator.pushNamed(context, Constants.gameScreen);
        },
      );
    } catch (e) {
      gameProvider.setIsLoading(value: false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send invitation: $e')),
      );
    }
  }

  Future<void> _onInvitationAccepted({
    required String gameId,
    required UserModel userModel,
  }) async {
    try {
      final gameProvider =
          Provider.of<GameProvider>(context, listen: false);

      final DocumentSnapshot invitation = await FirebaseFirestore
          .instance
          .collection(Constants.availableGames)
          .doc(userModel.uid)
          .get();

      if (invitation.exists) {
        await gameProvider.joinGame(
          gameId: gameId,
          game: invitation,
          userModel: userModel,
          onSuccess: () async {
            await gameProvider.setGameDataAndSettings(
              game: invitation,
              userModel: userModel,
            );

            await gameProvider.listenForGameChanges(
              context: MyApp.navigatorKey.currentContext!,
              userModel: userModel,
            );
          },
          onFail: (error) {
            throw Exception('Failed to join game: $error');
          },
        );
      } else {
        throw Exception('Invitation does not exist');
      }
    } catch (e) {
      if (e is FirebaseException) {
        throw Exception('Firebase error: ${e.message}');
      } else if (e is ArgumentError) {
        print('Invalid Move instance: $e');
      } else {
        throw Exception('Error processing invitation acceptance: $e');
      }
    }
  }
}

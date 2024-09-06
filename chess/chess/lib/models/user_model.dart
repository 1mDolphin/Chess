import 'package:chess/constants.dart';


class UserModel {
  String uid;
  String name;
  String email;
  String createdAt;
  String inviteStatus;


  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
    required  this.inviteStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      Constants.uid: uid,
      Constants.name: name,
      Constants.email: email,
      Constants.createdAt: createdAt,
      Constants.pendingStatus: inviteStatus,

    };
  }

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data[Constants.uid] ?? '',
      name: data[Constants.name] ?? '',
      email: data[Constants.email] ?? '',
      createdAt: data[Constants.createdAt] ?? '',
      inviteStatus: data[Constants.pendingStatus] ?? '',
    );
  }
}
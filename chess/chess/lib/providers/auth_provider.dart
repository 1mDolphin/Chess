
import 'dart:convert';
import 'package:chess/constants.dart';
import 'package:chess/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSignedIn = false;
  String? _uid;
  UserModel? _userModel;

  // getters
  bool get isLoading => _isLoading;
  bool get isSignIn => _isSignedIn;

  UserModel? get userModel => _userModel;
  String? get uid => _uid;

  void setIsLoading({required bool value}) {
    _isLoading = value;
    notifyListeners();
  }

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  // create user with email and password
  Future<UserCredential?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    UserCredential userCredential = await firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    _uid = userCredential.user!.uid;
    notifyListeners();

    return userCredential;
  }

  // sign in user with email and password
  Future<UserCredential?> signInUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();
    UserCredential userCredential = await firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password);
    _uid = userCredential.user!.uid;
    notifyListeners();

    return userCredential;
  }

  // check if user exist
  Future<bool> checkUserExist() async {
    DocumentSnapshot documentSnapshot =
    await firebaseFirestore.collection(Constants.users).doc(uid).get();

    if (documentSnapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  // get user data from firestore
  Future getUserDataFromFireStore() async {
    await firebaseFirestore
        .collection(Constants.users)
        .doc(firebaseAuth.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      _userModel =
          UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
      _uid = _userModel!.uid;
      notifyListeners();
    });
  }

  // store user data to shared preferences
  Future saveUserDataToSharedPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(
        Constants.userModel, jsonEncode(userModel!.toMap()));
  }

  // get user data to shared preferences
  Future getUserDataToSharedPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String data = sharedPreferences.getString(Constants.userModel) ?? '';

    _userModel = UserModel.fromMap(jsonDecode(data));
    _uid = _userModel!.uid;

    notifyListeners();
  }

  // set user as signIn
  Future setSignedIn() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(Constants.isSignedIn, true);
    _isSignedIn = true;
    notifyListeners();
  }

  // set user as signIn
  Future<bool> checkIsSignedIn() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _isSignedIn = sharedPreferences.getBool(Constants.isSignedIn) ?? false;
    notifyListeners();
    return _isSignedIn;
  }

  // save user data to firestore
  void saveUserDataToFireStore({
    required UserModel currentUser,
    required Function onSuccess,
    required Function(String) onFail,
  }) async {
    try {
      currentUser.createdAt = DateTime.now().microsecondsSinceEpoch.toString();

      _userModel = currentUser;

      // save data to fireStore
      await firebaseFirestore
          .collection(Constants.users)
          .doc(uid)
          .set(currentUser.toMap());

      onSuccess();
      _isLoading = false;
      notifyListeners();
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      onFail(e.toString());
    }
  }


}
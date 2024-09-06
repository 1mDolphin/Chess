import 'package:chess/constants.dart';
import 'package:chess/providers/auth_provider.dart';
import 'package:chess/providers/game_provider.dart';
import 'package:chess/widgets/auth_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chess/service/assets_manager.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String email = email.trim();
  late String password;
  bool obscureText = true;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void signInUser() async {
    final authProvider = context.read<AuthenticationProvider>();
    final gameProvider = context.read<GameProvider>();
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      authProvider.setIsLoading(value: true);

      try {
        UserCredential? userCredential =
            await authProvider.signInUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (userCredential != null) {
          bool userExist = await authProvider.checkUserExist();

          if (userExist) {
            await authProvider.getUserDataFromFireStore();
            await authProvider.saveUserDataToSharedPref();
            await authProvider.setSignedIn();

            gameProvider
                .listenForInvitations(authProvider.userModel!);

            formKey.currentState!.reset();
            authProvider.setIsLoading(value: false);

            navigate(isSignedIn: true);
          } else {
            navigate(isSignedIn: false);
          }

          Navigator.pushNamed(context, Constants.mainMenuScreen);
        }
      } catch (e) {
        // Handle sign-in errors
        authProvider.setIsLoading(value: false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in failed: ${e.toString()}')),
        );
      }
    }
  }

  bool validateEmail(String email) {
    // Regular expression for email validation
    final RegExp emailRegex =
        RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');

    // Check if the email matches the regular expression
    return emailRegex.hasMatch(email);
  }

  navigate({required bool isSignedIn}) {
    if (isSignedIn) {
      Navigator.pushNamedAndRemoveUntil(
          context, Constants.mainMenuScreen, (route) => false);
    } else {
      // navigate to user information screen
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 9, 60, 94),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 30.0,
            vertical: 5,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 100,
                    backgroundImage:
                        AssetImage(AssetsManager.loginChessPick),
                  ),
                  const SizedBox(height: 80),
                  TextFormField(
                    decoration: textFormDecoration.copyWith(
                      labelText: "Email",

                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      value = value!.trim();
                      if (value.isEmpty) {
                        return 'Please enter your email';
                      } else if (!validateEmail(value)) {
                        return 'Please enter a valid email';
                      } else if (validateEmail(value)) {
                        return null;
                      }
                      return null;
                    },
                    onSaved: (value) {
                      email = value!.trim();
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: textFormDecoration.copyWith(
                      labelText: "Password",
                    ),
                    style: const TextStyle(color: Colors.white),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      password = value!;
                    },
                  ),
                  const SizedBox(height: 40),
                  authProvider.isLoading
                      ? const CircularProgressIndicator()
                      : AuthButton(
                          label: 'Login',
                          onPressed: signInUser,
                          fontSize: 24.0,
                        ),
                  const SizedBox(height: 60),
                  CreateAccount(
                    label: 'Don\'t have an account?',
                    labelAction: 'Create account',
                    onPressed: () {
                      Navigator.pushNamed(
                          context, Constants.signUpScreen);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const InputDecoration textFormDecoration = InputDecoration(
  border: OutlineInputBorder(),
  labelStyle: TextStyle(color: Colors.grey),
);

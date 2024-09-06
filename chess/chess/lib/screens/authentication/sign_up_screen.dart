
import 'package:chess/constants.dart';
import 'package:chess/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chess/widgets/auth_widgets.dart';
import 'package:provider/provider.dart';
import 'package:chess/providers/auth_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SingUpScreenState();
}

class _SingUpScreenState extends State<SignUpScreen> {
  late String name;
  late String email;
  late String password;
  bool obscureText = true;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();


  void popCropDialog() {
    Navigator.pop(context);
  }

  // signUp user
  void signUpUser() async {
    final authProvider = context.read<AuthenticationProvider>();
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      UserCredential? userCredential =
      await authProvider.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential != null) {

        UserModel userModel = UserModel(
          uid: userCredential.user!.uid,
          name: name,
          email: email,
          createdAt: '',
          inviteStatus: Constants.pendingStatus,
        );

        authProvider.saveUserDataToFireStore(
          currentUser: userModel,
          onSuccess: () async {
            formKey.currentState!.reset();

            Navigator.pushNamed(context, Constants.mainMenuScreen);
          },
          onFail: (error) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
          },
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 9, 60, 94),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 40.0,
            vertical: 5,
          ),
          child: SingleChildScrollView (
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Create account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(
                    height: 80,
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    maxLength: 10,
                    minLines: 1,
                    decoration: textFormDecoration.copyWith(
                        counterText: '', labelText: "Create username"),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your name';
                      } else if (value.length < 3) {
                        return 'Username must be at least 3 characters';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      name = value.trim();
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    minLines: 1,
                    decoration:
                   textFormDecoration.copyWith(labelText: "Enter your email"),
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email';
                      } else if (value.length < 3) {
                        return 'Email must be at least 3 characters';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      email = value.trim();
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.done,
                    decoration: textFormDecoration.copyWith(
                      labelText: "Create password",
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscureText = !obscureText;
                          });
                        },
                        icon: Icon(
                          obscureText ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    obscureText: obscureText,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a password';
                      } else if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      password = value;
                    },
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  AuthButton(
                      label: 'Create account',
                      onPressed: () {
                        signUpUser();
                      },
                      fontSize: 24.0
                  ),
                  const SizedBox(
                    height: 60,
                  ),
                  CreateAccount(
                    label: 'Have an account?',
                    labelAction: 'Log In',
                    onPressed: () {
                      Navigator.pop(context);
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

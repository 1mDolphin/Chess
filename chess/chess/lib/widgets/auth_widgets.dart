import 'package:flutter/material.dart';

class CreateAccount extends StatelessWidget {
  const CreateAccount ({
  super.key,
  required this.label,
  required this.labelAction,
  required this.onPressed,
  });

  final String label;
  final String labelAction;
  final Function() onPressed;
 

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            color:  Color.fromARGB(255, 176, 216, 251),
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: onPressed, 
          child: Text(
            labelAction,
            style: const TextStyle(
              color: Color.fromARGB(255, 222, 203, 147),
              fontWeight: FontWeight.bold,
              fontSize: 16
            ),
          ),
          ),
      ],
 
    );
  }
}



class AuthButton extends StatelessWidget {
  const AuthButton ({
  super.key,
  required this.label,
  required this.onPressed,
  required this.fontSize,
  });

  final String label;
  final Function() onPressed;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      color: const Color.fromARGB(255, 247, 211, 103),
      borderRadius: BorderRadius.circular(10),
      child: MaterialButton(
        onPressed: onPressed,
        minWidth: double.infinity,
        child: Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
           ),
        ),
        ),
    );
  }
}
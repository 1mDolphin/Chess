import 'package:chess/constants.dart';
import 'package:flutter/material.dart';

class PlayerColorButton extends StatelessWidget {
  const PlayerColorButton({super.key, required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,});


  final String title;
  final PlayerColor value;
  final PlayerColor? groupValue;
  final Function(PlayerColor?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<PlayerColor>(
        title: Text(title),
        value: value,
        dense: true,
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: Colors.grey[300],
        groupValue: groupValue,
        onChanged: onChanged);
  }
}

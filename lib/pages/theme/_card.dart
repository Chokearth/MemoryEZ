import 'package:flutter/material.dart';

class CardDisplay extends StatelessWidget {
  final String front;
  final String back;

  const CardDisplay({Key? key, required this.front, required this.back}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(front),
            subtitle: Text(back),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../services/auth.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Text(getUsername()),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            signOut();
          },
          child: const Text('Sign Out'),
        ),
      ],
    );
  }
}

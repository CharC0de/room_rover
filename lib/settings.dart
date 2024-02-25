import 'package:flutter/material.dart';
import 'package:room_rover/edit_user.dart';
import 'package:room_rover/user_details.dart';

class Settings extends StatelessWidget {
  const Settings({super.key, required this.userData});
  final Map userData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('User Details'),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => UserDetailsScreen(
                        userData: userData,
                      )));
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_note_outlined),
            title: const Text('Edit User'),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const EditUser()));
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:room_rover/utilities/server_util.dart';

class UserDetailsScreen extends StatelessWidget {
  final Map userData;

  const UserDetailsScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('User Details'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(size: 100, Icons.person),
                ),
                Card(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(5),
                              child: Text.rich(TextSpan(children: [
                                const TextSpan(
                                    text: "Username: ",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600)),
                                TextSpan(
                                    style: const TextStyle(fontSize: 20),
                                    text: userData['username'])
                              ]))),
                          Padding(
                              padding: const EdgeInsets.all(5),
                              child: Text.rich(TextSpan(children: [
                                const TextSpan(
                                    text: "First Name: ",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600)),
                                TextSpan(
                                    style: const TextStyle(fontSize: 20),
                                    text: userData['firstName'])
                              ]))),
                          Padding(
                              padding: const EdgeInsets.all(5),
                              child: Text.rich(TextSpan(children: [
                                const TextSpan(
                                    text: "Last Name: ",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600)),
                                TextSpan(
                                    style: const TextStyle(fontSize: 20),
                                    text: userData['lastName'])
                              ]))),
                          Padding(
                              padding: const EdgeInsets.all(5),
                              child: Text.rich(TextSpan(children: [
                                const TextSpan(
                                    text: "Email: ",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600)),
                                TextSpan(
                                    text: userRef.currentUser!.email,
                                    style: const TextStyle(fontSize: 20))
                              ]))),
                          Padding(
                              padding: const EdgeInsets.all(5),
                              child: Text.rich(TextSpan(children: [
                                const TextSpan(
                                    text: "User Type: ",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600)),
                                TextSpan(
                                    style: const TextStyle(fontSize: 20),
                                    text: userData['type'])
                              ]))),
                        ]),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

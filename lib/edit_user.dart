import 'dart:async';

import 'package:flutter/material.dart';

import 'utilities/server_util.dart';
import 'utilities/util.dart';

class EditUser extends StatefulWidget {
  const EditUser({super.key});

  @override
  State<EditUser> createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  StreamSubscription? userStream;
  getUser() {
    userStream = dbref
        .child('users/${userRef.currentUser!.uid}')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        var result = (event.snapshot.value as Map).cast<String, dynamic>();
        setState(() {
          _firstNameController.text = result['firstName'];
          _lastNameController.text = result['lastName'];
          _usernameController.text = result['username'];
        });
      }
    });
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  Map<String, dynamic> userData = {};
  bool success = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Update User Details')),
        body: SingleChildScrollView(
            child: Center(
                child: SizedBox(
                    width: MediaQuery.of(context).size.width * .75,
                    height: MediaQuery.of(context).size.height * .75,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _firstNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'First Name',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your first name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _lastNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Last Name',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your last name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              } else if (!isUsernameValidated(value)) {
                                return 'Invalid username format';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                // Form is valid, save data to formData map
                                setState(() {
                                  userData = {
                                    'firstName': _firstNameController.text,
                                    'lastName': _lastNameController.text,
                                    'username': _usernameController.text,
                                  };
                                });
                                try {
                                  dbref
                                      .child(
                                          'users/${userRef.currentUser!.uid}')
                                      .update(userData);
                                  setState(() {
                                    success = true;
                                  });
                                  var result = await dbref
                                      .child('rooms/')
                                      .orderByChild('ownerId')
                                      .equalTo(userRef.currentUser!.uid)
                                      .get();

                                  var roomData = (result.value as Map)
                                      .cast<String, dynamic>();
                                  roomData.forEach((key, value) async {
                                    await dbref.child('rooms/$key').update({
                                      'ownerName': _usernameController.text
                                    });
                                  });
                                } catch (e) {
                                  debugPrint(e.toString());
                                }

                                // You can use the formData map as needed (e.g., send it to the server)

                                debugPrint(userData.toString());
                              }
                            },
                            child: const Text('Submit'),
                          ),
                          Visibility(
                              visible: success,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  'Edit Success',
                                  style: TextStyle(color: Colors.green[700]),
                                ),
                              ))
                        ],
                      ),
                    )))));
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    userStream!.cancel();
  }
}

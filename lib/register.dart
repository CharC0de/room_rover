import 'utilities/util.dart';
import 'utilities/server_util.dart';
import 'package:flutter/material.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});
  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Map<String, dynamic> userData = {};
  Map<String, dynamic> authData = {};
  bool success = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Register')),
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
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              } else if (!isEmailValidated(value)) {
                                return 'Invalid email format';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              // Add password validation logic here if needed
                              return null;
                            },
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Confirm Password',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              } else if (value != _passwordController.text) {
                                return 'Passwords do not match';
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
                                  authData = {
                                    'email': _emailController.text,
                                    'password': _passwordController.text,
                                  };
                                  userData = {
                                    'firstName': _firstNameController.text,
                                    'lastName': _lastNameController.text,
                                    'username': _usernameController.text,
                                    'type': 'user'
                                  };
                                });
                                try {
                                  await userRef.createUserWithEmailAndPassword(
                                      email: authData['email'],
                                      password: authData['password']);
                                  await userRef.signInWithEmailAndPassword(
                                      email: authData['email'],
                                      password: authData['password']);
                                  await dbref
                                      .child(
                                          'users/${userRef.currentUser!.uid}')
                                      .set(userData);
                                  setState(() {
                                    success = true;
                                  });
                                  _formKey.currentState!.reset();
                                  _firstNameController.clear();
                                  _lastNameController.clear();
                                  _usernameController.clear();
                                  _emailController.clear();
                                  _passwordController.clear();
                                  _confirmPasswordController.clear();
                                } catch (e) {
                                  debugPrint(e.toString());
                                }

                                // You can use the formData map as needed (e.g., send it to the server)
                                debugPrint(authData.toString());
                                debugPrint(userData.toString());
                              }
                            },
                            child: const Text('Register'),
                          ),
                          Visibility(
                              visible: success,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  'Registration Success',
                                  style: TextStyle(color: Colors.green[700]),
                                ),
                              ))
                        ],
                      ),
                    )))));
  }
}

import 'package:flutter/material.dart';
import 'utilities/server_util.dart';
import 'register.dart';
import 'dashboard.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool error = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  width: 300,
                  height: 300,
                  child: Image.asset('assets/logo.png'),
                ),
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
                    }
                    // You can add additional email validation logic here
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
                    // You can add additional password validation logic here
                    return null;
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      String email = _emailController.text;
                      String password = _passwordController.text;

                      debugPrint('Email: $email, Password: $password');

                      try {
                        await userRef.signInWithEmailAndPassword(
                            email: email, password: password);
                        setState(() {
                          error = false;
                        });
                        _emailController.clear();
                        _passwordController.clear();
                        if (context.mounted) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const Dashboard()));
                        }
                      } catch (e) {
                        debugPrint(e.toString());

                        setState(() {
                          error = true;
                        });
                      }
                    }
                  },
                  child: const Text('Login'),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const RegisterForm()));
                    },
                    child: const Text('Register Here')),
                Visibility(
                    visible: error,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        'Invalid Credentials',
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ))
              ],
            ),
          ),
        ));
  }
}

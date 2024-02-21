import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:room_rover/firebase_options.dart';
import 'login.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AcadNote());
}

class AcadNote extends StatefulWidget {
  const AcadNote({super.key});

  // This widget is the root of your application.

  @override
  State<AcadNote> createState() => _AcadNoteState();
}

class _AcadNoteState extends State<AcadNote> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Room Rover',
      theme: ThemeData(colorSchemeSeed: Colors.red),
      //create a new class for this
      home: const LoginForm(),
    );
  }
}

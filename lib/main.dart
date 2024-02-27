import 'package:firebase_core/firebase_core.dart';
import 'package:fleet_map_tracker/firebase_options.dart';
import 'package:fleet_map_tracker/screens/splashscreen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.teal),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

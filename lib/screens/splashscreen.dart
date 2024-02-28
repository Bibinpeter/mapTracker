 
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fleet_map_tracker/screens/auth/loginscreen.dart';
import 'package:fleet_map_tracker/screens/mapscreen.dart';
import 'package:flutter/material.dart';
 

class SplashScreen extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const SplashScreen({Key? key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Image.asset(
              "assets/images/map_854878.png",
              height: 250,
              width: 250,
            ),
          ),
          const Text(
            "Fleet Tracker",
            style: TextStyle(
                fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      nextScreen: FirebaseAuth.instance.currentUser == null
          ? const LoginPage() 
          :  MapPage(),
      splashIconSize: 500,
      duration: 2500,
      splashTransition: SplashTransition.fadeTransition,
    );
  }
}
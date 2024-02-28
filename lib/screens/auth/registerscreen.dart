 import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fleet_map_tracker/helper/helper.dart';
import 'package:fleet_map_tracker/services/auth_service.dart';
import 'package:fleet_map_tracker/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool isloading = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String email = "";
  String password = "";
  String fullName = "";
  String profile = "";
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AuthService authService = AuthService();
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Black Opacity
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/arron-choi-KnV8G0As4QM-unsplash.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.6), // Adjust opacity as needed
          ),
          // Content
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: isloading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : SingleChildScrollView(
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Register Heading
                            Text(
                              'REGISTER',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  color: Colors.white, fontSize: 37),
                            ),
                            const SizedBox(height: 20),
                            // Username TextField
                            _buildTextField(
                              controller: _usernameController,
                              hintText: 'Username',
                              prefixIcon: Icons.person,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your username';
                                }
                                return null;
                              },
                              
                            ),
                            const SizedBox(height: 10),
                            // Email TextField
                            _buildTextField(
                              controller: _emailController,
                              hintText: 'Email',
                              prefixIcon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                } else if (!RegExp(
                                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            // Password TextField
                            _buildTextField(
                              controller: _passwordController,
                              hintText: 'Password (only numbers)',
                              prefixIcon: Icons.lock,
                              obscureText: true,
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            // Register Button
                            ElevatedButton(
                              onPressed: () async {
                                await register();
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.teal,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text('Register',
                                  style: GoogleFonts.poppins(fontSize: 18)),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,  
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      obscureText: obscureText,
      validator: (value) {
        final error = validator(value);
        if (error != null) return error;    
        return null;
      },
    );
  }

  register() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isloading = true;
      });
      await authService
          .registerUserWithEmailandPassword(_usernameController.text, _emailController.text, _passwordController.text, profile)
          .then((value) async {
        if (value == true) {
//////////////////////////////saving to shared preference///////////////////////////////
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserNameSF(fullName);
          await HelperFunctions.saveUserEmailSF(email);
          // ignore: use_build_context_synchronously
          nextScreenReplace(
              context, Page, FirebaseAuth.instance.currentUser!.uid);
        } else {
          showSnackbar(context, Colors.red, value);
          print('${e.toString()}');
          setState(() {
            isloading = false;
          });
        }
});
}
}
}
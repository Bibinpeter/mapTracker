import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fleet_map_tracker/helper/helper.dart';
import 'package:fleet_map_tracker/screens/registerscreen.dart';
import 'package:fleet_map_tracker/services/auth_service.dart';
import 'package:fleet_map_tracker/services/database_service.dart';
import 'package:fleet_map_tracker/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = "";
  String password = "";

  late Color myColor;
  late Size mediaSize;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool rememberUser = false;
  final _formKey = GlobalKey<FormState>();
  AuthService authService = AuthService();

  @override
  @override
  Widget build(BuildContext context) {
    myColor = Theme.of(context).primaryColor;
    mediaSize = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        color: myColor.withOpacity(0.6),
        image: DecorationImage(
          image: const AssetImage(
              "assets/images/arron-choi-KnV8G0As4QM-unsplash.jpg"),
          fit: BoxFit.cover,
          colorFilter:
              ColorFilter.mode(myColor.withOpacity(0.6), BlendMode.dstATop),
        ),
      ),
      child: Scaffold(
        backgroundColor:
            Colors.transparent, // Set Scaffold background color to transparent
        body: Stack(
          children: [
            Positioned(top: 80, child: _buildTop()),
            Positioned(bottom: 0, child: _buildBottom()),
          ],
        ),
      ),
    );
  }

  Widget _buildTop() {
    return SizedBox(
      width: mediaSize.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/map_854878.png', // Replace 'your_image.png' with your image asset path
            width: 100, // Adjust width as needed
            height: 100, // Adjust height as needed
          ),
          const SizedBox(
              height:
                  10), // Add some vertical spacing between the image and text
          const Text(
            "GO MAP",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 40,
                letterSpacing: 2),
          )
        ],
      ),
    );
  }

  Widget _buildBottom() {
    return SizedBox(
      width: mediaSize.width,
      child: Card(
        color:
            Colors.transparent.withOpacity(0.7), // Set the color to transparent
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Welcome",
            style: TextStyle(
                color: myColor, fontSize: 32, fontWeight: FontWeight.w500),
          ),
          _buildGreyText("Please login with your information"),
          const SizedBox(height: 60),
          _buildGreyText("Username or Email id"),
          _buildInputField(emailController, isPassword: false),
          const SizedBox(height: 40),
          _buildGreyText("Password"),
          _buildInputField(passwordController, isPassword: true),
          const SizedBox(height: 20),
          _buildRememberForgot(),
          const SizedBox(height: 20),
          _buildLoginButton(),
          const SizedBox(height: 20),
          _buildOtherLogin(),
        ],
      ),
    );
  }

  Widget _buildGreyText(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.grey),
    );
  }

  Widget _buildInputField(TextEditingController controller,
      {required bool isPassword}) {
    return TextFormField(
      style: const TextStyle(color: Colors.grey),
      cursorColor: Colors.teal,
      controller: controller,
      obscureText: isPassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter ${isPassword ? 'password' : 'email'}';
        }
        if (isPassword) {
          if (value.length < 6) {
            return 'Password must be at least 6 characters long';
          }
          // You can add more password validation here if needed
        } else {
          // This pattern checks if the email is valid
          final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailPattern.hasMatch(value)) {
            return 'Please enter a valid email';
          }
        }
        return null; // Return null if the input is valid
      },
      decoration: InputDecoration(
        suffixIcon: isPassword
            ? const Icon(
                Icons.password,
                color: Colors.white60,
              )
            : const Icon(Icons.done, color: Colors.white60),
      ),
    );
  }

  Widget _buildRememberForgot() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RegisterPage(),
                  ),
                );
              },
              child: const Text(
                "Register",
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
        TextButton(
            onPressed: () {}, child: _buildGreyText("I forgot my password"))
      ],
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () async {
        login();
      },
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
        elevation: 20,
        shadowColor: myColor,
        minimumSize: const Size.fromHeight(50),
        backgroundColor: Colors.teal,
      ),
      child: const Text("LOGIN"),
    );
  }

  Widget _buildOtherLogin() {
    return Center(
      child: Column(
        children: [
          _buildGreyText("Or Login with"),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                //  onTap: _handleGoogleSignIn,
                child: const Icon(
                  Bootstrap.google,
                  color: Colors.blueGrey,
                ),
              ),
              const Icon(
                Bootstrap.twitter,
                color: Colors.blueGrey,
              ),
              const Icon(
                Bootstrap.github,
                color: Colors.blueGrey,
              ),
            ],
          )
        ],
      ),
    );
  }

  login() async {
    if (_formKey.currentState!.validate()) {
    print('email ${emailController.text}');
    print('password ${passwordController.text}');
      await authService
          .loginWithUserNameandPassword(emailController.text, passwordController.text)
          .then((value) async {
        if (value == true) {
          QuerySnapshot snapshot =
              await DatabaseService(uid: FirebaseAuth.instance.currentUser!.uid)
                  .gettingUserData(email);
          // saving the values to our shared preferences
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserEmailSF(email);
          await HelperFunctions.saveUserNameSF(snapshot.docs[0]['email']);

          // ignore: u se_build_context_synchronously, use_build_context_synchronously
          nextScreenReplace(
              context, Page, FirebaseAuth.instance.currentUser!.uid);
        } else if (UserCredentialConstant.admin == value) {
        } else {
          showSnackbar(context, Colors.red, value);
        }
      });
    }
  }
}

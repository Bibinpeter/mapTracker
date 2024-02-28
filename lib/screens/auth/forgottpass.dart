import 'package:firebase_auth/firebase_auth.dart';
import 'package:fleet_map_tracker/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(MyApp());

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ResetPage(),
    );
  }
}

// ignore: use_key_in_widget_constructors
class ResetPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _ResetPageState createState() => _ResetPageState();
}

class _ResetPageState extends State<ResetPage> {
  final TextEditingController _emailController = TextEditingController();
    AuthService authService = AuthService();
  final formKey = GlobalKey<FormState>();
  String email = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.6),
      ),
      body: Container( 
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage(
                'assets/images/towfiqu-barbhuiya-FnA5pAzqhMM-unsplash.jpg'),  
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(
                  0.5),  
              BlendMode.dstATop,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(29),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(),
                child: Text(
                  "RESET PASSWORD",
                  style: GoogleFonts.poppins(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontSize: 42,
                      fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(
                height: 1,
              ),
              Form(
                key: formKey,
                child: Column(children: [
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                        color: Colors.white), // Set text color to white
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      labelStyle: TextStyle(
                          color: Colors.white), // Set label color to white
                      hintStyle: TextStyle(
                          color: Color.fromARGB(255, 159, 162,
                              159)), // Set hint text color to white
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white), // Set border color to white
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .white), // Set focused border color to white
                      ),
                    ),
                     onChanged: (value) {
                                  setState(() {
                                    email = value;
                                  });
                                },
                                validator: (value) {
                                  return RegExp(
                                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                          .hasMatch(value!)
                                      ? null
                                      : "Please enter a valid email";
                                },
                  ),
                ]),
              ),
              const SizedBox(height: 70),
              ElevatedButton(

                onPressed: () {
                  print(_emailController.text);
  if (formKey.currentState!.validate()) {
   FirebaseAuth.instance 
        .sendPasswordResetEmail(email: _emailController.text)
        .then((value) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Password reset email sent to ${_emailController.text}"),
            backgroundColor: Colors.green, // Success color
          ));
          // You can also navigate to another page or perform other actions here if needed
        })
        .catchError((error) {
          snackbarFunction(context, "Error: $error", Colors.redAccent);
        });
  }
},

                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      const Color.fromARGB(
                          255, 90, 87, 87)), // Set button color to green
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30.0), // Set button edge curve
                    ),
                  ),
                  minimumSize: MaterialStateProperty.all(
                      const Size(150, 50)), // Set button size
                ),
                child: const Text('Reset password ',
                    style:
                        TextStyle(fontSize: 18)), // Increase button text size
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
 void snackbarFunction(BuildContext context, String content, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(content),
    backgroundColor: color,
  ));
}
 
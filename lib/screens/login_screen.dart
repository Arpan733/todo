import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo/screens/signup_screen.dart';

import '../services/firebase_auth.dart';
import '../utils.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuthentication firebaseAuthentication =
      FirebaseAuthentication();

  late bool isVisible = true;
  late bool isLoading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final GlobalKey<FormState> key = GlobalKey<FormState>();

  void login() async {
    setState(() {
      isLoading = true;
    });

    String email = emailController.text;
    String password = passwordController.text;

    UserCredential? user = await firebaseAuthentication
        .signInWithEmailAndPassword(email, password, context);

    if (user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );

      if (kDebugMode) {
        print('User login successfully');
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        color: Colors.blueAccent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: Form(
                key: key,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 30),
                      child: Text(
                        'Login',
                        style: GoogleFonts.robotoMono(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Utils.label('Email'),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.always,
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: Colors.blueAccent,
                      cursorWidth: 3,
                      validator: (value) {
                        if (value!.isNotEmpty) {
                          return null;
                        } else {
                          return 'Enter the value';
                        }
                      },
                      style: GoogleFonts.robotoMono(
                        color: Colors.blueAccent,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Colors.blueAccent,
                        ),
                        hintText: 'Email',
                        hintStyle: GoogleFonts.robotoMono(
                          color: Colors.blueAccent,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Utils.label('Password'),
                    TextFormField(
                      autovalidateMode: AutovalidateMode.always,
                      controller: passwordController,
                      obscureText: isVisible,
                      obscuringCharacter: '*',
                      cursorColor: Colors.blueAccent,
                      cursorWidth: 3,
                      validator: (value) {
                        if (value!.isNotEmpty) {
                          return null;
                        } else {
                          return 'Enter the value';
                        }
                      },
                      style: GoogleFonts.robotoMono(
                        color: Colors.blueAccent,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.blueAccent,
                        ),
                        hintText: 'Password',
                        hintStyle: GoogleFonts.robotoMono(
                          color: Colors.blueAccent,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isVisible = !isVisible;
                            });
                          },
                          icon: Icon(
                            !isVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 150,
                      margin: const EdgeInsets.only(top: 30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextButton(
                        onPressed: () {
                          if (key.currentState != null &&
                              key.currentState!.validate()) {
                            if (!isLoading) {
                              login();
                            }
                          }
                        },
                        child: isLoading
                            ? Container(
                                height: 20,
                                width: 20,
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(
                                  color: Colors.blueAccent,
                                  value: 20,
                                ),
                              )
                            : Text(
                                'Login',
                                style: GoogleFonts.robotoMono(
                                  color: Colors.blueAccent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Don\'t have an account? Sign Up!',
                          style: GoogleFonts.robotoMono(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

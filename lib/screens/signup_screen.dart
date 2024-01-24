import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo/services/firebase_auth.dart';
import 'package:todo/services/todo_storage.dart';

import '../utils.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final FirebaseAuthentication firebaseAuthentication =
      FirebaseAuthentication();
  final ToDoStorage toDoStorage = ToDoStorage();

  late bool isVisible = true;
  late bool isLoading = false;

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final GlobalKey<FormState> key = GlobalKey<FormState>();

  void signUp() async {
    setState(() {
      isLoading = true;
    });

    String username = usernameController.text;
    String email = emailController.text;
    String password = passwordController.text;

    UserCredential? user = await firebaseAuthentication
        .signUpWithEmailAndPassword(username, email, password, context);

    if (user != null) {
      toDoStorage.makeUser(username, email, user.user!.uid, context);

      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );

      if (kDebugMode) {
        print('User successfully registered');
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    usernameController.dispose();
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
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Form(
            key: key,
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
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 30),
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.robotoMono(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Utils.label('Username'),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.always,
                        controller: usernameController,
                        keyboardType: TextInputType.name,
                        cursorColor: Colors.blueAccent,
                        cursorWidth: 3,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter the username.';
                          } else {
                            return null;
                          }
                        },
                        style: GoogleFonts.robotoMono(
                          color: Colors.blueAccent,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(
                            Icons.person_outlined,
                            color: Colors.blueAccent,
                          ),
                          hintText: 'Username',
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
                      Utils.label('Email'),
                      TextFormField(
                        autovalidateMode: AutovalidateMode.always,
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: Colors.blueAccent,
                        cursorWidth: 3,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Enter the email.';
                          } else if (!Utils.isValidEmail(value)) {
                            return 'Enter the valid email.';
                          } else {
                            return null;
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
                          if (value!.isEmpty) {
                            return 'Enter the password.';
                          } else if (value.length < 8) {
                            return 'Password length must be more than 8.';
                          } else {
                            return null;
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
                          errorStyle: GoogleFonts.robotoMono(
                            color: Colors.red.shade600,
                            fontSize: 14,
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
                                signUp();
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
                                  'Sign Up',
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
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Already have an account? Login!',
                            style: GoogleFonts.robotoMono(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

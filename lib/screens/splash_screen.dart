import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo/screens/home_screen.dart';

import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late Animation<int> animation;
  final String title = 'To Do';

  @override
  void initState() {
    // tz.initializeTimeZone();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    animation = IntTween(begin: 0, end: title.length).animate(controller);
    controller.forward();

    Future.delayed(
      const Duration(seconds: 3),
      () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              if (FirebaseAuth.instance.currentUser != null) {
                return const HomeScreen();
              } else {
                return const LoginScreen();
              }
            },
          ),
        );
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();

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
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            int currentLength = animation.value;
            String displayText = title.substring(0, currentLength);

            return Text(
              displayText,
              style: GoogleFonts.courgette(
                color: Colors.white,
                fontSize: 60,
                fontWeight: FontWeight.w800,
              ),
            );
          },
        ),
      ),
    );
  }
}

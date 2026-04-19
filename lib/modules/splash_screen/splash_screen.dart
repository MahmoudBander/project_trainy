import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_color.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  static const route = "splash";
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, OnboardingScreen.route);
    });
  }
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColor.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ZoomIn(
              duration: Duration(seconds: 2),
              child: Image.asset("assets/images/logo_img/ion_train-sharp.png"),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: FadeInUp(
              delay: Duration(seconds: 2),
              child: Image.asset("assets/images/logo_img/Trainy.png"),
            ),
          ),
        ],
      ),
    );
  }
}

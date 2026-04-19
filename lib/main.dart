import 'package:flutter/material.dart';
import 'modules/layout/data/passenger_data.dart';
import 'modules/layout/data/status.dart';
import 'modules/layout/data/veriflcation.dart';
import 'modules/layout/home.dart';
import 'modules/layout/tabs/home_tab.dart';
import 'modules/layout/tabs/subscriptions_tab.dart';
import 'modules/layout/tabs/tickts_tab.dart';
import 'modules/onboarding/onboarding_screen.dart';
import 'modules/splash_screen/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: SplashScreen.route,

      routes: {
        SplashScreen.route: (context) => SplashScreen(),
        OnboardingScreen.route: (context) => OnboardingScreen(),
        Home.route: (context) => Home(),
        HomeTab.route: (context) => HomeTab(),
        PassengerData.route: (context) => PassengerData(),
        Status.route: (context) => Status(),
        Veriflcation.route: (context) => Veriflcation(),
        SubscriptionsTab.route: (context) => SubscriptionsTab(),
        TicktsTab.route: (context) => TicktsTab(),
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:project_bander/core/notification_service.dart';
import 'modules/layout/home.dart';
import 'modules/layout/tabs/subscriptions_tab.dart';
import 'modules/layout/tabs/tickts_tab.dart';
import 'modules/onboarding/onboarding_screen.dart';
import 'modules/splash_screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
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
        SplashScreen.route:     (context) => SplashScreen(),
        OnboardingScreen.route: (context) => OnboardingScreen(),
        Home.route:             (context) => Home(),
        SubscriptionsTab.route: (context) => SubscriptionsTab(),
        TicktsTab.route:        (context) => TicktsTab(),
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'data/helpers/shared_prefs_helper.dart';
import 'presentation/screens/main_navigation.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bool isFirstTime = await SharedPrefsHelper.isFirstTime();
  final bool isLoggedIn = await SharedPrefsHelper.isLoggedIn();

  debugPrint('APP START - isLoggedIn=$isLoggedIn, isFirstTime=$isFirstTime');

  runApp(
    MyApp(
      initialScreen: isLoggedIn
          ? const MainNavigation()
          : isFirstTime
              ? const OnboardingScreen()
              : const WelcomeScreen(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sorgummi AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: initialScreen,
    );
  }
}

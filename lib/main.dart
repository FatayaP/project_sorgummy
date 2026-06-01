import 'package:flutter/material.dart';
import 'data/helpers/shared_prefs_helper.dart';
import 'presentation/screens/main_navigation.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bool isFirstTime = await SharedPrefsHelper.isFirstTime();
  final bool isLoggedIn = await SharedPrefsHelper.isLoggedIn();

  runApp(
    MyApp(
      initialScreen: isFirstTime
          ? const OnboardingScreen()
          : isLoggedIn
          ? const MainNavigation()
          : const WelcomeScreen(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({Key? key, required this.initialScreen}) : super(key: key);

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

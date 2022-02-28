import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transfero/ui/hooks/use_auth_enviroment.dart';
import 'package:transfero/ui/pages/home/home_page.dart';
import 'package:transfero/ui/pages/onboarding/onboarding_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends HookWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authState = useStream(useAuthEnviroment().state);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Transfero',
      theme: ThemeData(
        textTheme: GoogleFonts.montserratTextTheme(),
        colorScheme: const ColorScheme.light().copyWith(
          primary: const Color(0xff4553FD),
        ),
      ),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child:
            authState.data == null ? const OnboardingPage() : const HomePage(),
      ),
    );
  }
}

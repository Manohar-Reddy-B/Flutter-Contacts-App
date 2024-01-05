import 'package:call_manager_app/ui/splash.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              primary: const Color(0xFF2a37b8),
              //0xFF071d9f,0xFF0c234c,0xFF2c2b2a,0xFF063673,0xFF19294f,0xFF2a37b8
              secondary: Colors.white),
          textTheme: GoogleFonts.nunitoTextTheme()),
      home: const SafeArea(child: Splash()),
    );
  }
}

import 'package:flutter/material.dart';

class Registration extends StatelessWidget {
  const Registration({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome")),
      body: Stack(
        children: [Positioned(child: Image.asset("assets/main_top.png"))],
      ),
    );
  }
}

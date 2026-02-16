import 'package:flutter/material.dart';

class WebBackgroundPattern extends StatelessWidget {
  const WebBackgroundPattern({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF9FAFB), Color(0xFFEFF6FF)],
        ),
      ),
    );
  }
}

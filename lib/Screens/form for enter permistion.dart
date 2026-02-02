import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FormForEnterPermission extends StatelessWidget {
  const FormForEnterPermission({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildRequestforleave(),
          ]
        ),
      ),
    );
  }

  Widget _buildRequestforleave() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'សុំច្បាប់ឈប់សម្រាក', 
          style: GoogleFonts.preahvihear(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          ),
        )
      ],
    );
  }
}

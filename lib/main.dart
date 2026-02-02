import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/Screens/Top%20Employees%20show%20screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home:TopEmployeesShowScreen());
  }
}

import 'package:flutter/material.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 180,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("ច្បាប់ឈប់សម្រាក",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Color(0xFF004C4C)),),
                
                
              ],
            ),
        
          ),

        ],
      ),
      
      
    );
  }
}
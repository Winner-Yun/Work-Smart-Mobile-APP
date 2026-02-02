import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/config/appcolor.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xFFF8F9FA),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
         
        },
        label: Text(
          'សុំច្បាប់',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        icon: Icon(Icons.add, color: Colors.white),
        backgroundColor:AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding:  EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               SizedBox(height: 20),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    'ច្បាប់ឈប់សម្រាក',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding:  EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child:  Icon(Icons.notifications_none, color: Colors.black54),
                  ),
                ],
              ),
               SizedBox(height: 30),

            
              Row(
                children:  [
                  Expanded(
                    child: LeaveSummaryCard(
                      title: 'ច្បាប់ប្រចាំឆ្នាំ',
                      value: '១២',
                      icon: Icons.calendar_today_outlined,
                      iconColor: Colors.teal,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: LeaveSummaryCard(
                      title: 'ច្បាប់ឈឺ',
                      value: '០៥',
                      icon: Icons.medical_services_outlined,
                      iconColor: Colors.blue,
                    ),
                  ),
                ],
              ),
               SizedBox(height: 30),

            
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    'សំណើថ្មីៗ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {},
                    child:  Text('មើលទាំងអស់', style: TextStyle(color: Colors.teal)),
                  ),
                ],
              ),

              
               RequestListItem(
                title: 'ឈប់សម្រាកប្រចាំឆ្នាំ',
                subtitle: '២០ - ២២ តុលា ២០២៣',
                status: 'អនុម័ត',
                statusColor: Colors.green,
                icon: Icons.beach_access_outlined,
              ),
               RequestListItem(
                title: 'ច្បាប់ឈឺ (គ្រុនផ្តាសាយ)',
                subtitle: '០៥ វិច្ឆិកា ២០២៣',
                status: 'រង់ចាំ',
                statusColor: Colors.orange,
                icon: Icons.medical_services_outlined,
              ),
               RequestListItem(
                title: 'ឈប់សម្រាកផ្ទាល់ខ្លួន',
                subtitle: '១៥ តុលា ២០២៣',
                status: 'បដិសេធ',
                statusColor: Colors.red,
                icon: Icons.calendar_today_outlined,
              ),
            ],
          ),
        ),
      ),
 
    );
  }
}


class LeaveSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

   LeaveSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:  EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset:  Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding:  EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
           SizedBox(height: 12),
          Text(title, style:  TextStyle(color: Colors.grey, fontSize: 14)),
           SizedBox(height: 4),
          Row(
            children: [
              Text(
                value,
                style:  TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
               SizedBox(width: 4),
               Text('ថ្ងៃនៅសល់', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}


class RequestListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;
  final IconData icon;

   RequestListItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  EdgeInsets.only(bottom: 12),
      padding:  EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[100],
            child: Icon(icon, color: Colors.grey, size: 20),
          ),
           SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style:  TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(subtitle, style:  TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding:  EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';

class LightAdminHomepage extends StatefulWidget {
  const LightAdminHomepage({super.key});

  @override
  State<LightAdminHomepage> createState() => _LightAdminHomepageState();
}

class _LightAdminHomepageState extends State<LightAdminHomepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.menu),
            Text(
              "ការត្រួតពិនិត្យទូទៅ",
              style: TextStyle(
                fontSize: 20,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(Icons.notifications),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 15),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildSummaryCard(
                  "បុគ្គលិកសរុប",
                  "១២០",
                  Icons.people_outline,
                  AppColors.darkBg,
                ),
                _buildSummaryCard(
                  "មានវត្តមាន",
                  "៩៥",
                  Icons.check_circle_outline,
                  AppColors.primary,
                ),
                _buildSummaryCard(
                  "មកយឺត",
                  "១០",
                  Icons.access_time,
                  AppColors.secondary,
                ),
                _buildSummaryCard(
                  "អវត្តមាន",
                  "១៥",
                  Icons.cancel_outlined,
                  Colors.red,
                ),
              ],
            ),
            SizedBox( height: 15,),
            _buildchatsection(),
          ],
        ),
      ),
    );
  }
}

Widget _buildSummaryCard(
  String title,
  String count,
  IconData icon,
  Color iconColor,
) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(color: AppColors.darkBorder, fontSize: 15),
            ),
            Icon(icon, color: iconColor, size: 20),
          ],
        ),
        Text(
          count,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: iconColor == Colors.grey ? Colors.black : iconColor,
          ),
        ),
      ],
    ),
  );
}

Widget _buildchatsection() {
  return Container(
    width: double.infinity,
    height: 200,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
    ),
    child: Column(
      children: [
        Row(
          children: [
            Text(
              "ស្ថិតិវត្តមានប្រចាំថ្ងៃ",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkBorder,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

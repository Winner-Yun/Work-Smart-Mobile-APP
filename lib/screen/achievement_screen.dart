import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/config/appcolor.dart';


class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
 @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Icon(Icons.arrow_back_ios_new, color: AppColors.textGrey),
        title: Text(
          'សមិទ្ធផលរបស់ខ្ញុំ',
          style: TextStyle(
            color: AppColors.primary, 
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: AppColors.textGrey,),
            onPressed: () {},
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF9FAFB), 
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              SizedBox(height: 20),
              
              
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Color(0xFFFFD700), width: 3),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor:AppColors.background,
                          ),
                        ),
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.primary,
                          child: Icon(Icons.check, size: 16, color: Colors.white),
                        )
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'សួស្តី, សុភ័ក្រ',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                    ),
                    Text(
                      'អ្នកបម្រើការផ្នែក IT',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

            
              Row(
                children: [
                  _buildStatCard('មេដាយសរុប', '១២', Icons.emoji_events, Color(0xFFFFB300)),
                  SizedBox(width: 16),
                  _buildStatCard('ចំណាត់ថ្នាក់', '#៤', Icons.bar_chart, Color(0xFF42A5F5)),
                ],
              ),

              SizedBox(height: 40),

              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'មេដាយដែលទទួលបាន',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text('មើលទាំងអស់', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                ],
              ),
              
              SizedBox(height: 24),
              
              
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 30,
                crossAxisSpacing: 20,
                children: [
                  _buildMedal(Icons.wb_sunny_outlined, 'មកដល់មុនគេ', Color(0xFFFFB300), true),
                  _buildMedal(Icons.calendar_today_outlined, 'វត្តមានឥតចន្លោះ', Color(0xFF4DB6AC), true),
                  _buildMedal(Icons.military_tech_outlined, 'ឆ្នើមប្រចាំខែ', Color(0xFFF06292), true),
                  _buildMedal(Icons.rocket_launch_outlined, 'ល្បឿនលឿន', Color(0xFF42A5F5), true),
                  _buildMedal(Icons.handshake_outlined, 'សហការល្អ', Colors.grey, false),
                  _buildMedal(Icons.lightbulb_outline, 'គំនិតច្នៃប្រឌិត', Colors.grey, false),
                ],
              ),

              SizedBox(height: 30),

             
              _buildProgressCard(),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: Offset(0, 5)),
          ],
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: Colors.grey, fontSize: 13)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 22),
                SizedBox(width: 8),
                Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedal(IconData icon, String label, Color color, bool isActive) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? color.withOpacity(0.08) : Color(0xFFF2F2F2),
            border: Border.all(color: isActive ? color : Colors.transparent, width: 1.5),
          ),
          child: Icon(icon, color: isActive ? color : Color(0xFFD0D0D0), size: 30),
        ),
        SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12, 
            color: isActive ? Color(0xFF333333) : Colors.grey,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color:AppColors.primary, 
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.emoji_events, color: Color(0xFFFFB300)),
              ),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('គោលដៅបន្ទាប់', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('បញ្ចប់ ៥ ថ្ងៃទៀតដើម្បីបានមេដាយ \'វីរៈបុរស\'', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              Text('៨០%', style: TextStyle(color: Color(0xFFFFB300), fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('វឌ្ឍនភាព', style: TextStyle(color: Colors.white60, fontSize: 12)),
              Text('២០/២៥ ថ្ងៃ', style: TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.8,
              minHeight: 8,
              backgroundColor:AppColors.primary,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
            ),
          ),
        ],
      ),
    );
  }
}
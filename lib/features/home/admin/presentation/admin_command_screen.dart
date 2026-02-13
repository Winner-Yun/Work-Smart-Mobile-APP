import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/app/theme/theme.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';

class admincommandcenter extends StatefulWidget {
  const admincommandcenter({super.key});

  @override
  State<admincommandcenter> createState() => _admincommandcenterState();
}

class _admincommandcenterState extends State<admincommandcenter> {
@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:  EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: Icon(
                      Icons.person, 
                     color: AppColors.primary
                      ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    AppStrings.tr('admin_worksmart'),

                    style: 
                     TextStyle(
                      color: AppColors.primary,
                      fontSize: 18),
                  ),
                  Spacer(),
                   Icon(
                    Icons.notification_add, 
                    color: AppColors.primary),
                    SizedBox(width: 5),
                   Icon(
                    Icons.search, 
                    color: AppColors.primary),
                ],
              ),
            ),

            // Grid Cards
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                childAspectRatio: 1.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children:  [
                  InfoCard(
                    title: "បុគ្គលិកសរុប"
                  , value: "150"),
                  InfoCard(
                    title: "វត្តមាន",
                     value: "25"),
                  InfoCard(
                    title: "យឺត", 
                    value: "5"),
                  InfoCard(
                    title: "ច្បាប់",
                     value: "10"),
                ],
              ),
            ),

             SizedBox(height: 20),

            // Circular progress section
            Container(
              margin:  EdgeInsets.all(16),
              padding:  EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                   Text(
                    "ការវិភាគវត្តមាន",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: const [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: 0.5,
                          strokeWidth: 12,
                          color: Colors.orange,
                          backgroundColor: Colors.white12,
                        ),
                      ),
                      Text(
                        "65%",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      Text("វត្តមាន: 150", style: TextStyle(color: Colors.white70)),
                      Text("អវត្តមាន: 25", style: TextStyle(color: Colors.white70)),
                      Text("ច្បាប់: 10", style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Bottom button
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {},
                child: const Text("ចាប់ផ្តើម",
                    style: TextStyle(color: Colors.black)),
              ),
            ),

            // Bottom navigation
            BottomNavigationBar(
              backgroundColor: const Color(0xFF0B2D2D),
              selectedItemColor: Colors.orange,
              unselectedItemColor: Colors.white70,
              type: BottomNavigationBarType.fixed,
              items:  [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "ទំព័រដើម",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: "បុគ្គលិក",
                ),
                BottomNavigationBarItem(
                icon:  Icon(Icons.bar_chart),
                label: AppStrings.tr('វិភាគ'),
              ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: "ផ្សេងៗ",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;

   InfoCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style:  
            TextStyle(
             color: AppColors.lightBg,
              )
              ),
           SizedBox(height: 8),
          Text(
            value,
            style:  TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

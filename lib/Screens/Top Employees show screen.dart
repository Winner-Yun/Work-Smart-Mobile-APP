import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopEmployeesShowScreen extends StatefulWidget {
  const TopEmployeesShowScreen({super.key});

  @override
  State<TopEmployeesShowScreen> createState() => _TopEmployeesShowScreenState();
}

class _TopEmployeesShowScreenState extends State<TopEmployeesShowScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: Text(
          'ចំណាត់ថ្នាក់កំពូល',
          style: GoogleFonts.hanuman(
            color: Colors.teal,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 50),
            _buildGrand(),
            SizedBox(height: 30),
            _buildNextrank(),
            SizedBox(height: 12),
            _buildNextrank5(),
            SizedBox(height: 12),
            _buildNextrank6(),
            SizedBox(height: 12),
            _buildNextDestination(),
          ],
        ),
      ),
    );
  }

  Widget _buildGrand() {
    return Column(
      children: [
        SizedBox(
          height: 270,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _podiumBlock(
                        height: 70,
                        color: const Color(0xFFE9EDF0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _podiumBlock(
                        height: 120,
                        color: const Color(0xFFF2D9A6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _podiumBlock(
                        height: 85,
                        color: const Color(0xFFF6E7C8),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 8,
                bottom: 85,
                child: _rankAvatar(
                  name: "យុត",
                  percent: "៦៣%",
                  ringColor: const Color(0xFFBFC7CF),
                  imageProvider: const AssetImage(
                    "assets/imgs/Spicy Fried chicken.png",
                  ),
                  showCrown: false,
                ),
              ),
              Positioned(
                bottom: 130,
                child: _rankAvatar(
                  name: "តារា",
                  percent: "៩៩%",
                  ringColor: const Color(0xFFF2B544),
                  imageProvider: const AssetImage(
                    "assets/imgs/Spicy Fried chicken.png",
                  ),
                  showCrown: true,
                ),
              ),
              Positioned(
                right: 8,
                bottom: 90,
                child: _rankAvatar(
                  name: "សុភ",
                  percent: "៦៥%",
                  ringColor: const Color(0xFFF0B46D),
                  imageProvider: const AssetImage(
                    "assets/imgs/Spicy Fried chicken.png",
                  ),
                  showCrown: false,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _podiumBlock({required double height, required Color color}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: Icon(Icons.emoji_events_outlined, color: Colors.white70),
      ),
    );
  }

  Widget _rankAvatar({
    required String name,
    required String percent,
    required Color ringColor,
    required ImageProvider imageProvider,
    required bool showCrown,
  }) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: 3),
              ),
              child: CircleAvatar(
                radius: 28,
                backgroundImage: imageProvider,
                backgroundColor: Colors.white,
              ),
            ),
            if (showCrown)
              const Positioned(
                top: -18,
                child: Icon(
                  Icons.emoji_events,
                  color: Color(0xFFF2B544),
                  size: 26,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: GoogleFonts.hanuman(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          percent,
          style: GoogleFonts.hanuman(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildNextrank() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'ចំណាត់ថ្នាក់បន្ទាប់',
              style: GoogleFonts.hanuman(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              'មធ្យមភាគពិន្ទុ',
              style: GoogleFonts.hanuman(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                child: Text(
                  '4',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage(
                  'assets/imgs/Spicy Fried chicken.png',
                ),
              ),

              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'សុភ័ក្រ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ផ្នែកព័ត៍មានវិឡា',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              Column(
                children: const [
                  Text(
                    '៩២%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Icon(Icons.arrow_upward, size: 12, color: Colors.green),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNextrank5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                child: Text(
                  '5',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage(
                  'assets/imgs/Spicy Fried chicken.png',
                ),
              ),

              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'សុខា',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ផ្នែកគណនេយ្យ',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              Column(
                children: const [
                  Text(
                    '៩០%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Icon(Icons.arrow_upward, size: 12, color: Colors.green),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNextrank6() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                child: Text(
                  '6',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 24,
                backgroundImage: AssetImage(
                  'assets/imgs/Spicy Fried chicken.png',
                ),
              ),

              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'បញ្ញា',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ផ្នែករដ្ធបាល',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              Column(
                children: const [
                  Text(
                    '៨៨%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Icon(Icons.arrow_upward, size: 12, color: Colors.green),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNextDestination() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A3A),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 55, 105, 57),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color.fromARGB(255, 116, 105, 65),
                        width: 2,
                      ),
                    ),
                    child: const Icon(Icons.emoji_events, color: Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "គោលដៅបន្ទាប់",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "ឈានដល់ ៩៥% ដើម្បីទទួលបានមេដាយសំរិទ្ធ",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: const LinearProgressIndicator(
                  value: 0.95,
                  backgroundColor: Colors.white24,
                  color: Colors.orange,
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 24,
          bottom: -14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: const [
                Icon(Icons.emoji_events, size: 16, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  "សមិទ្ធិផល",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 18,
          bottom: -22,
          child: Container(
            width: 110, 
            height: 44, 
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.emoji_events, size: 16, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  "សមិទ្ធិផល",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class TelegramIntegration extends StatefulWidget {
  const TelegramIntegration({super.key});

  @override
  State<TelegramIntegration> createState() => _TelegramIntegrationState();
}

class _TelegramIntegrationState extends State<TelegramIntegration> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB), // Light background like the image
      appBar: AppBar(
        backgroundColor:  Color(0xFFF8FAFB),
        elevation: 0,
        title: const Text(
          'ការកំណត់ Telegram',
          style: TextStyle(
            fontSize: 20,
            color: Color(0xFF004C4C),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            // 1. Telegram Icon (Added a stack for the checkmark)
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: const Icon(Icons.send, size: 60, color: Colors.white),
                  ),
                  const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.check_circle, color: Colors.green, size: 22),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'ភ្ជាប់ជាមួយ Telegram',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color: Color(0xFF004C4C) ),
            ),
            const SizedBox(height: 10),
            const Text(
              'ទទួលបានការជូនដំណឹងភ្លាមៗអំពីការងារ និងវត្តមាន\nរបស់អ្នកតាមរយៈ Telegram Bot។',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 30),

            // 2. Action Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004C4C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('ភ្ជាប់ឥឡូវនេះ ', style: TextStyle(fontSize: 18, color: Colors.white)),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 3. QR Code Card Section
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('ស្កេនកូដ QR ដើម្បីចូលរួម', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 20),
                   
                    Container(
                      height: 290,
                      width: 290,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.qr_code, size: 130, color: Color(0xFF004C4C)),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '@WorkSmart_Bot',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF004C4C), fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // 4. Instructional Steps
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('របៀបភ្ជាប់៖', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            _buildStepItem('១', 'ស្កេនកូដ QR', 'បើកកាមេរ៉ាទូរស័ព្ទរបស់អ្នក ដើម្បីស្កេនកូដខាងលើ។'),
            _buildStepItem('២', 'ចុចប៊ូតុង ចាប់ផ្តើម (Start)', 'ផ្ញើសារ /start ទៅកាន់ប៊ូត ដើម្បីធ្វើការចុះឈ្មោះ។'),
            _buildStepItem('៣', 'ទទួលបានការជូនដំណឹង', 'អ្នកនឹងទទួលបានការជូនដំណឹងដោយស្វ័យប្រវត្តិតាម Telegram។'),
            const SizedBox(height: 50),
          ],
        ),
      ),
      // 5. Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF004C4C),
        unselectedItemColor: Colors.grey,
        currentIndex: 3, // Highlight 'Account'
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'ទំព័រដើម'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), label: 'វត្តមាន'),
          BottomNavigationBarItem(icon: Icon(Icons.beach_access_outlined), label: 'ច្បាប់ឈប់សម្រាក'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'គណនី'),
        ],
      ),
    );
  }

  // Helper method for the steps
  Widget _buildStepItem(String number, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFFE0F2F1),
            child: Text(number, style: const TextStyle(color: Color(0xFF004C4C), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
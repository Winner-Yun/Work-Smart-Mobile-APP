import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/config/appcolor.dart';

class TelegramIntegration extends StatefulWidget {
   TelegramIntegration({super.key});

  @override
  State<TelegramIntegration> createState() => _TelegramIntegrationState();
}

class _TelegramIntegrationState extends State<TelegramIntegration> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  AppColors.background, 
      appBar: AppBar(
        backgroundColor:  AppColors.background,
        elevation: 0,
        title:  Text(
          'ការកំណត់ Telegram',
          style: TextStyle(
            fontSize: 20,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding:  EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
             SizedBox(height: 30),
         
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding:  EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child:  Icon(Icons.send, size: 60, color: Colors.white),
                  ),
                   CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.check_circle, color: Colors.green, size: 22),
                  ),
                ],
              ),
            ),
             SizedBox(height: 20),
             Text(
              'ភ្ជាប់ជាមួយ Telegram',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color: Color(0xFF004C4C) ),
            ),
             SizedBox(height: 10),
             Text(
              'ទទួលបានការជូនដំណឹងភ្លាមៗអំពីការងារ និងវត្តមាន\nរបស់អ្នកតាមរយៈ Telegram Bot។',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, height: 1.5),
            ),
             SizedBox(height: 30),

          
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor:  Color(0xFF004C4C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child:  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('ភ្ជាប់ឥឡូវនេះ ', style: TextStyle(fontSize: 18, color: Colors.white)),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ),
             SizedBox(height: 40),

           
            Container(
              padding:  EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset:  Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding:  EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Text('ស្កេនកូដ QR ដើម្បីចូលរួម', style: TextStyle(color: Colors.grey)),
                     SizedBox(height: 20),
                   
                    Container(
                      height: 290,
                      width: 290,
                      decoration: BoxDecoration(
                        color:  Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child:  Icon(Icons.qr_code, size: 130, color: Color(0xFF004C4C)),
                    ),
                     SizedBox(height: 20),
                     Text(
                      '@WorkSmart_Bot',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF004C4C), fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
             SizedBox(height: 40),

            
            Align(
              alignment: Alignment.centerLeft,
              child: Text('របៀបភ្ជាប់៖', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
             SizedBox(height: 20),
            _buildStepItem('១', 'ស្កេនកូដ QR', 'បើកកាមេរ៉ាទូរស័ព្ទរបស់អ្នក ដើម្បីស្កេនកូដខាងលើ។'),
            _buildStepItem('២', 'ចុចប៊ូតុង ចាប់ផ្តើម (Start)', 'ផ្ញើសារ /start ទៅកាន់ប៊ូត ដើម្បីធ្វើការចុះឈ្មោះ។'),
            _buildStepItem('៣', 'ទទួលបានការជូនដំណឹង', 'អ្នកនឹងទទួលបានការជូនដំណឹងដោយស្វ័យប្រវត្តិតាម Telegram។'),
             SizedBox(height: 50),
          ],
        ),
      ),
    
      
     
    );
  }

 
  Widget _buildStepItem(String number, String title, String desc) {
    return Padding(
      padding:  EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor:  Color(0xFFE0F2F1),
            child: Text(number, style:  TextStyle(color: Color(0xFF004C4C), fontWeight: FontWeight.bold)),
          ),
           SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style:  TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(desc, style:  TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
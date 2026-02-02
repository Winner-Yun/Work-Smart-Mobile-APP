import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';

class TelegramIntegration extends StatefulWidget {
  const TelegramIntegration({super.key});

  @override
  State<TelegramIntegration> createState() => _TelegramIntegrationState();
}

class _TelegramIntegrationState extends State<TelegramIntegration> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            _buildHeaderIcon(),
            const SizedBox(height: 20),
            _buildIntroText(context),
            const SizedBox(height: 30),
            _buildConnectButton(),
            const SizedBox(height: 40),
            _buildQRCodeCard(context),
            const SizedBox(height: 40),
            _buildInstructionsSection(context),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Theme.of(context).iconTheme.color,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'ការកំណត់ Telegram',
        style: TextStyle(
          fontSize: 20,
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHeaderIcon() {
    return Center(
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
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveY(
                begin: -5,
                end: 5,
                duration: 2.seconds,
                curve: Curves.easeInOut,
              ),
          const CircleAvatar(
            radius: 12,
            backgroundColor: Colors.white,
            child: Icon(Icons.check_circle, color: Colors.green, size: 22),
          ).animate().scale(
            delay: 500.ms,
            duration: 400.ms,
            curve: Curves.elasticOut,
          ),
        ],
      ),
    );
  }

  Widget _buildIntroText(BuildContext context) {
    return Column(
      children: [
        const Text(
          'ភ្ជាប់ជាមួយ Telegram',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'ទទួលបានការជូនដំណឹងភ្លាមៗអំពីការងារ និងវត្តមាន\nរបស់អ្នកតាមរយៈ Telegram Bot។',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textGrey, height: 1.5),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildConnectButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ភ្ជាប់ឥឡូវនេះ ',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            Icon(Icons.arrow_forward, color: Colors.white),
          ],
        ),
      ),
    ).animate().scale(delay: 200.ms);
  }

  Widget _buildQRCodeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'ស្កេនកូដ QR ដើម្បីចូលរួម',
            style: TextStyle(color: AppColors.textGrey),
          ),
          const SizedBox(height: 20),
          Container(
                height: 260,
                width: 260,
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFF5F5F5,
                  ), // QR Code background stays light for scanning contrast
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.qr_code,
                  size: 130,
                  color: AppColors.primary,
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .shimmer(
                delay: 3.seconds,
                duration: 1500.ms,
                color: Colors.white54,
              )
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.03, 1.03),
                duration: 2.seconds,
              ),
          const SizedBox(height: 20),
          const Text(
            '@WorkSmart_Bot',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildInstructionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'របៀបភ្ជាប់៖',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ...[
          _buildStepItem(
            context,
            '១',
            'ស្កេនកូដ QR',
            'បើកកាមេរ៉ាទូរស័ព្ទរបស់អ្នក ដើម្បីស្កេនកូដខាងលើ។',
          ),
          _buildStepItem(
            context,
            '២',
            'ចុចប៊ូតុង ចាប់ផ្តើម (Start)',
            'ផ្ញើសារ /start ទៅកាន់ប៊ូត ដើម្បីធ្វើការចុះឈ្មោះ។',
          ),
          _buildStepItem(
            context,
            '៣',
            'ទទួលបានការជូនដំណឹង',
            'អ្នកនឹងទទួលបានការជូនដំណឹងដោយស្វ័យប្រវត្តិតាម Telegram។',
          ),
        ].asMap().entries.map((entry) {
          return entry.value
              .animate()
              .fadeIn(delay: (600 + (entry.key * 150)).ms)
              .slideX(begin: 0.1, end: 0);
        }),
      ],
    );
  }

  Widget _buildStepItem(
    BuildContext context,
    String number,
    String title,
    String desc,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Text(
              number,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

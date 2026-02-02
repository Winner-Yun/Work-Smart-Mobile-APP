import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_img.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textLight,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ជំនួយ និង ការគាំទ្រ',
          style: TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('ទំនាក់ទំនងមកយើង', context),
            const SizedBox(height: 15),
            _buildSupportCard(
              context,
              icon: Icons.headset_mic_rounded,
              title: 'ផ្នែកបម្រើអតិថិជន',
              subtitle: 'ឆ្លើយតបរហ័ស ២៤/៧',
              color: Colors.blue,
              onTap: () {}, // Add Telegram link logic
            ),
            const SizedBox(height: 15),
            _buildSupportCard(
              context,
              icon: Icons.mail_rounded,
              title: 'ផ្ញើអ៊ីមែល',
              subtitle: 'support@worksmart.kh',
              color: Colors.orange,
              onTap: () {},
            ),
            const SizedBox(height: 30),
            _buildSectionHeader('សំណួរដែលសួរញឹកញាប់ (FAQ)', context),
            const SizedBox(height: 15),
            _buildFAQTile('របៀបប្តូរលេខសម្ងាត់?', context),
            _buildFAQTile('តើធ្វើដូចម្តេចដើម្បីភ្ជាប់ Telegram?', context),
            _buildFAQTile('បញ្ហាការចុះឈ្មោះចូលប្រើប្រាស់', context),
            const SizedBox(height: 40),
            _buildVersionInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildSupportCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 26),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textGrey,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildFAQTile(String question, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        title: Text(question, style: const TextStyle(fontSize: 14)),
        trailing: const Icon(Icons.add, size: 20, color: AppColors.primary),
        onTap: () {},
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildVersionInfo() {
    return Center(
      child: Column(
        children: [
          Image.asset(
            AppImg.appIcon,
            height: 40,
            errorBuilder: (c, e, s) =>
                const Icon(Icons.business_center, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          const Text(
            'WorkSmart Mobile App',
            style: TextStyle(
              color: AppColors.textGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Version 1.0.0',
            style: TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';

class AnnualLeaveRequestScreen extends StatefulWidget {
  const AnnualLeaveRequestScreen({super.key});

  @override
  State<AnnualLeaveRequestScreen> createState() =>
      _AnnualLeaveRequestScreenState();
}

class _AnnualLeaveRequestScreenState extends State<AnnualLeaveRequestScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoBanner(),
            const SizedBox(height: 25),
            _buildSectionTitle('ជ្រើសរើសកាលបរិច្ឆេទ', context),
            const SizedBox(height: 15),
            _buildDateRangePicker(context),
            const SizedBox(height: 25),
            _buildSectionTitle('មូលហេតុនៃការស្នើសុំ', context),
            const SizedBox(height: 15),
            _buildTextArea(context),
            const SizedBox(height: 40),
            _buildSubmitButton(),
          ],
        ).animate().fadeIn(duration: 500.ms),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50.withOpacity(0.1), // Adjusted for theme
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'អ្នកនៅសល់ច្បាប់សម្រាកចំនួន ១២ ថ្ងៃសម្រាប់ឆ្នាំនេះ។',
              style: TextStyle(
                color: Colors.teal.shade900, // Or adapt to theme
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangePicker(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _dateColumn(context, 'ថ្ងៃចាប់ផ្តើម', '២០ តុលា ២០២៣'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.arrow_forward, color: Colors.grey, size: 16),
          ),
          _dateColumn(context, 'ថ្ងៃបញ្ចប់', '២២ តុលា ២០២៣'),
        ],
      ),
    );
  }

  Widget _dateColumn(BuildContext context, String label, String date) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 5),
          Text(
            date,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextArea(BuildContext context) {
    return TextField(
      maxLines: 5,
      decoration: InputDecoration(
        hintText: 'បញ្ជាក់មូលហេតុនៅទីនេះ...',
        filled: true,
        fillColor: Theme.of(context).inputDecorationTheme.fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // --- Reusing AppBar, Section Title, and Submit Button from Sick Leave ---
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0.5,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          color: Theme.of(context).iconTheme.color,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'ពាក្យសុំច្បាប់ប្រចាំឆ្នាំ',
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSectionTitle(String text, BuildContext context) => Text(
    text,
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Theme.of(context).textTheme.bodyLarge?.color,
    ),
  );

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          'ផ្ញើសំណើឈប់សម្រាក',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

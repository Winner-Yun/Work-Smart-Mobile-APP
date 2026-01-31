import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/config/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/translations/app_strings.dart';

class AttendanceDetailScreen extends StatelessWidget {
  const AttendanceDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> data =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeaderCard(data).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 25),
            if (data['status'] == "វត្តមាន") ...[
              _buildCheckInDetail(data).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 25),
              _buildCheckOutDetail(data).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 25),
              _buildTotalHoursSummary(data).animate().fadeIn(delay: 200.ms),
            ] else ...[
              _buildAbsentFallback().animate().fadeIn(delay: 200.ms),
            ],
          ],
        ),
      ),
    );
  }

  // --- WIDGET MODULES ---

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        AppStrings.tr('attendance_details'),
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildDateHeaderCard(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "កាលបរិច្ឆេទ",
                style: TextStyle(color: AppColors.textGrey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                "${data['date']} ${data['day']}",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: (data['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.circle, size: 8, color: data['color']),
                const SizedBox(width: 5),
                Text(
                  data['status'],
                  style: TextStyle(
                    color: data['color'],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInDetail(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(Icons.login, AppStrings.tr('check_in_title')),
        const SizedBox(height: 10),
        _buildDetailCard(
          time: data['checkIn'],
          imageColor: const Color(0xFFD7CCC8),
          isCheckIn: true,
          isLate: data['isLate'] ?? false,
        ),
      ],
    );
  }

  Widget _buildCheckOutDetail(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          Icons.logout,
          AppStrings.tr('check_out_title'),
          color: Colors.orange,
        ),
        const SizedBox(height: 10),
        _buildDetailCard(
          time: data['checkOut'],
          imageColor: const Color(0xFFC8E6C9),
          isCheckIn: false,
          isLate: false,
        ),
      ],
    );
  }

  Widget _buildTotalHoursSummary(Map<String, dynamic> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.timer_outlined, color: Colors.white),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.tr('total_hours'),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    data['hours'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppStrings.tr('equal_to'),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
              Text(
                AppStrings.tr('one_full_day'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAbsentFallback() {
    return Column(
      children: [
        const SizedBox(height: 50),
        Center(
          child: Column(
            children: [
              Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 20),
              Text(
                "មិនមានទិន្នន័យសម្រាប់ថ្ងៃនេះទេ",
                style: TextStyle(color: AppColors.textGrey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- SHARED SUB-WIDGETS ---

  Widget _buildSectionHeader(
    IconData icon,
    String title, {
    Color color = AppColors.primary,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required String time,
    required Color imageColor,
    required bool isCheckIn,
    required bool isLate,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildLiveImagePlaceholder(imageColor),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeHeader(isCheckIn, isLate),
                Text(
                  time,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                _buildLocationInfo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveImagePlaceholder(Color color) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.image, color: Colors.white54, size: 40),
        ),
        Positioned(
          bottom: 5,
          right: 5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              "Live",
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeHeader(bool isCheckIn, bool isLate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isCheckIn ? "ម៉ោងចូល" : "ម៉ោងចេញ",
          style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
        ),
        if (isLate && isCheckIn)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              "Late",
              style: TextStyle(
                color: Colors.orange,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Row(
      children: [
        const Icon(Icons.location_on, color: AppColors.secondary, size: 20),
        const SizedBox(width: 5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.tr('location_label'),
                style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
              ),
              Text(
                AppStrings.tr('phnom_penh'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_route.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_img.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/appcolor.dart';
import 'package:flutter_worksmart_mobile_app/features/user/logic/homepage_logic.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePageScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;
  final Map<String, dynamic>? loginData;

  const HomePageScreen({super.key, this.onProfileTap, this.loginData});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends HomePageLogic {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: [
            _buildStickyHeader(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _buildDateAndStatusRow().animate().fadeIn(duration: 400.ms),
                    const SizedBox(height: 20),
                    _buildTimeAttendanceSection(
                      context,
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                    const SizedBox(height: 20),
                    // Check logic based on currentUser Face Status
                    if (currentFaceStatus == 'approved')
                      _buildLiveMapCard(context)
                          .animate()
                          .fadeIn(delay: 400.ms)
                          .scale(begin: const Offset(0.95, 0.95))
                    else
                      _buildFaceRegistrationCard(),
                    const SizedBox(height: 20),
                    _buildLeaveStatsSection(
                      context,
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
                    const SizedBox(height: 20),
                    _buildEmployeeSectionHeader(
                      context,
                    ).animate().fadeIn(delay: 700.ms),
                    _buildEmployeeList(context),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveMapCard(BuildContext context) {
    String getFormattedDistance(String statusText) {
      if (!statusText.contains("m")) return "--";
      try {
        String rawMetric = statusText
            .split(" ")
            .firstWhere((s) => s.contains("m"), orElse: () => "");
        String numberString = rawMetric.replaceAll(RegExp(r'[^0-9.]'), '');
        if (numberString.isEmpty) return "--";
        double distance = double.parse(numberString);
        if (distance >= 1000) {
          return "${(distance / 1000).toStringAsFixed(2)} km";
        } else {
          return "${distance.toInt()} m";
        }
      } catch (e) {
        return "--";
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A4A4A).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 240,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: officeLocation, // Use dynamic variable
                      zoom: 16,
                    ),
                    onMapCreated: (c) {
                      mapController = c;
                      updateMapStyle(context);
                    },
                    markers: markers,
                    circles: circles,
                    myLocationEnabled: false,
                    zoomGesturesEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                    compassEnabled: false,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.05),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isInRange
                                ? Theme.of(context).colorScheme.primary
                                : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ).animate(onPlay: (c) => c.repeat()).fade().scale(),
                        const SizedBox(width: 6),
                        Text(
                          isInRange
                              ? AppStrings.tr('office_zone')
                              : AppStrings.tr('outside_zone'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isInRange
                                ? Theme.of(context).colorScheme.primary
                                : Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.tr('gps_status'),
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isInRange
                                ? AppStrings.tr('ready_to_scan')
                                : rangeStatusText.contains("Mock")
                                ? "Fake GPS!"
                                : AppStrings.tr('too_far'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isInRange
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            AppStrings.tr('get_directions'),
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppStrings.tr('distance'),
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            getFormattedDistance(rangeStatusText),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: openDirections,
                            child: Container(
                              width: 100,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.directions_bike,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isInRange
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).cardTheme.color,
                    boxShadow: isInRange
                        ? [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : [],
                  ),
                  child: ElevatedButton(
                    onPressed: isInRange
                        ? () => {
                            Navigator.pushNamed(
                              context,
                              AppRoute.faceScanScreen,
                            ),
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          color: isInRange ? Colors.white : Colors.grey[500],
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AppStrings.tr('scan_out'),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isInRange ? Colors.white : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyHeader(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      pinned: true,
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0,
      elevation: 0,
      toolbarHeight: 80,
      titleSpacing: 20,
      title: Row(
        children: [
          GestureDetector(
            onTap: widget.onProfileTap,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey,
                  // Use dynamic profile URL
                  backgroundImage: NetworkImage(currentUser.profileUrl),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      border: Border.all(color: Colors.white, width: 2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.tr('greeting'),
                  style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                ),
                // Dynamic User Name
                Text(
                  "${AppStrings.tr(currentUser.gender == 'male' ? 'greet_pronoun_man' : 'greet_pronoun_woman')} ${currentUser.displayName}",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(
            context,
            AppRoute.notificationScreen,
            arguments: widget.loginData,
          ),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5),
              ],
            ),
            child: Stack(
              children: [
                Icon(
                  Icons.notifications_none,
                  color: Theme.of(context).iconTheme.color,
                ),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().shake(delay: 1.seconds, duration: 500.ms),
        ),
      ],
    );
  }

  Widget _buildDateAndStatusRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Using real date from attendance record or defaulting to today
        Text(
          currentAttendance['date'] ?? AppStrings.tr('mock_date'),
          style: const TextStyle(color: AppColors.textGrey, fontSize: 14),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                Icons.shield_outlined,
                size: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                AppStrings.tr('safety'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeAttendanceSection(BuildContext context) {
    return Row(
      children: [
        _buildTimeCard(
          context,
          AppStrings.tr('check_in'),
          currentAttendance['check_in'] ?? "--:--",
          Icons.login,
          false,
        ),
        const SizedBox(width: 10),
        _buildTimeCard(
          context,
          AppStrings.tr('check_out'),
          currentAttendance['check_out'] ?? "--:--",
          Icons.logout,
          false,
        ),
        const SizedBox(width: 10),
        _buildTimeCard(
          context,
          AppStrings.tr('work_hours'),
          "${currentAttendance['total_hours'] ?? 0}h",
          Icons.access_time,
          true,
        ),
      ],
    );
  }

  Widget _buildTimeCard(
    BuildContext context,
    String label,
    String time,
    IconData icon,
    bool isDark,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        height: 110,
        decoration: BoxDecoration(
          color: isDark
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isDark
                      ? Colors.white70
                      : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppColors.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Text(
              time,
              style: TextStyle(
                color: isDark
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveStatsSection(BuildContext context) {
    // Access data via Getter from Logic
    return Row(
      children: leaveStatisticsData.map((data) {
        return Expanded(
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              AppRoute.leaveDatailScreen,
              arguments: widget.loginData,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildPremiumLeaveCard(
                    context,
                    data['icon'] as IconData,
                    AppStrings.tr(data['label']),
                    data['amount'],
                    data['color'] as Color,
                    data['progress'] as double,
                    data['used'] as int,
                    data['remaining'] as int,
                  ),
                ),
                if (data != leaveStatisticsData.last) const SizedBox(width: 15),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPremiumLeaveCard(
    BuildContext context,
    IconData icon,
    String label,
    String amount,
    Color color,
    double progress,
    int used,
    int remaining,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                AppStrings.tr('days'),
                style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${AppStrings.tr('used')} $used ${AppStrings.tr('days')}\n${AppStrings.tr('remaining')} $remaining ${AppStrings.tr('days')}",
            style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeSectionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppStrings.tr('employee_title'),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pushNamed(context, AppRoute.leaderboardScreen),
          child: Text(
            AppStrings.tr('view_all'),
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeList(BuildContext context) {
    // Access data via Getter from Logic
    return Column(
      children: employeeListDisplayData.asMap().entries.map((entry) {
        return GestureDetector(
          onTap: () => Navigator.pushNamed(
            context,
            AppRoute.leaderboardScreen,
            arguments: widget.loginData,
          ),
          child:
              _buildEmployeeRow(
                    context,
                    entry.value['name'],
                    AppStrings.tr(
                      entry.value['role'],
                    ), // Assuming roles are keys
                    entry.value['score'],
                    entry.value['imgUrl'],
                    entry.value['isTop'],
                  )
                  .animate()
                  .fadeIn(delay: (800 + (entry.key * 100)).ms)
                  .slideX(begin: 0.1),
        );
      }).toList(),
    );
  }

  Widget _buildFaceRegistrationCard() {
    bool isPending = currentFaceStatus == 'pending';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPending
              ? Theme.of(context).colorScheme.secondary.withOpacity(0.5)
              : Theme.of(context).colorScheme.primary.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isPending
                ? Icons.hourglass_empty_rounded
                : Icons.face_retouching_natural,
            size: 50,
            color: isPending
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 15),
          Text(
            isPending
                ? AppStrings.tr('pending_approval_title')
                : AppStrings.tr('face_required_title'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isPending
                ? AppStrings.tr('pending_approval_desc')
                : AppStrings.tr('face_required_desc'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          if (!isPending)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    AppRoute.registerFace,
                  );
                  if (result != null) {
                    // Call handler to update face status: pending -> approved after 5 seconds
                    handleFaceRegistrationComplete();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppStrings.tr('register_now'),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppStrings.tr('processing'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ).animate().fade().slideY(begin: 0.2);
  }

  Widget _buildEmployeeRow(
    BuildContext context,
    String name,
    String role,
    String score,
    String imgUrl,
    bool isTop,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: isTop ? Border.all(color: AppColors.secondary, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: EdgeInsets.all(isTop ? 2 : 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isTop
                      ? Border.all(color: AppColors.secondary, width: 2)
                      : null,
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(imgUrl),
                ),
              ),
              if (isTop)
                Positioned(
                  top: -8,
                  right: -6,
                  child: Image.asset(AppImg.crown, width: 24, height: 24),
                ),
            ],
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                role,
                style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Text(
            score,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

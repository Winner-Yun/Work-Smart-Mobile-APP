import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_admin_route.dart';
import 'package:flutter_worksmart_mobile_app/config/language_manager.dart';
import 'package:flutter_worksmart_mobile_app/config/theme_manager.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/core/util/mock_data/userFinalData.dart';
import 'package:flutter_worksmart_mobile_app/shared/model/admin_models/dashboard_model.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/admin/admin_header_bar.dart';
import 'package:flutter_worksmart_mobile_app/shared/widget/admin/admin_side_bar.dart';

class ManualFaceReviewScreen extends StatefulWidget {
  const ManualFaceReviewScreen({super.key});

  @override
  State<ManualFaceReviewScreen> createState() => _ManualFaceReviewScreenState();
}

class _ManualFaceReviewScreenState extends State<ManualFaceReviewScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final Map<String, ScrollController> _sampleScrollControllers = {};

  late List<UserEmployee> _users;
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _users = usersFinalData
        .map((entry) => UserEmployee.fromMap(entry))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    for (final controller in _sampleScrollControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _navigateTo(String routeName) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
    if (mounted) Navigator.of(context).pushNamed(routeName);
  }

  List<UserEmployee> get _filteredUsers {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = _users.where((user) {
      final currentStatus = (user.faceStatus ?? 'pending').toLowerCase();
      final statusMatches =
          _statusFilter == 'all' || currentStatus == _statusFilter;
      final searchMatches =
          query.isEmpty ||
          user.displayName.toLowerCase().contains(query) ||
          user.uid.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);
      return statusMatches && searchMatches;
    }).toList();

    if (_statusFilter == 'all') {
      const statusPriority = {
        'pending': 0,
        'approved': 1,
        'uninitialized': 2,
        'rejected': 3,
      };

      filtered.sort((a, b) {
        final aStatus = (a.faceStatus ?? 'pending').toLowerCase();
        final bStatus = (b.faceStatus ?? 'pending').toLowerCase();

        final aRank = statusPriority[aStatus] ?? 99;
        final bRank = statusPriority[bStatus] ?? 99;

        if (aRank != bRank) {
          return aRank.compareTo(bRank);
        }

        return a.displayName.toLowerCase().compareTo(
          b.displayName.toLowerCase(),
        );
      });
    }

    return filtered;
  }

  bool _hasFaceSamples(UserEmployee user) {
    final faceImages = user.faceImageUrls
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toList();
    return faceImages.isNotEmpty || user.faceImageUrl.trim().isNotEmpty;
  }

  bool _canApprove(UserEmployee user) {
    final status = (user.faceStatus ?? 'pending').toLowerCase();
    if (status == 'approved') return false;
    if (!_hasFaceSamples(user)) return false;
    return true;
  }

  bool _canReject(UserEmployee user) {
    final status = (user.faceStatus ?? 'pending').toLowerCase();
    if (status == 'rejected') return false;
    if (status == 'uninitialized' && !_hasFaceSamples(user)) return false;
    return true;
  }

  String _faceStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppStrings.tr('face_status_approved');
      case 'rejected':
        return AppStrings.tr('face_status_rejected');
      case 'uninitialized':
        return AppStrings.tr('face_status_uninitialized');
      case 'pending':
      default:
        return AppStrings.tr('face_status_pending');
    }
  }

  void _updateFaceStatus(UserEmployee user, String newStatus) {
    final currentStatus = (user.faceStatus ?? 'pending').toLowerCase();
    final targetStatus = newStatus.toLowerCase();

    if (currentStatus == targetStatus) {
      return;
    }

    if (targetStatus == 'approved' && !_hasFaceSamples(user)) {
      return;
    }

    setState(() {
      _users = _users
          .map(
            (item) => item.uid == user.uid
                ? UserEmployee(
                    uid: item.uid,
                    displayName: item.displayName,
                    roleTitle: item.roleTitle,
                    gender: item.gender,
                    email: item.email,
                    phone: item.phone,
                    departmentId: item.departmentId,
                    officeId: item.officeId,
                    profileUrl: item.profileUrl,
                    faceImageUrl: item.faceImageUrl,
                    faceImageUrls: item.faceImageUrls,
                    faceCount: item.faceCount,
                    status: item.status,
                    joinDate: item.joinDate,
                    faceStatus: newStatus,
                  )
                : item,
          )
          .toList();
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'uninitialized':
        return Colors.orange;
      default:
        return Theme.of(context).colorScheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([ThemeManager(), LanguageManager()]),
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 1100;
            final isCompact = !isDesktop;

            final mainContent = Column(
              children: [
                AdminHeaderBar(_scaffoldKey, isCompact: isCompact),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(isCompact ? 16 : 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.tr('manual_face_review_title'),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppStrings.tr('manual_face_review_subtitle'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.65),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildFilters(),
                        const SizedBox(height: 16),
                        _buildFaceReviewTable(),
                      ],
                    ),
                  ),
                ),
              ],
            );

            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              drawer: isCompact
                  ? Drawer(
                      child: AdminSideBar(
                        isCompact: true,
                        faceReviewSelected: true,
                        onDashboardTap: () =>
                            _navigateTo(AppAdminRoute.adminDashboard),
                        onStaffTap: () =>
                            _navigateTo(AppAdminRoute.staffManagement),
                        onGeofencingTap: () =>
                            _navigateTo(AppAdminRoute.geofencing),
                        onLeaderboardTap: () =>
                            _navigateTo(AppAdminRoute.performanceLeaderboard),
                        onLeaveRequestsTap: () =>
                            _navigateTo(AppAdminRoute.leaveRequests),
                        onAnalyticsTap: () =>
                            _navigateTo(AppAdminRoute.analyticsReports),
                        onFaceReviewTap: () =>
                            _navigateTo(AppAdminRoute.manualFaceReview),
                        onSettingsTap: () =>
                            _navigateTo(AppAdminRoute.systemSettings),
                      ),
                    )
                  : null,
              body: Row(
                children: [
                  if (isDesktop)
                    AdminSideBar(
                      isCompact: false,
                      faceReviewSelected: true,
                      onDashboardTap: () =>
                          _navigateTo(AppAdminRoute.adminDashboard),
                      onStaffTap: () =>
                          _navigateTo(AppAdminRoute.staffManagement),
                      onGeofencingTap: () =>
                          _navigateTo(AppAdminRoute.geofencing),
                      onLeaderboardTap: () =>
                          _navigateTo(AppAdminRoute.performanceLeaderboard),
                      onLeaveRequestsTap: () =>
                          _navigateTo(AppAdminRoute.leaveRequests),
                      onAnalyticsTap: () =>
                          _navigateTo(AppAdminRoute.analyticsReports),
                      onFaceReviewTap: () =>
                          _navigateTo(AppAdminRoute.manualFaceReview),
                      onSettingsTap: () =>
                          _navigateTo(AppAdminRoute.systemSettings),
                    ),
                  Expanded(child: mainContent),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilters() {
    final statuses = [
      'all',
      'pending',
      'approved',
      'rejected',
      'uninitialized',
    ];

    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: AppStrings.tr('manual_face_review_search_hint'),
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor.withOpacity(0.3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final status = statuses[index];
              final isSelected = status == _statusFilter;
              return ChoiceChip(
                label: Text(status.toUpperCase()),
                selected: isSelected,
                onSelected: (_) => setState(() => _statusFilter = status),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemCount: statuses.length,
          ),
        ),
      ],
    );
  }

  Widget _buildFaceReviewTable() {
    final users = _filteredUsers;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.25),
        ),
      ),
      child: users.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 56),
              child: Center(
                child: Text(
                  AppStrings.tr('no_data'),
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
              itemBuilder: (context, index) {
                final user = users[index];
                final faceStatus = (user.faceStatus ?? 'pending').toLowerCase();
                final statusColor = _statusColor(faceStatus);
                final isUninitialized = faceStatus == 'uninitialized';
                final canApprove = _canApprove(user);
                final canReject = _canReject(user);
                return Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFaceSamples(user, isUninitialized),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.displayName,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.email,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.65),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.uid,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.55),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                _faceStatusLabel(faceStatus).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: canReject
                                ? () => _updateFaceStatus(user, 'rejected')
                                : null,
                            icon: const Icon(Icons.close_rounded, size: 18),
                            label: Text(AppStrings.tr('reject')),
                          ),
                          FilledButton.icon(
                            onPressed: canApprove
                                ? () => _updateFaceStatus(user, 'approved')
                                : null,
                            icon: const Icon(Icons.check_rounded, size: 18),
                            label: Text(AppStrings.tr('approve')),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildFaceSamples(UserEmployee user, bool isUninitialized) {
    final faceImages = user.faceImageUrls
        .map((url) => url.trim())
        .where((url) => url.isNotEmpty)
        .toList();
    if (faceImages.isEmpty && user.faceImageUrl.trim().isNotEmpty) {
      faceImages.add(user.faceImageUrl.trim());
    }

    final slotCount = [
      5,
      user.faceCount,
      faceImages.length,
    ].reduce((a, b) => a > b ? a : b);

    final scrollController = _sampleScrollControllers.putIfAbsent(
      user.uid,
      () => ScrollController(),
    );

    if (isUninitialized || faceImages.isEmpty) {
      return Container(
        width: 440,
        height: 110,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withOpacity(0.45),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.35),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.face_retouching_off_rounded,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppStrings.tr('manual_face_review_uninitialized_no_samples'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 440,
        height: 110,
        padding: const EdgeInsets.all(8),
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.35),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragUpdate: (details) {
            if (!scrollController.hasClients) return;
            final maxExtent = scrollController.position.maxScrollExtent;
            final minExtent = scrollController.position.minScrollExtent;
            final target = (scrollController.offset - details.delta.dx).clamp(
              minExtent,
              maxExtent,
            );
            scrollController.jumpTo(target);
          },
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(slotCount, (index) {
                    final hasImage = index < faceImages.length;

                    Widget item;
                    if (!hasImage) {
                      item = Container(
                        width: 92,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).dividerColor.withOpacity(0.35),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${AppStrings.tr('manual_face_review_slot')} ${index + 1}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                      );
                    } else {
                      item = ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 92,
                          child: Image.network(
                            faceImages[index],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Theme.of(context).colorScheme.surface,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    if (index == slotCount - 1) return item;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: item,
                    );
                  }),
                ),
              ),
              Positioned(
                right: 6,
                bottom: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surface.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    AppStrings.tr('manual_face_review_swipe_hint'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

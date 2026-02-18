import 'package:flutter/material.dart';
import 'package:flutter_worksmart_mobile_app/app/routes/app_admin_route.dart';
import 'package:flutter_worksmart_mobile_app/config/language_manager.dart';
import 'package:flutter_worksmart_mobile_app/config/theme_manager.dart';
import 'package:flutter_worksmart_mobile_app/core/constants/app_strings.dart';
import 'package:flutter_worksmart_mobile_app/features/admin/dashboard/logic/admin_dashboard_logic.dart';

class AdminHeaderBar extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final bool isCompact;

  const AdminHeaderBar(this.scaffoldKey, {this.isCompact = false, super.key});

  @override
  State<AdminHeaderBar> createState() => _AdminHeaderBarState();
}

class _AdminHeaderBarState extends State<AdminHeaderBar> {
  bool _isProfileHovering = false;
  bool _notifSortAscending = true;
  final Set<String> _readNotificationIds = {};

  List<Map<String, dynamic>> _buildNotificationItems() {
    final items = [
      {
        'id': 'late_alert',
        'title': AppStrings.tr('admin_notif_late_title'),
        'detail': AppStrings.tr('admin_notif_late_detail'),
        'time': '10m',
        'icon': Icons.warning_amber_rounded,
        'color': Theme.of(context).colorScheme.secondary,
      },
      {
        'id': 'leave_approved_1',
        'title': AppStrings.tr('admin_notif_leave_title'),
        'detail': AppStrings.tr('admin_notif_leave_detail'),
        'time': '1h',
        'icon': Icons.check_circle_rounded,
        'color': Theme.of(context).colorScheme.primary,
      },
      {
        'id': 'leave_approved_2',
        'title': AppStrings.tr('admin_notif_leave_title'),
        'detail': AppStrings.tr('admin_notif_leave_detail'),
        'time': '1h',
        'icon': Icons.check_circle_rounded,
        'color': Theme.of(context).colorScheme.primary,
      },
      {
        'id': 'leave_approved_3',
        'title': AppStrings.tr('admin_notif_leave_title'),
        'detail': AppStrings.tr('admin_notif_leave_detail'),
        'time': '1h',
        'icon': Icons.check_circle_rounded,
        'color': Theme.of(context).colorScheme.primary,
      },
      {
        'id': 'leave_approved_4',
        'title': AppStrings.tr('admin_notif_leave_title'),
        'detail': AppStrings.tr('admin_notif_leave_detail'),
        'time': '1h',
        'icon': Icons.check_circle_rounded,
        'color': Theme.of(context).colorScheme.primary,
      },
      {
        'id': 'leave_approved_5',
        'title': AppStrings.tr('admin_notif_leave_title'),
        'detail': AppStrings.tr('admin_notif_leave_detail'),
        'time': '1h',
        'icon': Icons.check_circle_rounded,
        'color': Theme.of(context).colorScheme.primary,
      },
      {
        'id': 'leave_approved_6',
        'title': AppStrings.tr('admin_notif_leave_title'),
        'detail': AppStrings.tr('admin_notif_leave_detail'),
        'time': '1h',
        'icon': Icons.check_circle_rounded,
        'color': Theme.of(context).colorScheme.primary,
      },
      {
        'id': 'leave_approved_7',
        'title': AppStrings.tr('admin_notif_leave_title'),
        'detail': AppStrings.tr('admin_notif_leave_detail'),
        'time': '1h',
        'icon': Icons.check_circle_rounded,
        'color': Theme.of(context).colorScheme.primary,
      },
    ];

    items.sort((a, b) {
      final aMinutes = _parseMinutes(a['time'] as String);
      final bMinutes = _parseMinutes(b['time'] as String);
      return _notifSortAscending
          ? aMinutes.compareTo(bMinutes)
          : bMinutes.compareTo(aMinutes);
    });

    return items;
  }

  int _parseMinutes(String time) {
    final value = int.tryParse(time.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (time.contains('h')) {
      return value * 60;
    }
    return value;
  }

  void _markAllNotificationsRead({VoidCallback? onAfter}) {
    final items = _buildNotificationItems();
    setState(() {
      _readNotificationIds.addAll(items.map((item) => item['id'] as String));
    });
    onAfter?.call();
  }

  void _markNotificationRead(String id, {VoidCallback? onAfter}) {
    setState(() {
      _readNotificationIds.add(id);
    });
    onAfter?.call();
  }

  @override
  Widget build(BuildContext context) {
    return _buildHeader(context, widget.isCompact);
  }

  Widget _buildHeader(BuildContext context, bool isCompact) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final borderColor = Theme.of(context).dividerColor.withOpacity(0.6);
    final isDarkMode = ThemeManager().isDarkMode;

    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 16 : 24),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(bottom: BorderSide(color: borderColor)),
      ),
      child: Row(
        children: [
          if (isCompact)
            IconButton(
              onPressed: () => widget.scaffoldKey.currentState?.openDrawer(),
              icon: const Icon(Icons.menu_rounded),
            ),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              child: TextField(
                decoration: InputDecoration(
                  hintText: AppStrings.tr('search_hint'),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          _buildActionIcon(
            context: context,
            onTap: () => LanguageManager().changeLanguage(
              LanguageManager().locale == 'en' ? 'km' : 'en',
            ),
            child: Text(
              LanguageManager().locale.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          _buildActionIcon(
            context: context,
            onTap: () => ThemeManager().toggleTheme(!isDarkMode),
            child: Icon(
              isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              size: 20,
            ),
          ),
          Builder(
            builder: (buttonContext) => _buildActionIcon(
              context: context,
              onTap: () => _showNotificationsMenu(buttonContext),
              child: const Icon(Icons.notifications_none_rounded, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          const VerticalDivider(indent: 20, endIndent: 20),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "Admin",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'HR Administrator',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          _buildHoverableProfile(context),
        ],
      ),
    );
  }

  Widget _buildHoverableProfile(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isProfileHovering = true),
      onExit: (_) => setState(() => _isProfileHovering = false),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AppAdminRoute.systemSettings);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _isProfileHovering
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              getInitials('Admin'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon({
    required BuildContext context,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            hoverColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.6),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationsMenu(BuildContext buttonContext) async {
    final items = _buildNotificationItems();
    final menuItems = items.take(5).toList();

    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final box = buttonContext.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final selected = await showMenu<int>(
      context: context,
      position: position,
      color: Theme.of(context).colorScheme.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: [
        PopupMenuItem<int>(
          value: -1,
          height: 36,
          child: SizedBox(
            width: 300,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.tr('notifications_title'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  AppStrings.tr('admin_notif_view_all'),
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        PopupMenuItem<int>(
          value: -2,
          height: 34,
          child: SizedBox(
            width: 300,
            child: Row(
              children: [
                Icon(
                  Icons.done_all_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  AppStrings.tr('mark_all_read'),
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(height: 8),
        if (menuItems.isEmpty)
          PopupMenuItem<int>(
            enabled: false,
            child: SizedBox(
              width: 300,
              child: Row(
                children: [
                  Icon(
                    Icons.inbox_rounded,
                    size: 18,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.4),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppStrings.tr('no_notif'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...menuItems.asMap().entries.map((entry) {
            final item = entry.value;
            final isRead = _readNotificationIds.contains(item['id'] as String);
            final color = item['color'] as Color;
            return PopupMenuItem<int>(
              value: entry.key,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isRead
                      ? Colors.transparent
                      : Theme.of(context).colorScheme.primary.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isRead)
                      Container(
                        margin: const EdgeInsets.only(right: 8, top: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(isRead ? 0.08 : 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        color: isRead ? color.withOpacity(0.6) : color,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: TextStyle(
                              fontWeight: isRead
                                  ? FontWeight.w400
                                  : FontWeight.w700,
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item['detail'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withOpacity(isRead ? 0.3 : 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['time'] as String,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: isRead
                              ? FontWeight.w500
                              : FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface
                              .withOpacity(isRead ? 0.4 : 0.65),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );

    if (selected == -1) {
      _showAllNotificationsDialog();
      return;
    }

    if (selected == -2) {
      _markAllNotificationsRead();
      return;
    }

    if (selected == null) return;

    if (selected >= 0 && selected < menuItems.length) {
      final id = menuItems[selected]['id'] as String;
      _markNotificationRead(id);
    }
  }

  void _showAllNotificationsDialog() {
    String searchQuery = '';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final dialogItems = _buildNotificationItems();
            final filteredItems = searchQuery.isEmpty
                ? dialogItems
                : dialogItems.where((item) {
                    final title = (item['title'] as String).toLowerCase();
                    final detail = (item['detail'] as String).toLowerCase();
                    final query = searchQuery.toLowerCase();
                    return title.contains(query) || detail.contains(query);
                  }).toList();
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(22),
                          topRight: Radius.circular(22),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.notifications_none_rounded,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.tr('notifications_title'),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      dialogItems.isEmpty
                                          ? AppStrings.tr('no_notif')
                                          : '${dialogItems.length} ${AppStrings.tr('results_found')}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  _markAllNotificationsRead(
                                    onAfter: () => setDialogState(() {}),
                                  );
                                },
                                icon: const Icon(
                                  Icons.done_all_rounded,
                                  size: 16,
                                ),
                                label: Text(
                                  AppStrings.tr('mark_all_read'),
                                  style: const TextStyle(fontSize: 11),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                icon: const Icon(Icons.close_rounded, size: 18),
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                                splashRadius: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _buildSortChip(
                                label: AppStrings.tr('sort_asc'),
                                icon: Icons.arrow_upward_rounded,
                                isActive: _notifSortAscending,
                                onTap: () {
                                  setState(() => _notifSortAscending = true);
                                  setDialogState(() {});
                                },
                              ),
                              const SizedBox(width: 8),
                              _buildSortChip(
                                label: AppStrings.tr('sort_desc'),
                                icon: Icons.arrow_downward_rounded,
                                isActive: !_notifSortAscending,
                                onTap: () {
                                  setState(() => _notifSortAscending = false);
                                  setDialogState(() {});
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  onChanged: (value) {
                                    setDialogState(() {
                                      searchQuery = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: AppStrings.tr(
                                      'search_notifications',
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.search_rounded,
                                      size: 18,
                                    ),
                                    filled: true,
                                    fillColor: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest
                                        .withOpacity(0.3),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                onPressed: () {
                                  setDialogState(() {
                                    searchQuery = '';
                                  });
                                },
                                icon: const Icon(Icons.close_rounded, size: 18),
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                                splashRadius: 18,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      child: filteredItems.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.inbox_rounded,
                                      size: 36,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.4),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      AppStrings.tr('no_notif'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 360),
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: filteredItems.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 16),
                                itemBuilder: (_, index) {
                                  final item = filteredItems[index];
                                  final isRead = _readNotificationIds.contains(
                                    item['id'] as String,
                                  );
                                  final color = item['color'] as Color;
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isRead
                                          ? Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest
                                                .withOpacity(0.2)
                                          : Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isRead
                                            ? Theme.of(
                                                context,
                                              ).dividerColor.withOpacity(0.3)
                                            : Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.2),
                                        width: isRead ? 1 : 1.5,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        _markNotificationRead(
                                          item['id'] as String,
                                          onAfter: () => setDialogState(() {}),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(14),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (!isRead)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                right: 8,
                                                top: 2,
                                              ),
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withOpacity(0.3),
                                                    blurRadius: 4,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.15),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Icon(
                                              item['icon'] as IconData,
                                              color: isRead
                                                  ? color.withOpacity(0.7)
                                                  : color,
                                              size: 18,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item['title'] as String,
                                                  style: TextStyle(
                                                    fontWeight: isRead
                                                        ? FontWeight.w400
                                                        : FontWeight.w700,
                                                    fontSize: 13,
                                                    color: Theme.of(
                                                      context,
                                                    ).colorScheme.onSurface,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  item['detail'] as String,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withOpacity(0.7),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest
                                                  .withOpacity(0.5),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              item['time'] as String,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: isRead
                                                    ? FontWeight.w500
                                                    : FontWeight.w600,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withOpacity(0.65),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortChip({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final color = Theme.of(context).colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? color.withOpacity(0.4)
                : Theme.of(context).dividerColor.withOpacity(0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: isActive
                  ? color
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? color
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AdminHomepageWeb extends StatefulWidget {
  final Map<String, dynamic>? loginData;

  const AdminHomepageWeb({super.key, this.loginData});

  @override
  State<AdminHomepageWeb> createState() => _AdminHomepageWebState();
}

class _AdminHomepageWebState extends State<AdminHomepageWeb> {
  int _selectedIndex = 0;
  final bool _isDrawerOpen = true;

  // ──────────────── ADMIN DASHBOARD BUILD ────────────────
  // Renders responsive dashboard with sidebar, stats, and employee management
  @override
  Widget build(BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('WorkSmart - Admin Dashboard'),
        elevation: 2,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Row(
                children: [
                  Icon(Icons.account_circle, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text('Admin User'),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          if (isWideScreen)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people),
                  label: Text('Users'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.assignment),
                  label: Text('Reports'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.event),
                  label: Text('Leaves'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
            ),
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Page Title
                    Text(
                      'Dashboard',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome back! Here\'s what\'s happening with your organization today.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 32),

                    // Stats Overview
                    _buildStatsOverview(context, isWideScreen),
                    const SizedBox(height: 32),

                    // Main Content Grid
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              _buildQuickActionsSection(context),
                              const SizedBox(height: 24),
                              _buildEmployeeStatsSection(context),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Right Column
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              _buildRecentActivitiesSection(context),
                              const SizedBox(height: 24),
                              _buildUpcomingEventsSection(context),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isWideScreen
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Users',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment),
                  label: 'Reports',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildStatsOverview(BuildContext context, bool isWideScreen) {
    final stats = [
      {
        'title': 'Total Employees',
        'value': '1,250',
        'icon': Icons.people,
        'color': Colors.blue,
      },
      {
        'title': 'Active Today',
        'value': '892',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'title': 'Leaves Pending',
        'value': '45',
        'icon': Icons.calendar_today,
        'color': Colors.orange,
      },
      {
        'title': 'Attendance Rate',
        'value': '96.5%',
        'icon': Icons.trending_up,
        'color': Colors.purple,
      },
    ];

    return GridView.count(
      crossAxisCount: isWideScreen ? 4 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: stats.map((stat) {
        return _buildStatCard(
          context,
          stat['title'] as String,
          stat['value'] as String,
          stat['icon'] as IconData,
          stat['color'] as Color,
        );
      }).toList(),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildActionButton(
                  context,
                  'Manage Users',
                  Icons.person_add,
                  () {},
                ),
                _buildActionButton(
                  context,
                  'View Reports',
                  Icons.assessment,
                  () {},
                ),
                _buildActionButton(
                  context,
                  'Leave Requests',
                  Icons.mail,
                  () {},
                ),
                _buildActionButton(context, 'Settings', Icons.tune, () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeStatsSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Employee Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildStatRow('Present Today', '892', 0.89),
            const SizedBox(height: 16),
            _buildStatRow('Absent Today', '150', 0.15),
            const SizedBox(height: 16),
            _buildStatRow('On Leave', '208', 0.21),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String title, String count, double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(title), Text('$count employees')],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: percentage, minHeight: 8),
        ),
      ],
    );
  }

  Widget _buildRecentActivitiesSection(BuildContext context) {
    final activities = [
      {'user': 'John Doe', 'action': 'Checked in', 'time': '2 min ago'},
      {'user': 'Jane Smith', 'action': 'Requested leave', 'time': '1 hr ago'},
      {'user': 'Mike Johnson', 'action': 'Checked out', 'time': '3 hrs ago'},
      {
        'user': 'Sarah Williams',
        'action': 'Updated profile',
        'time': '5 hrs ago',
      },
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activities',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity['user'] as String,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        activity['action'] as String,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity['time'] as String,
                        style: Theme.of(
                          context,
                        ).textTheme.labelSmall?.copyWith(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEventsSection(BuildContext context) {
    final events = [
      {'date': 'Feb 14', 'event': 'Team Meeting'},
      {'date': 'Feb 20', 'event': 'Performance Review'},
      {'date': 'Feb 28', 'event': 'Company Outing'},
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upcoming Events',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final event = events[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          event['date'] as String,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          event['event'] as String,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

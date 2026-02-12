import 'package:flutter/material.dart';

class AdminHomepage extends StatefulWidget {
  final Map<String, dynamic>? loginData;

  const AdminHomepage({super.key, this.loginData});

  @override
  State<AdminHomepage> createState() => _AdminHomepageState();
}

class _AdminHomepageState extends State<AdminHomepage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Welcome Admin',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(context),
              const SizedBox(height: 24),

              // Stats Cards
              Text(
                'Overview',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              _buildStatsGrid(context),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              _buildQuickActionsGrid(context),
              const SizedBox(height: 24),

              // Recent Activities
              Text(
                'Recent Activities',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              _buildRecentActivities(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
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
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard Summary',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Monitor and manage your organization',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final stats = [
      {'title': 'Total Users', 'value': '1,250', 'icon': Icons.people},
      {'title': 'Active Today', 'value': '892', 'icon': Icons.check_circle},
      {'title': 'Leaves Pending', 'value': '45', 'icon': Icons.calendar_today},
      {'title': 'Attendance Rate', 'value': '96.5%', 'icon': Icons.trending_up},
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: stats.map((stat) {
        return StatCard(
          title: stat['title'] as String,
          value: stat['value'] as String,
          icon: stat['icon'] as IconData,
        );
      }).toList(),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      {'title': 'Manage Users', 'icon': Icons.person_add},
      {'title': 'View Reports', 'icon': Icons.assessment},
      {'title': 'Leave Requests', 'icon': Icons.mail},
      {'title': 'System Settings', 'icon': Icons.tune},
      {'title': 'Attendance', 'icon': Icons.access_time},
      {'title': 'Announcements', 'icon': Icons.notifications},
    ];

    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: actions.map((action) {
        return QuickActionCard(
          title: action['title'] as String,
          icon: action['icon'] as IconData,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${action['title']} clicked')),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildRecentActivities(BuildContext context) {
    final activities = [
      {'user': 'John Doe', 'action': 'Checked in', 'time': '2 minutes ago'},
      {'user': 'Jane Smith', 'action': 'Requested leave', 'time': '1 hour ago'},
      {'user': 'Mike Johnson', 'action': 'Checked out', 'time': '3 hours ago'},
      {
        'user': 'Sarah Williams',
        'action': 'Updated profile',
        'time': '5 hours ago',
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final activity = activities[index];
        return ActivityListTile(
          userName: activity['user'] as String,
          action: activity['action'] as String,
          time: activity['time'] as String,
        );
      },
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityListTile extends StatelessWidget {
  final String userName;
  final String action;
  final String time;

  const ActivityListTile({
    super.key,
    required this.userName,
    required this.action,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(userName[0], style: const TextStyle(color: Colors.white)),
      ),
      title: Text(userName),
      subtitle: Text(action),
      trailing: Text(time, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

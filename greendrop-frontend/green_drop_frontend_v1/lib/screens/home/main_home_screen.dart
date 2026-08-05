import 'package:flutter/material.dart';
import '../auth/auth_screen.dart';
import '../donations/browse_donations_feed.dart';
import '../donations/create_donation_screen.dart';
import '../events/ngo_events_feed.dart';
import '../ngo/ngo_directory_screen.dart';
import '../ngo/ngo_requirements_screen.dart';
import '../ngo/ngo_achievements_screen.dart';
import '../ngo/edit_ngo_profile_screen.dart';
import '../donor/edit_donor_profile_screen.dart';
import '../disaster/disaster_mode_manager_screen.dart';
import '../dashboard/impact_dashboard_screen.dart';
import '../map/donations_map_screen.dart';
import '../recycle/recycle_tier_screen.dart';
import '../chatbot/chatbot_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class MainHomeScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const MainHomeScreen({super.key, required this.user});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final role = widget.user['role'] ?? 'DONOR';
    final isNgo = role == 'NGO';
    final isDonor = role == 'DONOR';
    final photoUrl = widget.user['profilePhotoUrl'] ?? '';

    final screens = [
      BrowseDonationsFeed(user: widget.user),
      ImpactDashboardScreen(user: widget.user),
      DonationsMapScreen(user: widget.user),
      NgoRequirementsScreen(user: widget.user),
      NgoDirectoryScreen(user: widget.user),
      NgoAchievementsScreen(user: widget.user),
      RecycleTierScreen(user: widget.user),
      NgoEventsFeed(user: widget.user),
      if (isDonor) CreateDonationScreen(user: widget.user),
      if (isNgo) DisasterModeManagerScreen(user: widget.user),
      const ChatbotScreen(),
      if (role == 'ADMIN') const AdminDashboardScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('🌱 GreenDrop', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                role,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                widget.user['name'] ?? 'User',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              accountEmail: Text(widget.user['email'] ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: photoUrl.startsWith('http') ? NetworkImage(photoUrl) : null,
                child: !photoUrl.startsWith('http')
                    ? Text(
                        widget.user['name']?[0] ?? 'U',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      )
                    : null,
              ),
              decoration: BoxDecoration(color: Colors.green.shade800),
            ),
            ListTile(
              leading: const Icon(Icons.shield, color: Colors.green),
              title: Text('Account Role: $role'),
            ),
            if (isDonor)
              ListTile(
                leading: const Icon(Icons.person, color: Colors.green),
                title: const Text('Edit Account Profile & Details'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => EditDonorProfileScreen(user: widget.user),
                    ),
                  );
                },
              ),
            if (isNgo)
              ListTile(
                leading: const Icon(Icons.edit_note, color: Colors.green),
                title: const Text('Edit NGO Public Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => EditNgoProfileScreen(user: widget.user),
                    ),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.eco, color: Colors.green),
              title: const Text('Environmental Impact Dashboard'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.map, color: Colors.green),
              title: const Text('Interactive Map & Route Planner'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.fact_check, color: Colors.green),
              title: const Text('NGO Structured Demands Board'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search, color: Colors.green),
              title: const Text('Verified NGO Search Directory'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 4);
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events, color: Colors.green),
              title: const Text('NGO Impact & Achievements Showcase'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 5);
              },
            ),
            ListTile(
              leading: const Icon(Icons.recycling, color: Colors.teal),
              title: const Text('Zero-Waste Recycle / Upcycle Tier'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 6);
              },
            ),
            if ((widget.user['warningCount'] ?? 0) > 0)
              ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: Text('Account Warnings: ${widget.user['warningCount']}'),
                subtitle: Text(
                  'Last reason: ${widget.user['lastWarningReason'] ?? ''}',
                ),
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (c) => const AuthScreen()),
              ),
            )
          ],
        ),
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.inventory_2),
            label: 'Donations',
          ),
          const NavigationDestination(
            icon: Icon(Icons.eco),
            label: 'Impact',
          ),
          const NavigationDestination(
            icon: Icon(Icons.map),
            label: 'Map View',
          ),
          const NavigationDestination(
            icon: Icon(Icons.fact_check),
            label: 'Demands',
          ),
          const NavigationDestination(
            icon: Icon(Icons.search),
            label: 'NGO Search',
          ),
          const NavigationDestination(
            icon: Icon(Icons.emoji_events),
            label: 'Showcase',
          ),
          const NavigationDestination(
            icon: Icon(Icons.recycling),
            label: 'Zero-Waste',
          ),
          const NavigationDestination(
            icon: Icon(Icons.campaign),
            label: 'Campaigns',
          ),
          if (isDonor)
            const NavigationDestination(
              icon: Icon(Icons.add_circle),
              label: 'Post Item',
            ),
          if (isNgo)
            const NavigationDestination(
              icon: Icon(Icons.warning_amber),
              label: 'Disaster Mode',
            ),
          const NavigationDestination(
            icon: Icon(Icons.smart_toy),
            label: 'AI HelpBot',
          ),
          if (role == 'ADMIN')
            const NavigationDestination(
              icon: Icon(Icons.admin_panel_settings),
              label: 'Admin Panel',
            ),
        ],
      ),
    );
  }
}

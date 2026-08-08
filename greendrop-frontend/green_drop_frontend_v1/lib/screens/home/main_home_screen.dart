import 'package:flutter/material.dart';
import '../../widgets/greendrop_native_logo.dart';
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
  final int initialIndex;
  const MainHomeScreen({super.key, required this.user, this.initialIndex = 0});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  late int _currentIndex;
  final Map<int, Widget> _loadedScreens = {};
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadedScreens[_currentIndex] = RepaintBoundary(
      child: _getOrConstructScreen(_currentIndex),
    );
  }

  Widget _getOrConstructScreen(int index) {
    if (_loadedScreens.containsKey(index)) {
      return _loadedScreens[index]!;
    }

    final role = widget.user['role'] ?? 'DONOR';
    final isNgo = role == 'NGO';
    final isAdmin = role == 'ADMIN';

    late Widget screen;
    switch (index) {
      case 0:
        screen = BrowseDonationsFeed(user: widget.user);
        break;
      case 1:
        screen = NgoEventsFeed(user: widget.user);
        break;
      case 2:
        screen = DonationsMapScreen(user: widget.user);
        break;
      case 3:
        screen = ImpactDashboardScreen(user: widget.user);
        break;
      case 4:
        screen = NgoRequirementsScreen(user: widget.user);
        break;
      case 5:
        screen = NgoDirectoryScreen(user: widget.user);
        break;
      case 6:
        screen = NgoAchievementsScreen(user: widget.user);
        break;
      case 7:
        screen = RecycleTierScreen(user: widget.user);
        break;
      case 8:
        screen = isNgo
            ? DisasterModeManagerScreen(user: widget.user)
            : BrowseDonationsFeed(user: widget.user);
        break;
      case 9:
        screen = const ChatbotScreen();
        break;
      case 10:
        screen = isAdmin ? const AdminDashboardScreen() : BrowseDonationsFeed(user: widget.user);
        break;
      default:
        screen = BrowseDonationsFeed(user: widget.user);
    }

    final wrappedScreen = RepaintBoundary(child: screen);
    _loadedScreens[index] = wrappedScreen;
    return wrappedScreen;
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.user['role'] ?? 'DONOR';
    final isNgo = role == 'NGO';
    final isDonor = role == 'DONOR';
    final isAdmin = role == 'ADMIN';
    final photoUrl = widget.user['profilePhotoUrl'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const GreenDropNativeLogo(size: 34, animate: false),
            const SizedBox(width: 8),
            const Text('GreenDrop', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),


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

      // SIDE DRAWER: FULL MENU
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
            SwitchListTile(
              secondary: Icon(
                _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
                color: _notificationsEnabled ? Colors.green : Colors.grey,
              ),
              title: const Text('In-App Notifications'),
              subtitle: Text(_notificationsEnabled ? 'Notifications Enabled' : 'Notifications Muted'),
              value: _notificationsEnabled,
              onChanged: (val) {
                setState(() => _notificationsEnabled = val);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: val ? Colors.green : Colors.grey.shade800,
                    content: Text(val ? '🔔 In-App Notifications Enabled!' : '🔕 In-App Notifications Muted.'),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.fact_check, color: Colors.green),
              title: const Text('📋 NGO Structured Demands Board'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 4);
              },
            ),
            ListTile(
              leading: const Icon(Icons.search, color: Colors.green),
              title: const Text('Verified NGO Search Directory'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 5);
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events, color: Colors.green),
              title: const Text('NGO Impact & Achievements Showcase'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 6);
              },
            ),
            ListTile(
              leading: const Icon(Icons.recycling, color: Colors.teal),
              title: const Text('Zero-Waste Recycle / Upcycle Tier'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 7);
              },
            ),
            if (isNgo)
              ListTile(
                leading: const Icon(Icons.warning_amber, color: Colors.red),
                title: const Text('Disaster Relief Broadcast Manager'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 8);
                },
              ),
            ListTile(
              leading: const Icon(Icons.smart_toy, color: Colors.green),
              title: const Text('AI HelpBot'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 9);
              },
            ),
            if (isAdmin)
              ListTile(
                leading: const Icon(Icons.admin_panel_settings, color: Colors.purple),
                title: const Text('Admin Panel'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _currentIndex = 10);
                },
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


      body: IndexedStack(
        index: _currentIndex < 11 ? _currentIndex : 0,
        children: List.generate(11, (i) {
          if (_currentIndex == i || _loadedScreens.containsKey(i)) {
            return _getOrConstructScreen(i);
          }
          return const SizedBox.shrink();
        }),
      ),


      // FLOATING ACTION BUTTON FOR DONORS: STRICTLY ON MAIN HOME DASHBOARD ONLY (INDEX 0)
      floatingActionButton: (isDonor && _currentIndex == 0)
          ? FloatingActionButton.extended(
              backgroundColor: Colors.green.shade800,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Post Item', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () async {
                final newItem = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (c) => CreateDonationScreen(user: widget.user),
                  ),
                );
                if (newItem != null) {
                  setState(() {
                    _currentIndex = 0;
                    _loadedScreens.remove(0);
                    _loadedScreens.remove(3);
                  });
                }
              },
            )
          : null,


      // 4 BOTTOM NAVIGATION ICONS: HOME, CAMPAIGNS, MAP, IMPACT
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex > 3 ? 0 : _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Colors.green),
            label: 'Home Feed',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign, color: Colors.green),
            label: 'Campaigns',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map, color: Colors.green),
            label: 'Map & Routes',
          ),
          NavigationDestination(
            icon: Icon(Icons.eco_outlined),
            selectedIcon: Icon(Icons.eco, color: Colors.green),
            label: 'Impact Stats',
          ),
        ],
      ),
    );
  }
}


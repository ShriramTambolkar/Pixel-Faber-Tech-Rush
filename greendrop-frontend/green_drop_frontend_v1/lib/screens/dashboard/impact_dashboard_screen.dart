import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ImpactDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const ImpactDashboardScreen({super.key, required this.user});

  @override
  State<ImpactDashboardScreen> createState() => _ImpactDashboardScreenState();
}

class _ImpactDashboardScreenState extends State<ImpactDashboardScreen> {
  List<dynamic> _myDonations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyActivity();
  }

  Future<void> _fetchMyActivity() async {
    try {
      final res = await ApiService.get('/donations/nearby');
      if (res.statusCode == 200) {
        final all = jsonDecode(res.body)['data'] as List<dynamic>;
        final userId = widget.user['_id'];
        final role = widget.user['role'] ?? 'DONOR';

        setState(() {
          if (role == 'DONOR') {
            _myDonations = all.where((d) => d['donorId'] == userId).toList();
          } else if (role == 'NGO') {
            _myDonations = all.where((d) => d['requestedByNgoId'] == userId).toList();
          } else {
            _myDonations = all;
          }
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.user['role'] ?? 'DONOR';
    final totalCount = _myDonations.length;
    final completedCount = _myDonations.where((d) => d['status'] == 'COMPLETED' || d['status'] == 'COLLECTED').length;
    
    double totalWeight = 0;
    for (var d in _myDonations) {
      totalWeight += (d['weightKg'] as num?)?.toDouble() ?? 2.0;
    }
    
    final co2Saved = (totalWeight * 2.5).toStringAsFixed(1);
    final waterSavedLiters = (totalCount * 120).toStringAsFixed(0);
    final landfillDivertedItems = totalCount;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // USER IMPACT HEADER CARD
            Card(
              color: Colors.green.shade800,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.eco, color: Colors.green.shade800, size: 30),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.user['name']}’s Eco-Impact',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                role == 'DONOR'
                                    ? 'Zero-Waste Donor & Community Benefactor'
                                    : 'NGO Environmental Relief Partner',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const Divider(color: Colors.white30, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricTile('🗑️ Items Saved', '$landfillDivertedItems', 'Landfill Diverted'),
                        _buildMetricTile('🌍 CO₂ Reduced', '$co2Saved kg', 'Emissions Saved'),
                        _buildMetricTile('💧 Water Saved', '$waterSavedLiters L', 'Conserved'),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ECO BADGES & MILESTONES
            const Text(
              '🏅 Unlocked Eco-Badges & Achievements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildBadgeCard('🌱 Eco Novice', 'First donation made', true),
                  _buildBadgeCard('🌿 Waste Defender', '5+ items saved', totalCount >= 5),
                  _buildBadgeCard('🌳 Carbon Hero', '25+ kg CO₂ saved', double.parse(co2Saved) >= 25),
                  _buildBadgeCard('👑 Zero Waste Champion', '10+ completed handovers', completedCount >= 10),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // DONATION HISTORY & ACTIVITY DASHBOARD LOG
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📜 Activity History & History Log',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(
                    'Total Activity: $totalCount',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _myDonations.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                            'No activity history logged yet.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _myDonations.length,
                        itemBuilder: (c, i) {
                          final item = _myDonations[i];
                          final status = item['status'] ?? 'AVAILABLE';
                          final title = item['title'] ?? 'Item';
                          final category = item['category'] ?? 'General';
                          final weight = item['weightKg'] ?? 1.0;

                          Color statusColor = Colors.green;
                          if (status == 'REQUESTED') statusColor = Colors.orange;
                          if (status == 'ACCEPTED') statusColor = Colors.blue;
                          if (status == 'COMPLETED' || status == 'COLLECTED') statusColor = Colors.purple;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: statusColor.withValues(alpha: 0.1),
                                child: Icon(Icons.inventory, color: statusColor),
                              ),
                              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('Category: $category • Weight: ${weight}kg'),
                              trailing: Chip(
                                backgroundColor: statusColor.withValues(alpha: 0.1),
                                side: BorderSide(color: statusColor),
                                label: Text(
                                  status,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, String subtitle) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(String name, String desc, bool isUnlocked) {
    return Card(
      color: isUnlocked ? Colors.green.shade50 : Colors.grey.shade100,
      margin: const EdgeInsets.only(right: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(
              isUnlocked ? Icons.stars : Icons.lock,
              color: isUnlocked ? Colors.amber.shade800 : Colors.grey,
              size: 32,
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isUnlocked ? Colors.green.shade900 : Colors.grey,
              ),
            ),
            Text(
              desc,
              style: TextStyle(fontSize: 10, color: isUnlocked ? Colors.black87 : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

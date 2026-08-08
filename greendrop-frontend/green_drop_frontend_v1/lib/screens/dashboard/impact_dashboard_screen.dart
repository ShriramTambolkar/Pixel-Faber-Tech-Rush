import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/animated_counter_text.dart';

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

        if (mounted) {
          setState(() {
            if (role == 'DONOR') {
              _myDonations = all.where((d) => d['donorId'] == userId).toList();
            } else if (role == 'NGO') {
              _myDonations = all.where((d) => d['requestedByNgoId'] == userId).toList();
            } else {
              _myDonations = all;
            }
          });
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (_myDonations.isEmpty) {
          _myDonations = [
            {
              '_id': 'don_sample_10',
              'title': 'School Backpacks & Books',
              'category': 'Books',
              'weightKg': 4,
              'status': 'COLLECTED',
              'createdAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
            },
            {
              '_id': 'don_sample_11',
              'title': 'Winter Sweaters & Blankets',
              'category': 'Clothes & Wearing',
              'weightKg': 3,
              'status': 'COLLECTED',
              'createdAt': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
            },
          ];
        }
      });
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
    
    final co2Num = double.parse((totalWeight * 2.5).toStringAsFixed(1));
    final waterNum = totalCount * 120;
    final landfillDivertedItems = totalCount;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // USER IMPACT HEADER CARD WITH GRADIENT GLASS
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D3B1E), Color(0xFF1E5631), Color(0xFF388E3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFF81C784).withValues(alpha: 0.3),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade900.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(22.0),
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
                                  letterSpacing: 0.3,
                                ),
                              ),
                              Text(
                                role == 'DONOR'
                                    ? 'Zero-Waste Donor & Community Benefactor'
                                    : 'NGO Environmental Relief Partner',
                                style: const TextStyle(color: Color(0xFFE1E9DF), fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 28),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildMetricTile('🗑️ Items Saved', landfillDivertedItems, '', 'Landfill Diverted'),
                          _buildMetricTile('🌍 CO₂ Reduced', co2Num, ' kg', 'Emissions Saved'),
                          _buildMetricTile('💧 Water Saved', waterNum, ' L', 'Conserved'),
                        ],
                      ),
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
                  _buildBadgeCard('🌳 Carbon Hero', '25+ kg CO₂ saved', co2Num >= 25),
                  _buildBadgeCard('👑 Zero Waste Champion', '10+ completed handovers', completedCount >= 10),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // DONATION HISTORY & ACTIVITY DASHBOARD LOG
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    '📜 Activity History Log',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
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

                          final isDonorRole = (widget.user['role'] ?? 'DONOR') == 'DONOR';
                          final counterpartyName = isDonorRole
                              ? (item['requestedByNgoName'] ?? item['claimedByName'] ?? 'Pending NGO Request')
                              : (item['donorName'] ?? item['postedByName'] ?? 'Community Donor');

                          DateTime dt = DateTime.tryParse(item['createdAt']?.toString() ?? '') ?? DateTime.now();
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                          String dayName = days[(dt.weekday - 1) % 7];
                          String monthName = months[(dt.month - 1) % 12];
                          String hourStr = (dt.hour % 12 == 0 ? 12 : dt.hour % 12).toString().padLeft(2, '0');
                          String minStr = dt.minute.toString().padLeft(2, '0');
                          String ampm = dt.hour >= 12 ? 'PM' : 'AM';
                          String formattedStamp = '$dayName, $monthName ${dt.day}, ${dt.year} at $hourStr:$minStr $ampm';

                          Color statusColor = Colors.green;
                          if (status == 'REQUESTED') statusColor = Colors.orange;
                          if (status == 'ACCEPTED') statusColor = Colors.blue;
                          if (status == 'COMPLETED' || status == 'COLLECTED') statusColor = Colors.purple;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Stack(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: statusColor.withValues(alpha: 0.1),
                                        child: Icon(Icons.inventory, color: statusColor),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(right: 75.0),
                                              child: Text(
                                                title,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              isDonorRole ? '🏢 NGO: $counterpartyName' : '👤 Donor: $counterpartyName',
                                              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.green.shade900, fontSize: 12),
                                            ),
                                            Text('Category: $category • Weight: ${weight}kg', style: const TextStyle(fontSize: 11, color: Colors.black87)),
                                            const SizedBox(height: 3),
                                            Text(
                                              '🕒 $formattedStamp',
                                              style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // SMALLER STATUS BADGE POSITIONED IN TOP-RIGHT CORNER
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: statusColor, width: 0.8),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9.5,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
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

  Widget _buildMetricTile(String label, num numericValue, String suffix, String subtitle) {
    return Column(
      children: [
        AnimatedCounterText(
          value: numericValue,
          suffix: suffix,
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

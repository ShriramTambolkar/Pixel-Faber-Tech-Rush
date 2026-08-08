import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class RecycleTierScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const RecycleTierScreen({super.key, required this.user});

  @override
  State<RecycleTierScreen> createState() => _RecycleTierScreenState();
}

class _RecycleTierScreenState extends State<RecycleTierScreen> {
  List<dynamic> _recycleItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecycleItems();
  }

  Future<void> _fetchRecycleItems() async {
    try {
      final res = await ApiService.get('/donations/nearby');
      if (res.statusCode == 200) {
        final all = jsonDecode(res.body)['data'] as List<dynamic>;
        setState(() {
          _recycleItems = all.where((item) {
            final condition = (item['condition'] ?? '').toString().toLowerCase();
            final category = (item['category'] ?? '').toString().toLowerCase();
            return condition.contains('worn') ||
                condition.contains('fair') ||
                category.contains('e-waste') ||
                category.contains('scrap') ||
                category.contains('electronics');
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _claimItem(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Claim "${item['title']}" for Recycling / Upcycling?'),
        content: const Text(
          'By claiming this item as a verified Recycler, E-Waste Center, or Upcycling Artist, you divert it 100% from landfills!',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade800),
            onPressed: () {
              Navigator.pop(c);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.teal,
                  content: Text('🎉 Item claimed by Recycler! Zero Landfill Waste achieved!'),
                ),
              );
            },
            child: const Text('Confirm Claim', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AnimatedRecycleBanner(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.teal.shade50,
            child: const Row(
              children: [
                Icon(Icons.recycling, color: Colors.teal),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '♻️ Zero-Waste Recycle & Upcycle Tier: Items too worn out for direct donation are claimed by Textile Recyclers, E-Waste Hubs & Upcycling Artists.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _recycleItems.isEmpty
                    ? const Center(
                        child: Text(
                          'No items currently flagged for recycling. All active items are in good condition!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _recycleItems.length,
                        itemBuilder: (c, i) {
                          final item = _recycleItems[i];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['title'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Chip(
                                        backgroundColor: Colors.tealAccent,
                                        label: Text(
                                          'RECYCLE / UPCYCLE',
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    ],
                                  ),
                                  Text('Category: ${item['category']} • Condition: ${item['condition']}'),
                                  Text('👤 Donor: ${item['donorName']}'),
                                  const SizedBox(height: 10),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal.shade800,
                                    ),
                                    icon: const Icon(Icons.recycling, color: Colors.white, size: 16),
                                    label: const Text(
                                      'Claim for Textile / E-Waste Upcycling',
                                      style: TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                    onPressed: () => _claimItem(item),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class AnimatedRecycleBanner extends StatefulWidget {
  const AnimatedRecycleBanner({super.key});

  @override
  State<AnimatedRecycleBanner> createState() => _AnimatedRecycleBannerState();
}

class _AnimatedRecycleBannerState extends State<AnimatedRecycleBanner> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.shade900,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: Column(
        children: [
          RotationTransition(
            turns: _ctrl,
            child: const Icon(Icons.recycling, size: 52, color: Colors.tealAccent),
          ),
          const SizedBox(height: 10),
          const Text(
            'Feature under development, connecting donors and organisers to waste collection vendors, ensuring zero waste',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

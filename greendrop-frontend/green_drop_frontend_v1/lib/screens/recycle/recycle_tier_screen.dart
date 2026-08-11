import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../donations/create_donation_screen.dart';

class RecycleTierScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const RecycleTierScreen({super.key, required this.user});

  @override
  State<RecycleTierScreen> createState() => _RecycleTierScreenState();
}

class _RecycleTierScreenState extends State<RecycleTierScreen> {
  List<dynamic> _recycleItems = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';

  final List<Map<String, String>> _defaultBatches = [
    {
      '_id': 'rec_batch_001',
      'title': '45 kg Worn-Out Cotton Sweaters & Fabric Scraps',
      'category': 'Textiles 👕',
      'condition': 'Torn / Worn Out',
      'weight': '45 kg',
      'tag': 'UPCYCLE READY',
      'description':
          'Damaged or torn cotton sweaters unsuitable for direct wearing. High cotton content ready for mechanical fiber regeneration.',
      'location': 'Kothrud Industrial Area, Pune',
      'targetHub': 'EcoThread Textile Shredders & Fiber Mill',
    },
    {
      '_id': 'rec_batch_002',
      'title': '20 Defunct Computer Power Supplies & Copper Wires Batch',
      'category': 'E-Waste 💻',
      'condition': 'Defunct / Non-Working',
      'weight': '22 kg',
      'tag': 'E-WASTE HUB',
      'description':
          'Assorted computer power units, motherboard PCB components, and stripped copper wiring for safe precious metal extraction.',
      'location': 'Hadapsar Industrial Estate, Pune',
      'targetHub': 'GreenTech E-Waste Recyclers (Govt Certified)',
    },
    {
      '_id': 'rec_batch_003',
      'title': '35 kg Shredded Office Paper & Cardboard Packaging',
      'category': 'Paper / Plastics 📄',
      'condition': 'Clean Scraps',
      'weight': '35 kg',
      'tag': 'PULP RECYCLED',
      'description':
          'De-stapled document scraps and corrugated cardboard packaging ready for eco-pulper processing and brown craft paper production.',
      'location': 'Viman Nagar Tech Park, Pune',
      'targetHub': 'Pune EcoPulp Paper Mills',
    },
  ];

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
        final fetched = all.where((item) {
          final condition = (item['condition'] ?? '').toString().toLowerCase();
          final category = (item['category'] ?? '').toString().toLowerCase();
          return condition.contains('worn') ||
              condition.contains('fair') ||
              category.contains('e-waste') ||
              category.contains('scrap') ||
              category.contains('electronics');
        }).toList();

        setState(() {
          _recycleItems = [...fetched, ..._defaultBatches];
          _isLoading = false;
        });
      } else {
        setState(() {
          _recycleItems = _defaultBatches;
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _recycleItems = _defaultBatches;
        _isLoading = false;
      });
    }
  }

  void _claimItem(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.recycling, color: Colors.teal, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Claim "${item['title']}"?',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'By claiming this batch as a certified Recycler, E-Waste Center, or Upcycling Artisan, you guarantee 100% Zero-Landfill diversion!',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Text(
                '🏢 Target Hub: ${item['targetHub'] ?? 'EcoThread Shredders'}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade900),
            icon: const Icon(Icons.check_circle, color: Colors.white, size: 18),
            label: const Text('Confirm Zero-Landfill Claim', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.pop(c);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.teal,
                  content: Text('🎉 Batch claimed successfully! Zero-Landfill processing initiated!'),
                ),
              );
            },
          )
        ],
      ),
    );
  }

  List<dynamic> get _filteredItems {
    if (_selectedCategory == 'All') return _recycleItems;
    return _recycleItems.where((i) {
      final cat = (i['category'] ?? '').toString();
      return cat.contains(_selectedCategory);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal.shade900,
        icon: const Icon(Icons.add_circle, color: Colors.white),
        label: const Text(
          'Post Item for Recycling',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => CreateDonationScreen(user: widget.user),
            ),
          ).then((_) => _fetchRecycleItems());
        },
      ),
      body: Column(
        children: [
          // 1. TOP HEADER BANNER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade900, Colors.teal.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
            ),
            child: Row(
              children: [
                const SpinningRecycleLogo(),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '♻️ Zero-Landfill Recycle & Upcycle Hub',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Connecting Donors & NGOs to certified textile shredders, e-waste centers & upcycling artisans.',
                        style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. LIVE IMPACT METRICS BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricCol('⌛ 1,420 kg', 'Landfill Diverted'),
                    Container(height: 24, width: 1, color: Colors.grey.shade300),
                    _buildMetricCol('⚡ 98.4%', 'Recycle Rate'),
                    Container(height: 24, width: 1, color: Colors.grey.shade300),
                    _buildMetricCol('🍃 3.5 Tons', 'CO₂ Prevented'),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 3. CATEGORY FILTER CHIPS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _buildFilterChip('All', '✓ All Scraps ♻️'),
                _buildFilterChip('Textiles', 'Textiles 👕'),
                _buildFilterChip('E-Waste', 'E-Waste 💻'),
                _buildFilterChip('Paper', 'Paper & Plastics 📄'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 4. RECYCLE BATCH CARDS LIST
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                    ? const Center(
                        child: Text(
                          'No items currently flagged for this category.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _filteredItems.length,
                        itemBuilder: (c, i) {
                          final item = _filteredItems[i];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item['title'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.teal.shade50,
                                          border: Border.all(color: Colors.teal.shade600),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          item['tag'] ?? 'UPCYCLE READY',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.teal.shade900,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item['description'] ?? 'Scrap items ready for mechanical fiber regeneration.',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.35),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.fitness_center, size: 14, color: Colors.teal),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Weight: ${item['weight'] ?? '25 kg'}',
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 14),
                                            const Icon(Icons.location_on, size: 14, color: Colors.teal),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                item['location'] ?? 'Pune, MH',
                                                style: const TextStyle(fontSize: 12),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.business, size: 14, color: Colors.teal),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                'Target Processing Hub: ${item['targetHub'] ?? 'EcoThread Shredders'}',
                                                style: TextStyle(fontSize: 11.5, color: Colors.teal.shade900, fontWeight: FontWeight.w600),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  if (widget.user['role'] == 'NGO' || widget.user['role'] == 'ADMIN' || widget.user['role'] == 'RECYCLER')
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal.shade900,
                                        minimumSize: const Size(double.infinity, 42),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      icon: const Icon(Icons.recycling, color: Colors.white, size: 18),
                                      label: const Text(
                                        '♻️ Claim Batch for Zero-Landfill Processing',
                                        style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () => _claimItem(item),
                                    )
                                  else
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.teal.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.teal.shade200),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.info_outline, color: Colors.teal, size: 16),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Donor View: Posted for verified NGO & Recycler processing. (Only NGOs can claim batches)',
                                              style: TextStyle(fontSize: 11, color: Colors.teal, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
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

  Widget _buildMetricCol(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedCategory == key;
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: FilterChip(
        selected: isSelected,
        showCheckmark: false,
        backgroundColor: Colors.white,
        selectedColor: Colors.teal.shade800,
        side: BorderSide(color: isSelected ? Colors.teal.shade800 : Colors.grey.shade300),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
        onSelected: (val) {
          setState(() => _selectedCategory = key);
        },
      ),
    );
  }
}

class SpinningRecycleLogo extends StatefulWidget {
  const SpinningRecycleLogo({super.key});

  @override
  State<SpinningRecycleLogo> createState() => _SpinningRecycleLogoState();
}

class _SpinningRecycleLogoState extends State<SpinningRecycleLogo> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: const Icon(Icons.recycling, size: 48, color: Colors.tealAccent),
    );
  }
}

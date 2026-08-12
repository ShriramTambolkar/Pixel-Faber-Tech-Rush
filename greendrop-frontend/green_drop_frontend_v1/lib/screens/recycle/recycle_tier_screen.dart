import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'create_recycle_item_screen.dart';

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
          final isRecycle = item['isRecycleItem'] == true;
          final condition = (item['condition'] ?? '').toString().toLowerCase();
          final category = (item['category'] ?? '').toString().toLowerCase();
          return isRecycle ||
              category.contains('recycle') ||
              category.contains('scrap') ||
              category.contains('e-waste') ||
              condition.contains('scrap');
        }).toList();

        if (mounted) {
          setState(() {
            _recycleItems = fetched;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
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
                '📍 Pickup Address: ${item['address']?['formattedAddress'] ?? item['address'] ?? 'Pune'}',
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
                  content: Text('🎉 Batch claimed successfully! Zero-Landfill pickup initiated.'),
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
          'Post Recycling Material',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        onPressed: () async {
          final posted = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (c) => CreateRecycleItemScreen(user: widget.user),
            ),
          );
          if (posted == true) {
            _fetchRecycleItems();
          }
        },
      ),
      body: RefreshIndicator(
        color: Colors.teal.shade900,
        onRefresh: _fetchRecycleItems,
        child: Column(
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
                          'Post scrap, e-waste, textiles & recyclables directly for pickup by verified recyclers & processing hubs.',
                          style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. CATEGORY FILTER CHIPS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  _buildFilterChip('All', '✓ All Materials ♻️'),
                  _buildFilterChip('Paper', 'Paper & Cardboard 📄'),
                  _buildFilterChip('Textiles', 'Textiles 👕'),
                  _buildFilterChip('E-Waste', 'E-Waste 💻'),
                  _buildFilterChip('Plastics', 'Plastics 📦'),
                  _buildFilterChip('Metal', 'Metal Scrap 🔩'),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 3. RECYCLE POSTS LIST (DYNAMIC)
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.recycling_outlined, size: 54, color: Colors.teal.shade200),
                              const SizedBox(height: 12),
                              const Text(
                                'No recycling posts yet.\nTap "Post Recycling Material" to create the first post!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey, fontSize: 13.5, height: 1.4),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filteredItems.length,
                          itemBuilder: (c, i) {
                            final item = _filteredItems[i];
                            final title = item['title'] ?? 'Recyclable Material';
                            final category = item['category'] ?? 'Recycle';
                            final quantity = item['quantity'] ?? '1 lot';
                            final weightKg = item['weightKg'] ?? 1.0;
                            final donorName = item['donorName'] ?? 'User';
                            final addressStr = item['address'] is Map
                                ? item['address']['formattedAddress'] ?? 'Pune, India'
                                : item['address'].toString();
                            final photos = (item['photoUrls'] as List<dynamic>?) ?? [];

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
                                            title,
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
                                            category.replaceAll('Recycle - ', ''),
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.teal.shade900,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Posted by: $donorName',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                    ),
                                    const SizedBox(height: 8),

                                    // PHOTO PREVIEW GALLERY IF AVAILABLE
                                    if (photos.isNotEmpty) ...[
                                      SizedBox(
                                        height: 85,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: photos.length,
                                          itemBuilder: (context, photoIndex) {
                                            final url = photos[photoIndex].toString();
                                            final isNetwork = url.startsWith('http');
                                            return Container(
                                              width: 85,
                                              margin: const EdgeInsets.only(right: 8),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8),
                                                color: Colors.grey.shade200,
                                                image: isNetwork
                                                    ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
                                                    : null,
                                              ),
                                              child: !isNetwork
                                                  ? const Center(child: Icon(Icons.image_outlined, color: Colors.teal))
                                                  : null,
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],

                                    // DETAILS BOX
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
                                                'Est. Weight: ${weightKg}kg  |  Quantity: $quantity',
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on, size: 14, color: Colors.teal),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  'Pickup Address: $addressStr',
                                                  style: const TextStyle(fontSize: 11.5, color: Colors.black87),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // ACTION BUTTON FOR RECYCLERS / NGOS
                                    if (widget.user['role'] == 'RECYCLER' || widget.user['role'] == 'NGO' || widget.user['role'] == 'ADMIN')
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.teal.shade900,
                                          minimumSize: const Size(double.infinity, 42),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        icon: const Icon(Icons.recycling, color: Colors.white, size: 18),
                                        label: const Text(
                                          '♻️ Claim Batch for Processing & Pickup',
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
                                                'Donor View: Posted for verified Recyclers & processing hubs.',
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
      ),
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
      child: const Icon(Icons.recycling, size: 44, color: Colors.tealAccent),
    );
  }
}

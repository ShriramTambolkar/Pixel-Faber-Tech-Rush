import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class NgoAchievementsScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const NgoAchievementsScreen({super.key, required this.user});

  @override
  State<NgoAchievementsScreen> createState() => _NgoAchievementsScreenState();
}

class _NgoAchievementsScreenState extends State<NgoAchievementsScreen> {
  List<dynamic> _achievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final res = await ApiService.get('/ngo/achievements');
      if (res.statusCode == 200) {
        setState(() {
          _achievements = jsonDecode(res.body)['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _showAddDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final metricsCtrl = TextEditingController(text: '5,000+ Meals Served • 1,200 Children Educated');
    final photoCtrl = TextEditingController(
      text: 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=600',
    );

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Post NGO Achievement Showcase'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Achievement Title *',
                  hintText: 'e.g. Annual Winter Relief Campaign 2026',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description & Impact Details *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: metricsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Impact Metrics (e.g., 500 Blankets Distributed)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: photoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Achievement Showcase Photo URL',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800),
            onPressed: () async {
              final navigator = Navigator.of(c);
              final messenger = ScaffoldMessenger.of(context);
              if (titleCtrl.text.trim().isEmpty || descCtrl.text.trim().isEmpty) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Title and description are required!')),
                );
                return;
              }
              final photoUrls = photoCtrl.text.trim().isNotEmpty ? [photoCtrl.text.trim()] : [];
              await ApiService.post('/ngo/achievements', {
                'ngoId': widget.user['_id'],
                'ngoName': widget.user['name'],
                'title': titleCtrl.text,
                'description': descCtrl.text,
                'photoUrls': photoUrls,
                'impactMetrics': metricsCtrl.text,
              });
              navigator.pop();
              messenger.showSnackBar(
                const SnackBar(content: Text('🏆 NGO Achievement published to global showcase!')),
              );
              _fetch();
            },
            child: const Text('Publish Achievement', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Future<void> _delete(String id) async {
    await ApiService.delete('/ngo/achievements/$id');
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.user['role'] ?? 'DONOR';
    final isNgo = role == 'NGO';
    final isAdmin = role == 'ADMIN';

    return Scaffold(
      floatingActionButton: isNgo
          ? FloatingActionButton.extended(
              onPressed: _showAddDialog,
              icon: const Icon(Icons.emoji_events),
              label: const Text('Post Achievement'),
            )
          : null,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            color: Colors.green.shade50,
            child: const Row(
              children: [
                Icon(Icons.military_tech, color: Colors.green),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '🏆 NGO Impact & Achievements Showcase: Explore real social impact, photos, and milestones achieved by non-profits.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _achievements.isEmpty
                    ? const Center(child: Text('No NGO achievements published yet.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _achievements.length,
                        itemBuilder: (c, i) {
                          final a = _achievements[i];
                          final isOwner = a['ngoId'] == widget.user['_id'];
                          final photoUrls = (a['photoUrls'] is List && (a['photoUrls'] as List).isNotEmpty)
                              ? List<String>.from(a['photoUrls'])
                              : ['https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=600'];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(
                                  photoUrls[0],
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    height: 180,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.emoji_events, size: 60, color: Colors.amber),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              a['title'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          if (isOwner || isAdmin)
                                            IconButton(
                                              icon: const Icon(Icons.delete, color: Colors.red),
                                              onPressed: () => _delete(a['_id']),
                                              tooltip: 'Delete Achievement',
                                            )
                                        ],
                                      ),
                                      Text(
                                        '🏢 NGO: ${a['ngoName']}',
                                        style: TextStyle(
                                          color: Colors.green.shade900,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if ((a['impactMetrics'] ?? '').isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Chip(
                                          avatar: const Icon(Icons.star, size: 16, color: Colors.amber),
                                          label: Text(
                                            'Impact: ${a['impactMetrics']}',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Text(a['description'] ?? ''),
                                    ],
                                  ),
                                )
                              ],
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

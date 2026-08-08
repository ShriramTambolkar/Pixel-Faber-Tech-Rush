import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../../widgets/ngo_profile_modal.dart';
import '../../widgets/shimmer_placeholder.dart';

class NgoEventsFeed extends StatefulWidget {
  final Map<String, dynamic> user;
  const NgoEventsFeed({super.key, required this.user});

  @override
  State<NgoEventsFeed> createState() => _NgoEventsFeedState();
}

class _NgoEventsFeedState extends State<NgoEventsFeed> {
  List<dynamic> _events = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final res = await ApiService.get('/events');
      if (res.statusCode == 200) {
        setState(() => _events = jsonDecode(res.body)['data']);
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _openMap(String address) async {
    final query = Uri.encodeComponent(address);
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _cancelEvent(String eventId, String title) async {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Cancel "$title"?'),
        content: const Text('This will cancel and permanently remove the campaign event from the public feed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Keep Event')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final navigator = Navigator.of(c);
              final messenger = ScaffoldMessenger.of(context);
              await ApiService.delete('/events/$eventId');
              navigator.pop();
              messenger.showSnackBar(
                const SnackBar(content: Text('Campaign event cancelled & deleted successfully.')),
              );
              _fetch();
            },
            child: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _showCreateDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: '2026-08-15');
    final timeCtrl = TextEditingController(text: '10:00 AM - 4:00 PM IST');
    final daysCtrl = TextEditingController(text: 'Saturday & Sunday');
    final addrCtrl = TextEditingController(text: 'Deccan Gymkhana, Pune, MH');
    final targetCtrl = TextEditingController();
    final photoCtrl = TextEditingController(
      text: 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=500',
    );

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Publish NGO Campaign Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Campaign Title *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: dateCtrl,
                decoration: const InputDecoration(
                  labelText: 'Event Date (Compulsory) *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: timeCtrl,
                decoration: const InputDecoration(
                  labelText: 'Event Timing (Compulsory) *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: daysCtrl,
                decoration: const InputDecoration(
                  labelText: 'Operating Days (Compulsory) *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: addrCtrl,
                decoration: const InputDecoration(
                  labelText: 'Venue Address *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: targetCtrl,
                decoration: const InputDecoration(
                  labelText: 'Target Goods Needed',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: photoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Cover Photo Link (or pick from device below)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 42),
                  side: BorderSide(color: Colors.green.shade800),
                ),
                icon: const Icon(Icons.photo_library, color: Colors.green),
                label: const Text('🖼️ Pick Cover Image from Device Gallery', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    final picker = ImagePicker();
                    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
                    if (img != null) {
                      final bytes = await img.readAsBytes();
                      photoCtrl.text = 'data:image/png;base64,${base64Encode(bytes)}';
                      messenger.showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.green,
                          content: Text('✅ Cover photo loaded from device gallery!'),
                        ),
                      );
                    }
                  } catch (_) {}
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(c);
              if (titleCtrl.text.trim().isEmpty ||
                  dateCtrl.text.trim().isEmpty ||
                  timeCtrl.text.trim().isEmpty ||
                  daysCtrl.text.trim().isEmpty) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Campaign title, Event Date, Timing, and Operating Days are ALL compulsory!'),
                  ),
                );
                return;
              }
              final res = await ApiService.post('/events', {
                'ngoId': widget.user['_id'],
                'ngoName': widget.user['name'],
                'title': titleCtrl.text,
                'description': descCtrl.text,
                'eventDate': dateCtrl.text,
                'eventTime': timeCtrl.text,
                'eventDays': daysCtrl.text,
                'address': addrCtrl.text,
                'targetItems': targetCtrl.text,
                'bannerPhotoUrl': photoCtrl.text,
              });

              if (res.statusCode == 201) {
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('NGO Campaign published successfully with full schedule!'),
                  ),
                );
                _fetch();
              }
            },
            child: const Text('Publish Campaign', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.user['role'] ?? 'DONOR';
    final isNgo = role == 'NGO';
    final isAdmin = role == 'ADMIN';

    final filtered = _events.where((ev) {
      final title = (ev['title'] ?? '').toString().toLowerCase();
      final ngoName = (ev['ngoName'] ?? '').toString().toLowerCase();
      final target = (ev['targetItems'] ?? '').toString().toLowerCase();
      final address = (ev['address'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return title.contains(query) ||
          ngoName.contains(query) ||
          target.contains(query) ||
          address.contains(query);
    }).toList();

    return Scaffold(
      floatingActionButton: isNgo
          ? FloatingActionButton.extended(
              onPressed: _showCreateDialog,
              icon: const Icon(Icons.campaign),
              label: const Text('Publish New Campaign'),
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: '🔎 Search donation campaigns by title, NGO, or goods...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
          Expanded(
            child: _isLoading
                ? ListView.builder(
                    itemCount: 3,
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (c, i) => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: ShimmerPlaceholder(height: 140, borderRadius: 16),
                    ),
                  )
                : filtered.isEmpty
                ? const Center(child: Text('No active donation campaigns found.'))
                : ListView.builder(
                    itemCount: filtered.length,
                    padding: const EdgeInsets.all(12),
                    itemBuilder: (c, i) {
                      final ev = filtered[i];
                      final isOwner = ev['ngoId'] == widget.user['_id'];
                      final canCancel = isNgo || isAdmin || isOwner;
                      final address = ev['address'] ?? '';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              ev['bannerPhotoUrl'] ?? '',
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                height: 160,
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.campaign, size: 60),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          ev['title'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (canCancel)
                                        IconButton(
                                          icon: const Icon(Icons.delete_forever, color: Colors.red),
                                          onPressed: () => _cancelEvent(ev['_id'], ev['title'] ?? 'Campaign'),
                                          tooltip: 'Cancel & Delete Campaign',
                                        )
                                    ],
                                  ),
                                   Row(
                                     children: [
                                       Text(
                                         '🏢 By: ${ev['ngoName']}',
                                         style: TextStyle(
                                           color: Colors.green.shade800,
                                           fontWeight: FontWeight.bold,
                                         ),
                                       ),
                                       IconButton(
                                         icon: const Icon(Icons.info_outline, color: Colors.green, size: 18),
                                         tooltip: 'View NGO Profile',
                                         onPressed: () {
                                           NgoProfileModal.show(
                                             context,
                                             ev['ngoId'] ?? 'demo_ngo_001',
                                             ev['ngoName'] ?? 'NGO',
                                             currentUser: widget.user,
                                           );
                                         },
                                       ),
                                     ],
                                   ),
                                  const SizedBox(height: 6),

                                  // COMPULSORY DATE, TIME, DAYS BADGES
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      Chip(
                                        avatar: const Icon(Icons.calendar_today, size: 14),
                                        label: Text('Date: ${ev['eventDate'] ?? ev['eventDateTime'] ?? 'Ongoing'}', style: const TextStyle(fontSize: 11)),
                                      ),
                                      Chip(
                                        avatar: const Icon(Icons.access_time, size: 14),
                                        label: Text('Time: ${ev['eventTime'] ?? '10 AM - 5 PM'}', style: const TextStyle(fontSize: 11)),
                                      ),
                                      Chip(
                                        avatar: const Icon(Icons.date_range, size: 14),
                                        label: Text('Days: ${ev['eventDays'] ?? 'Sat & Sun'}', style: const TextStyle(fontSize: 11)),
                                      ),
                                    ],
                                  ),

                                  if (address.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '📍 Venue: $address',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.map,
                                            size: 20,
                                            color: Colors.green,
                                          ),
                                          onPressed: () => _openMap(address),
                                          tooltip: 'View Venue Map',
                                        )
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Text(ev['description'] ?? ''),
                                  const SizedBox(height: 8),
                                  Chip(
                                    avatar: const Icon(Icons.inventory, size: 16),
                                    label: Text('Needed: ${ev['targetItems']}'),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
          )
        ],
      ),
    );
  }
}

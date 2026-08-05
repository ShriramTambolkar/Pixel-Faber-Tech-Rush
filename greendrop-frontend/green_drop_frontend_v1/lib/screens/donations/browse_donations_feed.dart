import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../../widgets/item_details_modal.dart';
import '../../widgets/ngo_profile_modal.dart';
import '../../widgets/qr_collection_modal.dart';
import '../../widgets/report_dialog.dart';
import '../chat/chat_screen.dart';

class BrowseDonationsFeed extends StatefulWidget {
  final Map<String, dynamic> user;
  const BrowseDonationsFeed({super.key, required this.user});

  @override
  State<BrowseDonationsFeed> createState() => _BrowseDonationsFeedState();
}

class _BrowseDonationsFeedState extends State<BrowseDonationsFeed> {
  List<dynamic> _donations = [];
  List<dynamic> _disasters = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final dRes = await ApiService.get('/donations/nearby');
      final disRes = await ApiService.get('/disasters/active');
      if (dRes.statusCode == 200) {
        setState(() => _donations = jsonDecode(dRes.body)['data']);
      }
      if (disRes.statusCode == 200) {
        setState(() => _disasters = jsonDecode(disRes.body)['data']);
      }
    } catch (_) {}
  }

  bool _canEdit(String createdAtStr) {
    try {
      final createdAt = DateTime.parse(createdAtStr);
      return DateTime.now().difference(createdAt).inMinutes < 5;
    } catch (_) {
      return false;
    }
  }

  Future<void> _deleteDonation(String id) async {
    final res = await ApiService.delete('/donations/$id');
    if (res.statusCode == 200) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation deleted successfully')),
      );
      _fetchData();
    }
  }

  void _showEditDialog(Map<String, dynamic> item) {
    final titleCtrl = TextEditingController(text: item['title'] ?? '');
    final weightCtrl =
        TextEditingController(text: (item['weightKg'] ?? 1).toString());

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Edit Donation Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Item Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: weightCtrl,
              decoration: const InputDecoration(
                labelText: 'Est. Weight (kg)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(c);
              await ApiService.patch('/donations/${item['_id']}', {
                'title': titleCtrl.text,
                'weightKg': double.tryParse(weightCtrl.text) ?? 1,
              });
              navigator.pop();
              _fetchData();
            },
            child: const Text('Save Changes'),
          )
        ],
      ),
    );
  }

  Future<void> _openMap(String address) async {
    final query = Uri.encodeComponent(address);
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.user['role'] ?? 'DONOR';
    final isNgo = role == 'NGO';
    final isAdmin = role == 'ADMIN';

    final filtered = _donations.where((item) {
      final title = (item['title'] ?? '').toString().toLowerCase();
      final category = (item['category'] ?? '').toString().toLowerCase();
      return title.contains(_searchQuery.toLowerCase()) ||
          category.contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        if (_disasters.isNotEmpty)
          Container(
            width: double.infinity,
            color: Colors.red.shade900,
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      '🚨 EMERGENCY DISASTER RELIEF ACTIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ..._disasters.map(
                  (d) {
                    final ngoDetails = d['ngoDetails'];
                    final disasterType = ngoDetails?['disasterType'] ?? 'Emergency Disaster';
                    final reason = ngoDetails?['disasterReason'] ?? 'Needs urgent goods';
                    final materials = ngoDetails?['requiredMaterials'] ?? 'Water, Blankets, Ration';
                    final dropoff = ngoDetails?['dropoffAddress'] ?? 'NGO Office';

                    return Card(
                      color: Colors.red.shade800,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ${d['name']}: $disasterType',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            Text('  Situation: $reason', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            Text('  Required Materials: $materials', style: const TextStyle(color: Colors.yellow, fontSize: 12, fontWeight: FontWeight.bold)),
                            Text('  Relief Drop-off Hub: $dropoff', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.red.shade900,
                                ),
                                icon: const Icon(Icons.volunteer_activism, size: 16),
                                label: const Text('Connect & Provide Relief', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                onPressed: () {
                                  NgoProfileModal.show(context, d['_id'], d['name']);
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            decoration: const InputDecoration(
              hintText: '🔎 Search items by keyword or category...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => setState(() => _searchQuery = val),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (c, i) {
              final item = filtered[i];
              final isOwner = item['donorId'] == widget.user['_id'];
              final canDelete = isOwner || isAdmin;
              final editable = isOwner &&
                  _canEdit(
                    item['createdAt'] ?? DateTime.now().toIso8601String(),
                  );
              final status = item['status'] ?? 'AVAILABLE';
              final photoUrls = (item['photoUrls'] is List && (item['photoUrls'] as List).isNotEmpty)
                  ? List<String>.from(item['photoUrls'])
                  : [''];
              final firstPhoto = photoUrls[0];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        onTap: () => ItemDetailsModal.show(context, item),
                        leading: firstPhoto.startsWith('data:image')
                            ? Image.memory(
                                base64Decode(firstPhoto.split(',').last),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                firstPhoto,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.inventory,
                                  size: 40,
                                ),
                              ),
                        title: Text(
                          item['title'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Text(
                              '👤 Donated by: ${item['donorName']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                            Text('Category: ${item['category']} • Status: $status'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.flag, color: Colors.orange),
                              tooltip: 'Report User or Listing',
                              onPressed: () => ReportDialog.show(
                                context,
                                currentUserId: widget.user['_id'],
                                currentUserName: widget.user['name'],
                                targetUserId: isOwner
                                    ? (item['requestedByNgoId'] ?? 'NGO')
                                    : item['donorId'],
                                targetUserName: isOwner
                                    ? (item['requestedByNgoName'] ?? 'NGO')
                                    : item['donorName'],
                                title: item['title'] ?? 'Item',
                              ),
                            ),
                            if (isOwner)
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: editable ? Colors.blue : Colors.grey,
                                ),
                                onPressed:
                                    editable ? () => _showEditDialog(item) : null,
                                tooltip: editable
                                    ? 'Edit (Within 5-min window)'
                                    : '5-min edit window expired',
                              ),
                            if (canDelete)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteDonation(item['_id']),
                                tooltip: isAdmin
                                    ? 'Admin: Delete Donation Listing'
                                    : 'Delete Donation',
                              ),
                          ],
                        ),
                      ),

                      // MULTI PHOTO GALLERY PREVIEW CAROUSEL
                      if (photoUrls.length > 1) ...[
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 60,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: photoUrls.length,
                            itemBuilder: (c, idx) {
                              final pUrl = photoUrls[idx];
                              return Container(
                                margin: const EdgeInsets.only(right: 6),
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.green.shade200),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: pUrl.startsWith('data:image')
                                      ? Image.memory(
                                          base64Decode(pUrl.split(',').last),
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          pUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => const Icon(Icons.image),
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],

                      const SizedBox(height: 8),

                      // REQUEST & NGO PROFILE CONTROLS
                      if (isNgo && status == 'AVAILABLE')
                        ElevatedButton.icon(
                          icon: const Icon(Icons.send),
                          label: const Text('Send Formal Item Request'),
                          onPressed: () async {
                            await ApiService.patch(
                              '/donations/${item['_id']}/request',
                              {
                                'ngoId': widget.user['_id'],
                                'ngoName': widget.user['name'],
                              },
                            );
                            _fetchData();
                          },
                        ),

                      if (isOwner && status == 'REQUESTED') ...[
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange.shade800,
                                ),
                                icon: const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'Accept Request from ${item['requestedByNgoName']}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                                onPressed: () async {
                                  await ApiService.patch(
                                    '/donations/${item['_id']}/accept',
                                    {},
                                  );
                                  _fetchData();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.info, color: Colors.blue, size: 18),
                              label: const Text('NGO Profile'),
                              onPressed: () {
                                NgoProfileModal.show(
                                  context,
                                  item['requestedByNgoId'] ?? '',
                                  item['requestedByNgoName'] ?? 'NGO',
                                );
                              },
                            )
                          ],
                        ),
                      ],

                      if (status == 'ACCEPTED' || status == 'COMPLETED') ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isOwner
                                          ? '🏢 NGO Office Address:'
                                          : '📍 Donor Pickup Address:',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    Text(
                                      isOwner
                                          ? (item['requestedByNgoOfficeAddress'] ??
                                              'Pune NGO Office')
                                          : (item['address']?['formattedAddress'] ??
                                              'Pune, India'),
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.map, color: Colors.green),
                                onPressed: () => _openMap(
                                  isOwner
                                      ? (item['requestedByNgoOfficeAddress'] ??
                                          'Pune NGO Office')
                                      : (item['address']?['formattedAddress'] ??
                                          'Pune, India'),
                                ),
                                tooltip: 'Open in Google Maps',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.qr_code),
                              label: Text(
                                isNgo ? 'Verify Collection QR Code' : 'Donor QR Collection Pass',
                              ),
                              onPressed: () {
                                QrCollectionModal.show(
                                  context,
                                  donationId: item['_id'],
                                  verificationCode: item['verificationCode'] ?? '123456',
                                  itemTitle: item['title'] ?? 'Item',
                                  isNgo: isNgo,
                                  onCollectionVerified: _fetchData,
                                );
                              },
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800),
                              icon: const Icon(Icons.chat, color: Colors.white),
                              label: const Text('1-on-1 Chat', style: TextStyle(color: Colors.white)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      donationId: item['_id'],
                                      currentUserId: widget.user['_id'],
                                      recipientId: isOwner
                                          ? (item['requestedByNgoId'] ?? 'NGO')
                                          : item['donorId'],
                                    ),
                                  ),
                                );
                              },
                            )
                          ],
                        )
                      ]
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}

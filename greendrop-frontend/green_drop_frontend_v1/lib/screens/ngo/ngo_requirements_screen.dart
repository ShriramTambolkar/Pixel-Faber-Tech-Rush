import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/ngo_profile_modal.dart';

class NgoRequirementsScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const NgoRequirementsScreen({super.key, required this.user});

  @override
  State<NgoRequirementsScreen> createState() => _NgoRequirementsScreenState();
}

class _NgoRequirementsScreenState extends State<NgoRequirementsScreen> {
  List<dynamic> _requirements = [];
  bool _isLoading = true;

  final List<String> _urgencyOptions = ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final res = await ApiService.get('/ngo/requirements');
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body)['data'] ?? [];
        if (mounted) setState(() => _requirements = data);
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (_requirements.isEmpty) {
          _requirements = [
            {
              '_id': 'req_sample_1',
              'ngoId': 'demo_ngo_001',
              'ngoName': 'SAMS Relief Network',
              'ngoPhone': '+91 9876500112',
              'ngoAddress': 'Kothrud, Pune, MH 411038',
              'title': 'Urgent: 50 Winter Blankets for Slum Drive',
              'itemName': '50 Winter Blankets',
              'quantityNeeded': '50 Blankets',
              'category': 'Clothes & Wearing',
              'urgencyLevel': 'HIGH',
              'helpfulDonors': [
                {'donorId': 'd101', 'donorName': 'Aarav Sharma', 'donorPhone': '+91 9876543210', 'donorEmail': 'aarav@gmail.com', 'message': 'Can provide 10 new blankets from Kothrud.'}
              ],
              'createdAt': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
            },
          ];
        }
      });
    }
  }


  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showOfferHelpDialog(Map<String, dynamic> reqItem) {
    final phoneCtrl = TextEditingController(text: widget.user['phoneNumber'] ?? '');
    final msgCtrl = TextEditingController(text: 'I would like to help provide ${reqItem['itemName'] ?? "items"} for your NGO.');

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Offer Help to ${reqItem['ngoName']}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Requirement: ${reqItem['itemName'] ?? reqItem['title']} (${reqItem['quantityNeeded'] ?? "Requested"})',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Your Contact Phone Number *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: msgCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Message / Details of what you can provide *',
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
              if (phoneCtrl.text.trim().isEmpty || msgCtrl.text.trim().isEmpty) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Phone number and message are required!')),
                );
                return;
              }
              await ApiService.post('/ngo/requirements/${reqItem['_id']}/offer-help', {
                'donorId': widget.user['_id'],
                'donorName': widget.user['name'],
                'donorPhone': phoneCtrl.text,
                'donorEmail': widget.user['email'],
                'message': msgCtrl.text,
              });

              NotificationService().showNotification(
                id: 202,
                title: '🔔 Help Offer Submitted!',
                body: 'Your offer to help ${reqItem['ngoName'] ?? "SAMS Relief Network"} was sent successfully!',
              );

              navigator.pop();
              messenger.showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.green,
                  content: Text('🎉 Your offer to help was sent directly to the NGO!'),
                ),
              );
              _fetch();
            },
            child: const Text('Send Help Offer', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _showHelpfulDonorsModal(Map<String, dynamic> reqItem) {
    final List<dynamic> donors = reqItem['helpfulDonors'] ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (c) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '👥 Donors Offering Help for "${reqItem['itemName']}"',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Total Donors Responded: ${donors.length}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const Divider(height: 20),
              if (donors.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'No donors have submitted help offers for this requirement yet.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...donors.map(
                  (d) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.green.shade100,
                        child: Icon(Icons.person, color: Colors.green.shade800),
                      ),
                      title: Text(d['donorName'] ?? 'Donor', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        '📞 ${d['donorPhone'] ?? 'N/A'}\n✉️ ${d['donorEmail'] ?? ''}\n💬 ${d['message'] ?? ''}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if ((d['donorPhone'] ?? '').isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.phone, color: Colors.green),
                              onPressed: () => _launchUrl('tel:${d['donorPhone']}'),
                              tooltip: 'Call Donor',
                            ),
                          if ((d['donorEmail'] ?? '').isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.email, color: Colors.blue),
                              onPressed: () => _launchUrl('mailto:${d['donorEmail']}'),
                              tooltip: 'Email Donor',
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text('Close List'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showAddRequirementDialog() {
    final itemCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String selectedUrgency = 'HIGH';

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setDialogState) {
          final safeUrgency = _urgencyOptions.contains(selectedUrgency)
              ? selectedUrgency
              : _urgencyOptions[0];

          return AlertDialog(
            title: const Text('Post Structured NGO Requirement'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: itemCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Material / Item Needed *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: qtyCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Quantity Needed (e.g., 50 Blankets, 100 kg Rice) *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: safeUrgency,
                    decoration: const InputDecoration(
                      labelText: 'Urgency Level',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'LOW', child: Text('Low Urgency')),
                      DropdownMenuItem(value: 'MEDIUM', child: Text('Medium Urgency')),
                      DropdownMenuItem(value: 'HIGH', child: Text('High Urgency 🔥')),
                      DropdownMenuItem(value: 'CRITICAL', child: Text('Critical Emergency 🚨')),
                    ],
                    onChanged: (v) {
                      if (v != null) setDialogState(() => selectedUrgency = v);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: targetCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Target Beneficiaries / Audience',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Additional Notes / Pickup Hours',
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
                  if (itemCtrl.text.trim().isEmpty || qtyCtrl.text.trim().isEmpty) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Item name and quantity are required!')),
                    );
                    return;
                  }
                  await ApiService.post('/ngo/requirements', {
                    'ngoId': widget.user['_id'],
                    'ngoName': widget.user['name'],
                    'itemName': itemCtrl.text,
                    'quantityNeeded': qtyCtrl.text,
                    'urgencyLevel': selectedUrgency,
                    'targetAudience': targetCtrl.text,
                    'notes': notesCtrl.text,
                  });
                  navigator.pop();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Requirement posted to global demand board!')),
                  );
                  _fetch();
                },
                child: const Text('Post Requirement', style: TextStyle(color: Colors.white)),
              )
            ],
          );
        },
      ),
    );
  }

  Future<void> _deleteRequirement(String id) async {
    await ApiService.delete('/ngo/requirements/$id');
    _fetch();
  }

  Color _urgencyColor(String level) {
    switch (level) {
      case 'CRITICAL':
        return Colors.red;
      case 'HIGH':
        return Colors.orange.shade800;
      case 'MEDIUM':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.user['role'] ?? 'DONOR';
    final isNgo = role == 'NGO';
    final isAdmin = role == 'ADMIN';

    return Scaffold(
      floatingActionButton: isNgo
          ? FloatingActionButton.extended(
              onPressed: _showAddRequirementDialog,
              icon: const Icon(Icons.add_task),
              label: const Text('Post Requirement'),
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
                Icon(Icons.fact_check, color: Colors.green),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '📋 Structured NGO Requirement Board: Donors can offer help directly; NGOs receive donor responses in real-time.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _requirements.isEmpty
                    ? const Center(
                        child: Text(
                          'No active NGO requirements posted currently.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _requirements.length,
                        itemBuilder: (c, i) {
                          final r = _requirements[i];
                          final isOwner = r['ngoId'] == widget.user['_id'];
                          final urgency = r['urgencyLevel'] ?? 'MEDIUM';
                          final color = _urgencyColor(urgency);
                          final helpfulDonorsList = (r['helpfulDonors'] as List<dynamic>?) ?? [];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: color.withValues(alpha: 0.5), width: 1.5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          r['itemName'] ?? '',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Chip(
                                        backgroundColor: color.withValues(alpha: 0.1),
                                        side: BorderSide(color: color),
                                        label: Text(
                                          urgency,
                                          style: TextStyle(
                                            color: color,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                   Row(
                                     children: [
                                       Text(
                                         '🏢 Requested by: ${r['ngoName']}',
                                         style: TextStyle(
                                           color: Colors.green.shade900,
                                           fontWeight: FontWeight.bold,
                                         ),
                                       ),
                                       IconButton(
                                         icon: const Icon(Icons.info_outline, color: Colors.green, size: 18),
                                         tooltip: 'View NGO Profile',
                                         onPressed: () {
                                           NgoProfileModal.show(
                                             context,
                                             r['ngoId'] ?? 'demo_ngo_001',
                                             r['ngoName'] ?? 'NGO',
                                             currentUser: widget.user,
                                           );
                                         },
                                       ),
                                     ],
                                   ),
                                  Text('⚖️ Needed Quantity: ${r['quantityNeeded']}'),
                                  if ((r['targetAudience'] ?? '').isNotEmpty)
                                    Text('👥 Target Beneficiaries: ${r['targetAudience']}'),
                                  if ((r['notes'] ?? '').isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '📝 Notes: ${r['notes']}',
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      // DONOR ACTION: OFFER HELP
                                      if (role == 'DONOR')
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green.shade800,
                                          ),
                                          icon: const Icon(Icons.handshake, color: Colors.white),
                                          label: const Text('🙋 I Want to Help / Offer Support', style: TextStyle(color: Colors.white)),
                                          onPressed: () => _showOfferHelpDialog(r),
                                        ),

                                      // NGO / ADMIN ACTION: VIEW HELPFUL DONORS LIST
                                      if (isOwner || isAdmin || role == 'NGO')
                                        OutlinedButton.icon(
                                          icon: const Icon(Icons.people, color: Colors.blue),
                                          label: Text('👥 View Helpful Donors (${helpfulDonorsList.length})'),
                                          onPressed: () => _showHelpfulDonorsModal(r),
                                        ),

                                      if (isOwner || isAdmin)
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => _deleteRequirement(r['_id']),
                                          tooltip: 'Delete Requirement',
                                        )
                                    ],
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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  List<dynamic> _users = [];
  List<dynamic> _reports = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final uRes = await ApiService.get('/admin/users');
      final rRes = await ApiService.get('/admin/reports');
      if (uRes.statusCode == 200) {
        setState(() => _users = jsonDecode(uRes.body)['data']);
      }
      if (rRes.statusCode == 200) {
        setState(() => _reports = jsonDecode(rRes.body)['data']);
      }
    } catch (_) {}
  }

  Future<void> _openProof(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Proof Document Link'),
          content: SelectableText(url),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Close'),
            )
          ],
        ),
      );
    }
  }

  Future<void> _warnUser(String userId, String userName) async {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Issue Warning to $userName'),
        content: TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(
            labelText: 'Formal Warning Explanation',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800),
            onPressed: () async {
              final navigator = Navigator.of(c);
              final messenger = ScaffoldMessenger.of(context);
              if (reasonCtrl.text.trim().isEmpty) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Warning reason is required!')),
                );
                return;
              }
              await ApiService.post('/admin/warn-user', {
                'userId': userId,
                'reason': reasonCtrl.text,
              });
              navigator.pop();
              messenger.showSnackBar(
                SnackBar(content: Text('Warning issued to $userName.')),
              );
              _fetch();
            },
            child: const Text('Send Warning', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Future<void> _deleteUser(String id, String userName) async {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Ban & Remove $userName?'),
        content: const Text('This action permanently deletes the user account from GreenDrop.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final navigator = Navigator.of(c);
              final messenger = ScaffoldMessenger.of(context);
              await ApiService.delete('/admin/users/$id');
              navigator.pop();
              messenger.showSnackBar(
                SnackBar(content: Text('$userName was removed.')),
              );
              _fetch();
            },
            child: const Text('Confirm Ban/Remove', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: const TabBar(
          tabs: [
            Tab(icon: Icon(Icons.verified_user), text: 'Users & Proofs'),
            Tab(icon: Icon(Icons.report_problem), text: 'Reports & Moderation'),
          ],
        ),
        body: TabBarView(
          children: [
            // USERS & PROOFS TAB
            ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _users.length,
              itemBuilder: (c, i) {
                final u = _users[i];
                final isNgo = u['role'] == 'NGO';
                final ngo = u['ngoDetails'];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: isNgo ? Colors.green.shade800 : Colors.blue.shade800,
                      child: Text(u['role']?[0] ?? 'U', style: const TextStyle(color: Colors.white)),
                    ),
                    title: Text('${u['name']} (${u['role']})', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${u['email']} • Warnings: ${u['warningCount'] ?? 0}',
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('📞 Phone: ${u['phoneNumber'] ?? 'N/A'}'),
                            if (isNgo && ngo != null) ...[
                              const Divider(),
                              const Text('📜 Verified NGO Document Proofs:', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text('• NGO Darpan ID: ${ngo['darpanId'] ?? 'MH/2026/001'}'),
                              Text('• Registered Address: ${ngo['officeAddress'] ?? 'N/A'}'),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  ActionChip(
                                    avatar: const Icon(Icons.description, size: 16),
                                    label: const Text('View Trust Deed Proof'),
                                    onPressed: () => _openProof(ngo['registrationCertificateUrl'] ?? ''),
                                  ),
                                  ActionChip(
                                    avatar: const Icon(Icons.credit_card, size: 16),
                                    label: const Text('View NGO PAN Proof'),
                                    onPressed: () => _openProof(ngo['panCardUrl'] ?? ''),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.warning, color: Colors.orange),
                                  label: const Text('Issue Warning'),
                                  onPressed: () => _warnUser(u['_id'], u['name'] ?? 'User'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  icon: const Icon(Icons.delete, color: Colors.white),
                                  label: const Text('Remove User', style: TextStyle(color: Colors.white)),
                                  onPressed: () => _deleteUser(u['_id'], u['name'] ?? 'User'),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
            // REPORTS & MODERATION TAB
            ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _reports.length,
              itemBuilder: (c, i) {
                final r = _reports[i];
                return Card(
                  color: Colors.red.shade50,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      'Reported: ${r['targetUserName']} (${r['reportCategory']})',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    subtitle: Text(
                      'By: ${r['reportedByUserName']}\nExplanation: ${r['reason']}\nTarget Item/Event: ${r['itemOrEventTitle']}',
                    ),
                    trailing: Wrap(
                      spacing: 4,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade800),
                          onPressed: () => _warnUser(r['targetUserId'], r['targetUserName']),
                          child: const Text('Issue Warning', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () => _deleteUser(r['targetUserId'], r['targetUserName']),
                          child: const Text('Ban Account', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

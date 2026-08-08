import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/ngo_profile_modal.dart';
import '../../widgets/shimmer_placeholder.dart';

class NgoDirectoryScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const NgoDirectoryScreen({super.key, required this.user});

  @override
  State<NgoDirectoryScreen> createState() => _NgoDirectoryScreenState();
}

class _NgoDirectoryScreenState extends State<NgoDirectoryScreen> {
  List<dynamic> _ngos = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchNgos();
  }

  Future<void> _fetchNgos() async {
    try {
      final res = await ApiService.get('/admin/users');
      if (res.statusCode == 200) {
        final allUsers = jsonDecode(res.body)['data'] as List<dynamic>;
        setState(() {
          _ngos = allUsers.where((u) => u['role'] == 'NGO').toList();
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
    final filtered = _ngos.where((ngo) {
      final name = (ngo['name'] ?? '').toString().toLowerCase();
      final email = (ngo['email'] ?? '').toString().toLowerCase();
      final address = (ngo['ngoDetails']?['officeAddress'] ?? '').toString().toLowerCase();
      final q = _searchQuery.toLowerCase();
      return name.contains(q) || email.contains(q) || address.contains(q);
    }).toList();

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            color: Colors.green.shade50,
            child: const Row(
              children: [
                Icon(Icons.search, color: Colors.green),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '🔍 NGO Search Directory: Browse and inspect verified non-profit NGOs, their mission, office address, and social channels.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: '🔎 Search verified NGOs by name, city, or email...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          Expanded(
            child: _isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: 4,
                    itemBuilder: (c, i) => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: ShimmerPlaceholder(height: 80, borderRadius: 12),
                    ),
                  )
                : filtered.isEmpty
                    ? const Center(child: Text('No verified NGOs found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filtered.length,
                        itemBuilder: (c, i) {
                          final ngo = filtered[i];
                          final ngoDetails = ngo['ngoDetails'];
                          final address = ngoDetails?['officeAddress'] ?? 'Pune, India';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              onTap: () {
                                NgoProfileModal.show(
                                  context,
                                  ngo['_id'],
                                  ngo['name'] ?? 'NGO',
                                  currentUser: widget.user,
                                );
                              },
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade800,
                                child: const Icon(Icons.corporate_fare, color: Colors.white),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    ngo['name'] ?? 'NGO',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('ℹ️', style: TextStyle(fontSize: 16)),
                                  const SizedBox(width: 4),
                                  Icon(Icons.verified, color: Colors.green.shade800, size: 18),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  '📍 Headquarters: $address\n✉️ Email: ${ngo['email']}',
                                  style: const TextStyle(height: 1.3),
                                ),
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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';

class DonationsMapScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const DonationsMapScreen({super.key, required this.user});

  @override
  State<DonationsMapScreen> createState() => _DonationsMapScreenState();
}

class _DonationsMapScreenState extends State<DonationsMapScreen> {
  List<dynamic> _donations = [];
  List<dynamic> _disasters = [];
  bool _isLoading = true;

  final List<Map<String, String>> _ngoOfficeLocations = [
    {
      'name': 'Smile Foundation Pune HQ',
      'address': 'Deccan Gymkhana, FC Road, Pune, MH 411004',
      'phone': '+91 9123456789',
      'type': 'Verified NGO Office & Drop-off Hub',
    },
    {
      'name': 'Goonj Urban Relief Hub',
      'address': 'Kothrud Industrial Area, Pune, MH 411038',
      'phone': '+91 9876543210',
      'type': 'Clothing & Appliance Collection Center',
    },
    {
      'name': 'Deepastambha Care Foundation',
      'address': 'Viman Nagar, Nagar Road, Pune, MH 411014',
      'phone': '+91 9988776655',
      'type': 'Food & Ration Distribution HQ',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchMapData();
  }

  Future<void> _fetchMapData() async {
    try {
      final dRes = await ApiService.get('/donations/nearby');
      final disRes = await ApiService.get('/disasters/active');
      if (dRes.statusCode == 200) {
        _donations = jsonDecode(dRes.body)['data'];
      }
      if (disRes.statusCode == 200) {
        _disasters = jsonDecode(disRes.body)['data'];
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _launchMap(String address) async {
    final query = Uri.encodeComponent(address.isNotEmpty ? address : 'Pune, MH');
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchBatchRoute(List<dynamic> items) async {
    if (items.isEmpty) return;
    final addresses = items.map((i) => i['address']?['formattedAddress'] ?? 'Pune').join('|');
    final query = Uri.encodeComponent(addresses);
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.user['role'] ?? 'DONOR';
    final isNgo = role == 'NGO';

    // Role-specific map items filtering
    // NGO: Accepted pickups by donors
    final ngoAcceptedPickups = _donations.where((d) => d['status'] == 'ACCEPTED' || d['status'] == 'AVAILABLE').toList();

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.green.shade50,
            child: Row(
              children: [
                const Icon(Icons.map, color: Colors.green),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isNgo
                        ? '🗺️ NGO Pickup Map: Showing donors who accepted collection requests.'
                        : '🗺️ Donor Map: Showing nearby verified NGO offices & emergency relief hubs.',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              ],
            ),
          ),

          // INTERACTIVE MAP CONTAINER
          Container(
            height: 200,
            width: double.infinity,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade800, width: 2),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=800',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.black.withValues(alpha: 0.35),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, color: Colors.red, size: 40),
                      const SizedBox(height: 4),
                      Text(
                        isNgo
                            ? '📍 ${ngoAcceptedPickups.length} Accepted Donor Pickups Nearby'
                            : '📍 ${_ngoOfficeLocations.length} Verified NGO Offices Nearby',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (_disasters.isNotEmpty)
                        Chip(
                          backgroundColor: Colors.red.shade900,
                          label: Text(
                            '🚨 ${_disasters.length} Active Emergency Relief Hub(s)',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade800,
                        ),
                        icon: const Icon(Icons.navigation, color: Colors.white, size: 16),
                        label: const Text(
                          'Open Full Live Google Maps',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        onPressed: () => _launchMap('Pune, Maharashtra'),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),

          // BATCH ROUTE PLANNER FOR NGOS
          if (isNgo) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Card(
                color: Colors.green.shade900,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.alt_route, color: Colors.white, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🚚 Driver Batch Route Planner',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Optimize pickup route for ${ngoAcceptedPickups.length} donor locations',
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                        onPressed: () => _launchBatchRoute(ngoAcceptedPickups),
                        child: Text(
                          'Plan Route',
                          style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // ROLE-SPECIFIC PINS LIST
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                isNgo
                    ? '📦 Donors Who Accepted Collection Requests:'
                    : '🏢 Nearby NGO Office Locations:',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 6),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : isNgo
                    ? (ngoAcceptedPickups.isEmpty
                        ? const Center(child: Text('No accepted donor collection requests found.'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: ngoAcceptedPickups.length,
                            itemBuilder: (c, i) {
                              final item = ngoAcceptedPickups[i];
                              final addr = item['address']?['formattedAddress'] ?? 'Deccan Gymkhana, Pune';

                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.green.shade100,
                                    child: const Icon(Icons.person_pin_circle, color: Colors.green),
                                  ),
                                  title: Text(item['title'] ?? 'Donation', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('👤 Donor Name: ${item['donorName']}\n📍 Pickup Location: $addr'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.directions, color: Colors.green),
                                    onPressed: () => _launchMap(addr),
                                    tooltip: 'Navigate to Donor Address',
                                  ),
                                ),
                              );
                            },
                          ))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: _ngoOfficeLocations.length,
                        itemBuilder: (c, i) {
                          final ngo = _ngoOfficeLocations[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Icon(Icons.business, color: Colors.blue.shade800),
                              ),
                              title: Text(ngo['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('📍 Office: ${ngo['address']}\n📞 Contact: ${ngo['phone']}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.directions, color: Colors.blue),
                                onPressed: () => _launchMap(ngo['address']!),
                                tooltip: 'Navigate to NGO Office',
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

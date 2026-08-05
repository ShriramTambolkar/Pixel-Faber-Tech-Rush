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
    final availableDonations = _donations.where((d) => d['status'] == 'AVAILABLE').toList();
    final role = widget.user['role'] ?? 'DONOR';
    final isNgo = role == 'NGO';

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.green.shade50,
            child: const Row(
              children: [
                Icon(Icons.map, color: Colors.green),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '🗺️ Map View & Geofencing: View donations, disaster hubs, and optimize batch pickup routes.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              ],
            ),
          ),

          // SIMULATED INTERACTIVE MAP VIEW CONTAINER
          Container(
            height: 220,
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
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on, color: Colors.red, size: 40),
                      const SizedBox(height: 4),
                      Text(
                        '📍 Map View Active: ${availableDonations.length} Available Donations nearby',
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
                          'Open Live Google Maps View',
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

          // BATCH ROUTE OPTIMIZER FOR NGOs
          if (isNgo) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Card(
                color: Colors.green.shade900,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.alt_route, color: Colors.white, size: 30),
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
                              'Optimize pickup route for ${availableDonations.length} nearby donations in 1 trip',
                              style: const TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                        onPressed: () => _launchBatchRoute(availableDonations),
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
            const SizedBox(height: 10),
          ],

          // LIST OF NEARBY LOCATIONS
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '📍 Geofenced Pickup Locations:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 6),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : availableDonations.isEmpty
                    ? const Center(child: Text('No active donation pins found nearby.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: availableDonations.length,
                        itemBuilder: (c, i) {
                          final item = availableDonations[i];
                          final addr = item['address']?['formattedAddress'] ?? 'Deccan Gymkhana, Pune';

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.red.shade100,
                                child: const Icon(Icons.location_on, color: Colors.red),
                              ),
                              title: Text(item['title'] ?? 'Donation Item', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('📍 Address: $addr\n👤 Donor: ${item['donorName']}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.directions, color: Colors.green),
                                onPressed: () => _launchMap(addr),
                                tooltip: 'Navigate to Pickup Address',
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

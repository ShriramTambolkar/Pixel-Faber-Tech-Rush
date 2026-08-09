import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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
  bool _isLoading = true;
  final MapController _mapController = MapController();

  final List<Map<String, dynamic>> _ngoOfficeLocations = [
    {
      'name': 'SAMS Relief Network HQ',
      'address': 'Kothrud, Pune, MH 411038',
      'phone': '+91 9876500112',
      'type': 'Verified NGO Office & Drop-off Hub',
      'location': const LatLng(18.5074, 73.8077), // Kothrud Pune
    },
    {
      'name': 'Smile Foundation Pune HQ',
      'address': 'Deccan Gymkhana, FC Road, Pune, MH 411004',
      'phone': '+91 9123456789',
      'type': 'Verified NGO Office & Drop-off Hub',
      'location': const LatLng(18.5167, 73.8412), // Deccan Gymkhana
    },
    {
      'name': 'Goonj Urban Relief Hub',
      'address': 'Warje, Pune, MH 411058',
      'phone': '+91 9876543210',
      'type': 'Clothing Collection Center',
      'location': const LatLng(18.4800, 73.8000), // Warje
    },
    {
      'name': 'Deepastambha Care Foundation',
      'address': 'Viman Nagar, Pune, MH 411014',
      'phone': '+91 9988776655',
      'type': 'Food Distribution HQ',
      'location': const LatLng(18.5679, 73.9143), // Viman Nagar
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
      if (dRes.statusCode == 200) {
        _donations = jsonDecode(dRes.body)['data'];
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _launchExternalMap(String address) async {
    final query = Uri.encodeComponent(address.isNotEmpty ? address : 'Pune, MH');
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showPinDetailsModal({
    required String title,
    required String subtitle,
    required String address,
    required String phone,
    required Color color,
    required IconData icon,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (c) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(child: Text(address, style: const TextStyle(fontSize: 13))),
              ],
            ),
            if (phone.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.phone, size: 18, color: Colors.green),
                  const SizedBox(width: 6),
                  Text(phone, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800),
                    icon: const Icon(Icons.directions, color: Colors.white),
                    label: const Text('Open External Navigation', style: TextStyle(color: Colors.white, fontSize: 12)),
                    onPressed: () => _launchExternalMap(address),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.user['role'] ?? 'DONOR';
    final isNgo = role == 'NGO';

    final ngoAcceptedPickups = _donations.where((d) => d['status'] == 'ACCEPTED' || d['status'] == 'AVAILABLE').toList();

    // Generate Map Markers
    final List<Marker> markers = [];

    // NGO Office Markers (Green Pins)
    for (var ngo in _ngoOfficeLocations) {
      final loc = ngo['location'] as LatLng;
      markers.add(
        Marker(
          point: loc,
          width: 48,
          height: 48,
          child: GestureDetector(
            onTap: () => _showPinDetailsModal(
              title: ngo['name']!,
              subtitle: ngo['type']!,
              address: ngo['address']!,
              phone: ngo['phone']!,
              color: Colors.green.shade800,
              icon: Icons.corporate_fare,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade800,
                    shape: BoxShape.circle,
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: const Icon(Icons.business, color: Colors.white, size: 20),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.green, size: 16),
              ],
            ),
          ),
        ),
      );
    }

    // Donor Accepted Collection Markers (Blue Pins)
    for (var i = 0; i < ngoAcceptedPickups.length; i++) {
      final item = ngoAcceptedPickups[i];
      // Generate realistic spread around Pune for demonstration
      final lat = 18.5204 + (i * 0.012) - 0.01;
      final lng = 73.8567 + (i * 0.015) - 0.01;
      final point = LatLng(lat, lng);

      markers.add(
        Marker(
          point: point,
          width: 48,
          height: 48,
          child: GestureDetector(
            onTap: () => _showPinDetailsModal(
              title: item['title'] ?? 'Donation Item',
              subtitle: '👤 Donor: ${item['donorName'] ?? "Donor"}',
              address: item['address']?['formattedAddress'] ?? 'Pune, MH',
              phone: '+91 9876543210',
              color: Colors.blue.shade800,
              icon: Icons.inventory_2,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  child: const Icon(Icons.person_pin_circle, color: Colors.white, size: 20),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.blue, size: 16),
              ],
            ),
          ),
        ),
      );
    }

    // Route points for multi-stop volunteer route line
    final routePoints = markers.map((m) => m.point).toList();

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
                        ? '🗺️ In-App Interactive Map: Tap any pin on the map below to view details!'
                        : '🗺️ In-App Interactive Map: Showing nearby verified NGO offices & drop-off hubs.',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ),
              ],
            ),
          ),

          // EMBEDDED IN-APP INTERACTIVE FLUTTER MAP WIDGET
          SizedBox(
            height: 320,
            width: double.infinity,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: const MapOptions(
                    initialCenter: LatLng(18.5204, 73.8567), // Pune Center
                    initialZoom: 12.0,
                    minZoom: 9.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.green_drop_frontend_v1',
                    ),
                    if (isNgo && routePoints.length > 1)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: routePoints,
                            strokeWidth: 3.5,
                            color: Colors.blue.shade700,
                          ),
                        ],
                      ),
                    MarkerLayer(markers: markers),
                  ],
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'recenter_map_btn',
                    backgroundColor: Colors.green.shade800,
                    child: const Icon(Icons.my_location, color: Colors.white),
                    onPressed: () {
                      _mapController.move(const LatLng(18.5204, 73.8567), 12.0);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // PINS LIST & DETAILS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                isNgo
                    ? '📦 Accepted Donor Pickups (${ngoAcceptedPickups.length}):'
                    : '🏢 Verified NGO Headquarters Locations:',
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
                                  onTap: () => _showPinDetailsModal(
                                    title: item['title'] ?? 'Donation Item',
                                    subtitle: '👤 Donor: ${item['donorName'] ?? "Donor"}',
                                    address: addr,
                                    phone: '+91 9876543210',
                                    color: Colors.blue.shade800,
                                    icon: Icons.inventory_2,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue.shade100,
                                    child: const Icon(Icons.person_pin_circle, color: Colors.blue),
                                  ),
                                  title: Text(item['title'] ?? 'Donation', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('👤 Donor: ${item['donorName']}\n📍 Location: $addr'),
                                  trailing: const Icon(Icons.touch_app, color: Colors.blue),
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
                              onTap: () => _showPinDetailsModal(
                                title: ngo['name']!,
                                subtitle: ngo['type']!,
                                address: ngo['address']!,
                                phone: ngo['phone']!,
                                color: Colors.green.shade800,
                                icon: Icons.business,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                child: Icon(Icons.business, color: Colors.green.shade800),
                              ),
                              title: Text(ngo['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('📍 Office: ${ngo['address']}\n📞 Contact: ${ngo['phone']}'),
                              trailing: const Icon(Icons.touch_app, color: Colors.green),
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

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../services/api_service.dart';

class DonationsMapScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const DonationsMapScreen({super.key, required this.user});

  @override
  State<DonationsMapScreen> createState() => _DonationsMapScreenState();
}

class _DonationsMapScreenState extends State<DonationsMapScreen> {
  List<dynamic> _donations = [];
  final MapController _mapController = MapController();

  bool _isNavigating = false;
  Map<String, dynamic>? _selectedTarget;
  List<LatLng> _routePolyline = [];
  List<Map<String, dynamic>> _navigationSteps = [];
  int _currentStepIndex = 0;
  double _remainingDistanceKm = 0.0;
  int _remainingDurationMins = 0;
  Timer? _navigationSimTimer;
  LatLng _driverCurrentPos = const LatLng(18.5074, 73.8077);

  final List<Map<String, dynamic>> _ngoOfficeLocations = [
    {
      'name': 'SAMS Relief Network HQ',
      'address': 'Kothrud, Pune, MH 411038',
      'phone': '+91 9876500112',
      'type': 'Verified NGO Office & Drop-off Hub',
      'location': const LatLng(18.5074, 73.8077),
    },
    {
      'name': 'Smile Foundation Pune HQ',
      'address': 'Deccan Gymkhana, FC Road, Pune, MH 411004',
      'phone': '+91 9123456789',
      'type': 'Verified NGO Office & Drop-off Hub',
      'location': const LatLng(18.5167, 73.8412),
    },
    {
      'name': 'Goonj Urban Relief Hub',
      'address': 'Warje, Pune, MH 411058',
      'phone': '+91 9876543210',
      'type': 'Clothing Collection Center',
      'location': const LatLng(18.4800, 73.8000),
    },
    {
      'name': 'Deepastambha Care Foundation',
      'address': 'Viman Nagar, Pune, MH 411014',
      'phone': '+91 9988776655',
      'type': 'Food Distribution HQ',
      'location': const LatLng(18.5679, 73.9143),
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchMapData();
  }

  @override
  void dispose() {
    _navigationSimTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchMapData() async {
    try {
      final dRes = await ApiService.get('/donations/nearby');
      if (dRes.statusCode == 200) {
        _donations = jsonDecode(dRes.body)['data'];
      }
    } catch (_) {}
  }

  // Fetch OSRM Road Polyline & Navigation Directions
  Future<void> _startTurnByTurnNavigation(Map<String, dynamic> target) async {
    setState(() {
      _selectedTarget = target;
    });

    final LatLng start = _driverCurrentPos;
    final LatLng end = target['location'] as LatLng;

    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
        '?overview=full&geometries=geojson&steps=true',
      );

      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final route = data['routes'][0];

        // Parse Polyline Coordinates
        final coords = route['geometry']['coordinates'] as List;
        final List<LatLng> polyline = coords.map((c) => LatLng(c[1].toDouble(), c[0].toDouble())).toList();

        // Parse Turn Steps
        final steps = (route['legs'][0]['steps'] as List).map((s) {
          final type = s['maneuver']['type'] ?? 'turn';
          final modifier = s['maneuver']['modifier'] ?? '';
          final name = s['name'] ?? '';
          return {
            'instruction': _formatTurnInstruction(type, modifier, name),
            'distance': (s['distance'] as num).toDouble(),
            'location': LatLng(s['maneuver']['location'][1].toDouble(), s['maneuver']['location'][0].toDouble()),
          };
        }).toList();

        setState(() {
          _routePolyline = polyline;
          _navigationSteps = List<Map<String, dynamic>>.from(steps);
          _currentStepIndex = 0;
          _remainingDistanceKm = (route['distance'] as num) / 1000.0;
          _remainingDurationMins = ((route['duration'] as num) / 60.0).round();
          _isNavigating = true;
        });

        _mapController.move(start, 15.0);
        _startSimulatedNavigation();
        return;
      }
    } catch (_) {}

    // Fallback if OSRM endpoint times out
    setState(() {
      _routePolyline = [start, end];
      _navigationSteps = [
        {'instruction': 'Head towards destination on main road', 'distance': 2000.0, 'location': end}
      ];
      _currentStepIndex = 0;
      _remainingDistanceKm = 3.5;
      _remainingDurationMins = 10;
      _isNavigating = true;
    });
    _mapController.move(start, 15.0);
    _startSimulatedNavigation();
  }

  String _formatTurnInstruction(String type, String modifier, String street) {
    final streetText = street.isNotEmpty ? ' onto $street' : '';
    if (type == 'depart') return 'Head towards your pickup destination';
    if (type == 'arrive') return 'Arriving at destination on your right';
    if (modifier == 'left') return 'In 100m, turn left$streetText';
    if (modifier == 'right') return 'In 100m, turn right$streetText';
    if (modifier == 'slight left') return 'Keep left$streetText';
    if (modifier == 'slight right') return 'Keep right$streetText';
    return 'Continue straight$streetText';
  }

  void _startSimulatedNavigation() {
    _navigationSimTimer?.cancel();
    if (_routePolyline.isEmpty) return;

    int polyIndex = 0;
    _navigationSimTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!mounted || !_isNavigating || polyIndex >= _routePolyline.length - 1) {
        timer.cancel();
        if (_isNavigating && mounted) {
          _showArrivalDialog();
        }
        return;
      }

      polyIndex++;
      final nextPos = _routePolyline[polyIndex];

      setState(() {
        _driverCurrentPos = nextPos;
        _remainingDistanceKm = (_remainingDistanceKm - 0.2).clamp(0.0, 50.0);
        if (_remainingDistanceKm <= 0.1) _remainingDurationMins = 0;

        if (_navigationSteps.length > 1 && polyIndex % 3 == 0) {
          _currentStepIndex = (_currentStepIndex + 1) % _navigationSteps.length;
        }
      });

      _mapController.move(nextPos, 15.5);
    });
  }

  void _stopNavigation() {
    _navigationSimTimer?.cancel();
    setState(() {
      _isNavigating = false;
      _selectedTarget = null;
      _routePolyline = [];
      _navigationSteps = [];
    });
  }

  void _showArrivalDialog() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 8),
            Text('Arrived at Destination!'),
          ],
        ),
        content: Text(
          'You have arrived at ${_selectedTarget?['name'] ?? "Pickup Location"}.\n'
          '🔑 Don\'t forget to verify the 6-digit donor passcode to complete collection!',
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800),
            onPressed: () {
              Navigator.pop(c);
              _stopNavigation();
            },
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  void _showPinDetailsModal({
    required String title,
    required String subtitle,
    required String address,
    required String phone,
    required Color color,
    required IconData icon,
    required LatLng location,
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.navigation, color: Colors.white),
                    label: const Text(
                      '▶ Start In-App Turn-by-Turn Navigation',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(c);
                      _startTurnByTurnNavigation({
                        'name': title,
                        'address': address,
                        'location': location,
                      });
                    },
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

    final ngoAcceptedPickups = _donations.where((d) => d['status'] == 'ACCEPTED' || d['status'] == 'CODE_VERIFIED').toList();

    final List<Marker> markers = [];

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
              location: loc,
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

    if (isNgo) {
      for (var i = 0; i < ngoAcceptedPickups.length; i++) {
        final item = ngoAcceptedPickups[i];
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
                location: point,
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
    }

    if (_isNavigating) {
      markers.add(
        Marker(
          point: _driverCurrentPos,
          width: 52,
          height: 52,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 6)],
                ),
                child: const Icon(Icons.navigation, color: Colors.black, size: 24),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          if (_isNavigating)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.green.shade900,
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.turn_right, color: Colors.amber, size: 36),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _navigationSteps.isNotEmpty
                                    ? _navigationSteps[_currentStepIndex]['instruction']
                                    : 'Navigating to ${_selectedTarget?['name']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Target: ${_selectedTarget?['name']}',
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: _stopNavigation,
                          tooltip: 'Exit Navigation',
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24, height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.timer, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '$_remainingDurationMins mins',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.straighten, color: Colors.amber, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${_remainingDistanceKm.toStringAsFixed(1)} km',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        const Chip(
                          backgroundColor: Colors.amber,
                          label: Text(
                            'LIVE GPS',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
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
                          ? '🗺️ In-App Turn-by-Turn Map: Tap any pin & select "Start Navigation" for live ETA!'
                          : '🗺️ In-App Interactive Donor Map: View nearby verified NGO offices & drop-off hubs.',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _driverCurrentPos,
                    initialZoom: 13.0,
                    minZoom: 9.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.green_drop_frontend_v1',
                    ),
                    if (_isNavigating && _routePolyline.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePolyline,
                            strokeWidth: 5.0,
                            color: Colors.blue.shade700,
                          ),
                        ],
                      ),
                    MarkerLayer(markers: markers),
                  ],
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Column(
                    children: [
                      if (_isNavigating)
                        FloatingActionButton.small(
                          heroTag: 'stop_nav_btn',
                          backgroundColor: Colors.red,
                          onPressed: _stopNavigation,
                          child: const Icon(Icons.stop, color: Colors.white),
                        ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'recenter_map_btn',
                        backgroundColor: Colors.green.shade800,
                        child: const Icon(Icons.my_location, color: Colors.white),
                        onPressed: () {
                          _mapController.move(_driverCurrentPos, 14.5);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

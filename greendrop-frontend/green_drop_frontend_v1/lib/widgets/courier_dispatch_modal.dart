import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CourierDispatchModal {
  static void show(
    BuildContext context, {
    required String donationId,
    required String itemTitle,
    required String pickupAddress,
    required VoidCallback onDispatched,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (c) => _CourierDispatchContent(
        donationId: donationId,
        itemTitle: itemTitle,
        pickupAddress: pickupAddress,
        onDispatched: onDispatched,
      ),
    );
  }
}

class _CourierDispatchContent extends StatefulWidget {
  final String donationId;
  final String itemTitle;
  final String pickupAddress;
  final VoidCallback onDispatched;

  const _CourierDispatchContent({
    required this.donationId,
    required this.itemTitle,
    required this.pickupAddress,
    required this.onDispatched,
  });

  @override
  State<_CourierDispatchContent> createState() => _CourierDispatchContentState();
}

class _CourierDispatchContentState extends State<_CourierDispatchContent> {
  String _selectedProvider = 'Porter';
  String _selectedVehicle = '🛵 2-Wheeler Bike Courier';
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  final List<Map<String, String>> _providers = [
    {
      'name': 'Porter',
      'subtitle': 'On-Demand Mini Truck & Bike Courier',
      'icon': '🚚',
      'color': '0xFF1E40AF',
      'eta': '10-15 Mins',
      'fare': '₹45',
    },
    {
      'name': 'Uber Connect',
      'subtitle': 'Instant Same-Day Package Express',
      'icon': '🚗',
      'color': '0xFF0f172a',
      'eta': '8-12 Mins',
      'fare': '₹55',
    },
    {
      'name': 'Zepto Express',
      'subtitle': 'Hyperlocal 10-Min Parcel Fetch',
      'icon': '⚡',
      'color': '0xFF7E22CE',
      'eta': '10-12 Mins',
      'fare': '₹40',
    },
    {
      'name': 'Blinkit Flash',
      'subtitle': 'Local Instant Parcel Collection',
      'icon': '🛒',
      'color': '0xFFCA8A04',
      'eta': '12-15 Mins',
      'fare': '₹42',
    },
  ];

  final List<String> _vehicles = [
    '🛵 2-Wheeler Bike Courier',
    '🛺 3-Wheeler Auto Cargo',
    '🛻 8ft Mini Pickup Truck',
  ];

  Future<void> _submitDispatch() async {
    setState(() => _isSubmitting = true);
    try {
      final res = await ApiService.post(
        '/donations/${widget.donationId}/dispatch-courier',
        {
          'provider': _selectedProvider,
          'vehicleType': _selectedVehicle,
          'pickupNotes': _notesController.text.trim(),
        },
      );

      final data = jsonDecode(res.body);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.shade800,
            content: Text(
              data['message'] ?? '🚚 External courier successfully dispatched!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
        widget.onDispatched();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to dispatch courier: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.amber.shade100,
                  child: const Icon(Icons.local_shipping, color: Colors.amber),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🚚 Dispatch External Courier Service',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Item: ${widget.itemTitle}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const Divider(height: 24),

            const Text('1. Select Courier Partner:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),

            Column(
              children: _providers.map((p) {
                final selected = _selectedProvider == p['name'];
                final color = Color(int.parse(p['color']!));
                return GestureDetector(
                  onTap: () => setState(() => _selectedProvider = p['name']!),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selected ? color.withValues(alpha: 0.1) : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? color : Colors.grey.shade300,
                        width: selected ? 2.0 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(p['icon']!, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p['name']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                p['subtitle']!,
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              p['fare']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                            Text(
                              '⏱️ ${p['eta']}',
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),
            const Text('2. Select Vehicle Type:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),

            DropdownButtonFormField<String>(
              initialValue: _selectedVehicle,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _vehicles.map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedVehicle = val);
              },
            ),

            const SizedBox(height: 12),
            const Text('3. Driver Pickup Instructions (Optional):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),

            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                hintText: 'e.g., Call donor before arrival, 2 boxes of clothes ready at security gate.',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade900,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: _isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.rocket_launch, color: Colors.white),
              label: Text(
                _isSubmitting ? 'Dispatching...' : 'Dispatch $_selectedProvider Courier (Sponsored by NGO)',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              onPressed: _isSubmitting ? null : _submitDispatch,
            ),
          ],
        ),
      ),
    );
  }
}

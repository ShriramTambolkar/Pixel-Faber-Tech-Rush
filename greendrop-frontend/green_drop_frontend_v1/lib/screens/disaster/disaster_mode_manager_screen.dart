import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class DisasterModeManagerScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const DisasterModeManagerScreen({super.key, required this.user});

  @override
  State<DisasterModeManagerScreen> createState() =>
      _DisasterModeManagerScreenState();
}

class _DisasterModeManagerScreenState
    extends State<DisasterModeManagerScreen> {
  bool _isDisasterMode = false;
  String _disasterType = 'Flood Relief Emergency';
  final _reasonCtrl = TextEditingController();
  final _materialsCtrl = TextEditingController(text: 'Clean Water, Medicines, Blankets, Dry Ration');
  final _dropoffCtrl = TextEditingController(text: 'Disaster Relief Hub, Pune Collectorate');

  final List<String> _disasterTypes = [
    'Flood Relief Emergency',
    'Earthquake Disaster',
    'Fire Emergency',
    'Cyclone / Hurricane',
    'Landslide Crisis',
    'Drought Relief',
    'Other Disaster Emergency'
  ];

  @override
  void initState() {
    super.initState();
    final ngo = widget.user['ngoDetails'];
    if (ngo != null) {
      _isDisasterMode = ngo['isDisasterMode'] ?? false;
      if (ngo['disasterType'] != null && _disasterTypes.contains(ngo['disasterType'])) {
        _disasterType = ngo['disasterType'];
      } else {
        _disasterType = _disasterTypes[0];
      }
      if (ngo['disasterReason'] != null) _reasonCtrl.text = ngo['disasterReason'];
      if (ngo['requiredMaterials'] != null) _materialsCtrl.text = ngo['requiredMaterials'];
      if (ngo['dropoffAddress'] != null) _dropoffCtrl.text = ngo['dropoffAddress'];
    }
  }

  Future<void> _toggleMode(bool val) async {
    final res = await ApiService.patch('/ngo/disaster-mode', {
      'ngoId': widget.user['_id'],
      'isDisasterMode': val,
      'disasterType': _disasterType,
      'reason': _reasonCtrl.text,
      'requiredMaterials': _materialsCtrl.text,
      'dropoffAddress': _dropoffCtrl.text,
    });
    if (res.statusCode == 200) {
      setState(() => _isDisasterMode = val);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: val ? Colors.red.shade800 : Colors.green,
          content: Text(
            val
                ? '🚨 Emergency Disaster Relief Broadcast ACTIVATED!'
                : '✅ Disaster Relief Broadcast Deactivated.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: _isDisasterMode ? Colors.red.shade50 : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: _isDisasterMode ? Colors.red : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SwitchListTile(
                    activeThumbColor: Colors.red,
                    title: Text(
                      _isDisasterMode
                          ? '🚨 EMERGENCY DISASTER MODE IS ACTIVE'
                          : '🚨 Activate Emergency Disaster Mode',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _isDisasterMode ? Colors.red.shade900 : Colors.black,
                      ),
                    ),
                    subtitle: const Text(
                      'Broadcasts urgent disaster demands to all donors across the platform.',
                    ),
                    value: _isDisasterMode,
                    onChanged: _toggleMode,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '📋 Disaster Relief Declaration Form',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _disasterTypes.contains(_disasterType) ? _disasterType : _disasterTypes[0],
            decoration: const InputDecoration(
              labelText: 'Kind of Disaster Occurred *',
              border: OutlineInputBorder(),
            ),
            items: _disasterTypes
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (v) => setState(() => _disasterType = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reasonCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Disaster Context & Situation Description (Mandatory) *',
              hintText: 'Explain the ground situation, affected area, and urgency...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _materialsCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Required Emergency Materials List *',
              hintText: 'e.g. Blankets, First Aid Kits, Bottled Water, Tarpaulins',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dropoffCtrl,
            decoration: const InputDecoration(
              labelText: 'Emergency Relief Drop-off Location Address *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: _isDisasterMode ? Colors.red.shade800 : Colors.green.shade800,
            ),
            icon: const Icon(Icons.broadcast_on_personal, color: Colors.white),
            label: Text(
              _isDisasterMode ? 'Update Disaster Broadcast' : 'Activate & Broadcast Disaster Mode',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onPressed: () => _toggleMode(_isDisasterMode),
          )
        ],
      ),
    );
  }
}

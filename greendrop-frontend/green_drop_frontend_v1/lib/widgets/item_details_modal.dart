import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ItemDetailsModal extends StatelessWidget {
  final Map<String, dynamic> item;

  const ItemDetailsModal({super.key, required this.item});

  static void show(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (c) => ItemDetailsModal(item: item),
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
    final photoUrl = (item['photoUrls'] != null && item['photoUrls'].isNotEmpty)
        ? item['photoUrls'][0]
        : '';
    final status = item['status'] ?? 'AVAILABLE';
    final isAccepted = status == 'ACCEPTED';
    final formattedAddress = item['address']?['formattedAddress'] ?? 'Pune, India';
    final ngoOfficeAddress =
        item['requestedByNgoOfficeAddress'] ?? 'Pune Registered Office';

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (photoUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: photoUrl.startsWith('data:image')
                    ? Image.memory(
                        base64Decode(photoUrl.split(',').last),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        photoUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            Container(height: 150, color: Colors.grey.shade300, child: const Icon(Icons.inventory, size: 60)),
                      ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item['title'] ?? 'Donation Item',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                Chip(
                  label: Text(status),
                  backgroundColor: status == 'ACCEPTED'
                      ? Colors.green.shade100
                      : (status == 'REQUESTED' ? Colors.orange.shade100 : Colors.blue.shade100),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text('📦 Category: ${item['category']}'),
            Text('✨ Condition: ${item['condition'] ?? 'Good'}'),
            Text('⚖️ Est. Weight: ${item['weightKg']} kg'),
            Text('🔐 Verification Code: ${item['verificationCode']}'),
            Text('👤 Donor Name: ${item['donorName']}'),
            if (item['requestedByNgoName'] != null)
              Text('🏢 Requested NGO: ${item['requestedByNgoName']}'),
            const Divider(height: 24),
            if (isAccepted) ...[
              const Text(
                '📍 Unlocked Pickup & Office Locations:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
              ),
              const SizedBox(height: 8),
              Card(
                color: Colors.green.shade50,
                child: ListTile(
                  title: const Text('Donor Pickup Location'),
                  subtitle: Text(formattedAddress),
                  trailing: IconButton(
                    icon: const Icon(Icons.map, color: Colors.green),
                    onPressed: () => _openMap(formattedAddress),
                    tooltip: 'Open in Google Maps',
                  ),
                ),
              ),
              Card(
                color: Colors.blue.shade50,
                child: ListTile(
                  title: const Text('NGO Registered Office Address'),
                  subtitle: Text(ngoOfficeAddress),
                  trailing: IconButton(
                    icon: const Icon(Icons.map, color: Colors.blue),
                    onPressed: () => _openMap(ngoOfficeAddress),
                    tooltip: 'Open in Google Maps',
                  ),
                ),
              ),
            ] else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock, color: Colors.grey),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Addresses and location sharing unlock automatically when the Donor accepts the NGO request.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

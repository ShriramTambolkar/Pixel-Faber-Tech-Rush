import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ReportDialog extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;
  final String targetUserId;
  final String targetUserName;
  final String title;

  const ReportDialog({
    super.key,
    required this.currentUserId,
    required this.currentUserName,
    required this.targetUserId,
    required this.targetUserName,
    required this.title,
  });

  static void show(
    BuildContext context, {
    required String currentUserId,
    required String currentUserName,
    required String targetUserId,
    required String targetUserName,
    required String title,
  }) {
    showDialog(
      context: context,
      builder: (c) => ReportDialog(
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        targetUserId: targetUserId,
        targetUserName: targetUserName,
        title: title,
      ),
    );
  }

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String _selectedCategory = 'Spam / Scam';
  final _reasonCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Report ${widget.targetUserName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: [
              'Spam / Scam',
              'Fake Listing / Proofs',
              'Abusive Behavior',
              'No-Show on Pickup',
              'Other'
            ].contains(_selectedCategory)
                ? _selectedCategory
                : 'Spam / Scam',
            decoration: const InputDecoration(
              labelText: 'Violation Category',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Spam / Scam', child: Text('Spam / Scam')),
              DropdownMenuItem(
                value: 'Fake Listing / Proofs',
                child: Text('Fake Listing / Proofs'),
              ),
              DropdownMenuItem(
                value: 'Abusive Behavior',
                child: Text('Abusive Behavior'),
              ),
              DropdownMenuItem(
                value: 'No-Show on Pickup',
                child: Text('No-Show on Pickup'),
              ),
              DropdownMenuItem(value: 'Other', child: Text('Other')),
            ],
            onChanged: (v) => setState(() => _selectedCategory = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reasonCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Detailed Explanation (Mandatory)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            final navigator = Navigator.of(context);
            if (_reasonCtrl.text.trim().isEmpty) {
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Reason is required for submitting a report!'),
                ),
              );
              return;
            }
            await ApiService.post('/reports', {
              'reportedByUserId': widget.currentUserId,
              'reportedByUserName': widget.currentUserName,
              'targetUserId': widget.targetUserId,
              'targetUserName': widget.targetUserName,
              'reportCategory': _selectedCategory,
              'reason': _reasonCtrl.text,
              'itemOrEventTitle': widget.title,
            });
            navigator.pop();
            messenger.showSnackBar(
              const SnackBar(
                content: Text(
                  'Report submitted to Platform Admin for review.',
                ),
              ),
            );
          },
          child: const Text('Submit Report'),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/api_service.dart';

class QrCollectionModal extends StatefulWidget {
  final String donationId;
  final String verificationCode;
  final String itemTitle;
  final bool isNgo;

  const QrCollectionModal({
    super.key,
    required this.donationId,
    required this.verificationCode,
    required this.itemTitle,
    required this.isNgo,
  });

  static void show(
    BuildContext context, {
    required String donationId,
    required String verificationCode,
    required String itemTitle,
    required bool isNgo,
    VoidCallback? onCollectionVerified,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (c) => QrCollectionModal(
        donationId: donationId,
        verificationCode: verificationCode,
        itemTitle: itemTitle,
        isNgo: isNgo,
      ),
    ).then((_) => onCollectionVerified?.call());
  }

  @override
  State<QrCollectionModal> createState() => _QrCollectionModalState();
}

class _QrCollectionModalState extends State<QrCollectionModal> {
  final _codeCtrl = TextEditingController();
  bool _isVerifying = false;

  Future<void> _verifyCode() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) return;
    setState(() => _isVerifying = true);

    try {
      final res = await ApiService.post(
        '/donations/${widget.donationId}/verify-collection',
        {'code': code},
      );
      if (res.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('🎉 Code verified! Donor screen now unlocked to confirm final handover.'),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('❌ Invalid verification code! Please check code on donor device.'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.isNgo
                  ? '📱 Scan / Verify Collection Code'
                  : '📱 Donor Handover QR Pass',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Item: ${widget.itemTitle}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const Divider(height: 24),
            // QR CODE VIEW
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade300, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade100,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: QrImageView(
                data: widget.verificationCode,
                version: QrVersions.auto,
                size: 180.0,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Verification Code: ${widget.verificationCode}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.green.shade900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.isNgo
                  ? 'Ask donor to show this QR code or enter code above during physical pickup.'
                  : 'Show this QR code to the NGO volunteer during item pickup.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (widget.isNgo) ...[
              TextField(
                controller: _codeCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter 6-Digit Code from Donor Mobile',
                  prefixIcon: Icon(Icons.qr_code_scanner),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.green.shade800,
                ),
                icon: _isVerifying
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.verified, color: Colors.white),
                label: const Text(
                  'Confirm Collection Handover',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: _isVerifying ? null : _verifyCode,
              ),
            ],
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close Pass'),
            )
          ],
        ),
      ),
    );
  }
}

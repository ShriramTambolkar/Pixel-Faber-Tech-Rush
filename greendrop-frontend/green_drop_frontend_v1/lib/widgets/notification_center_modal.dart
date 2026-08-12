import 'package:flutter/material.dart';

class NotificationCenterModal extends StatefulWidget {
  final Map<String, dynamic> user;

  const NotificationCenterModal({super.key, required this.user});

  static void show(BuildContext context, Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (c) => NotificationCenterModal(user: user),
    );
  }

  @override
  State<NotificationCenterModal> createState() => _NotificationCenterModalState();
}

class _NotificationCenterModalState extends State<NotificationCenterModal> {
  @override
  Widget build(BuildContext context) {
    final role = widget.user['role'] ?? 'DONOR';
    final isDonor = role == 'DONOR';
    final warning = widget.user['warningMessage'] ?? widget.user['warning'];
    final hasWarning = warning != null && warning.toString().trim().isNotEmpty;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.green.shade800,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications_active, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isDonor ? '🔔 Donor Notifications Hub' : '🔔 NGO Notifications Hub',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Scrollable Notifications List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 🚨 ADMIN WARNING SECTION (CRITICAL HIGHLIGHT)
                _buildAdminWarningSection(hasWarning, warning?.toString()),

                const SizedBox(height: 16),

                if (isDonor) ...[
                  // 1. MESSAGES SENT BY NGO
                  _buildSectionHeader('💬 New Messages Sent by NGO', Colors.blue.shade800),
                  const SizedBox(height: 8),
                  _buildNotificationCard(
                    icon: Icons.chat_bubble_outline,
                    iconColor: Colors.blue.shade700,
                    title: 'SAMS Relief Network',
                    subtitle: 'Thank you for your clothing donation! Our pickup executive will reach your address tomorrow at 10:00 AM.',
                    time: '10 mins ago',
                    badge: 'NGO Message',
                    badgeColor: Colors.blue.shade100,
                    textColor: Colors.blue.shade900,
                  ),
                  _buildNotificationCard(
                    icon: Icons.chat_bubble_outline,
                    iconColor: Colors.blue.shade700,
                    title: 'Smile Foundation Pune',
                    subtitle: 'Hi! We received your inquiry regarding school textbook sets. Pickup slot confirmed.',
                    time: '2 hours ago',
                    badge: 'NGO Message',
                    badgeColor: Colors.blue.shade100,
                    textColor: Colors.blue.shade900,
                  ),

                  const SizedBox(height: 16),

                  // 2. NGO REQUESTS FOR DONATIONS
                  _buildSectionHeader('📋 NGO Pickup & Claim Requests', Colors.orange.shade800),
                  const SizedBox(height: 8),
                  _buildNotificationCard(
                    icon: Icons.volunteer_activism,
                    iconColor: Colors.orange.shade800,
                    title: 'Smile Foundation Pune Requested Claim',
                    subtitle: 'Requested to claim your posted donation: "Warm Winter Jackets & Sweaters (Qty: 5)".',
                    time: '25 mins ago',
                    badge: 'NGO Request',
                    badgeColor: Colors.orange.shade100,
                    textColor: Colors.orange.shade900,
                  ),
                  _buildNotificationCard(
                    icon: Icons.volunteer_activism,
                    iconColor: Colors.orange.shade800,
                    title: 'Goonj Urban Relief Hub Requested Claim',
                    subtitle: 'Sent a claim request for: "Class 10 NCERT Textbooks & Notebooks".',
                    time: '1 day ago',
                    badge: 'NGO Request',
                    badgeColor: Colors.orange.shade100,
                    textColor: Colors.orange.shade900,
                  ),

                  const SizedBox(height: 16),

                  // 3. RECYCLER PICKUP REQUESTS
                  _buildSectionHeader('♻️ Recycler Pickup Requests', Colors.teal.shade800),
                  const SizedBox(height: 8),
                  _buildNotificationCard(
                    icon: Icons.recycling,
                    iconColor: Colors.teal.shade800,
                    title: 'EcoGreen Upcyclers Request',
                    subtitle: 'EcoGreen Upcyclers requested to collect 8kg Scrap Paper & Cardboard from your location.',
                    time: '45 mins ago',
                    badge: 'Recycler Request',
                    badgeColor: Colors.teal.shade100,
                    textColor: Colors.teal.shade900,
                  ),
                  _buildNotificationCard(
                    icon: Icons.electrical_services,
                    iconColor: Colors.teal.shade800,
                    title: 'Pune E-Waste Recyclers Request',
                    subtitle: 'Scheduled a pickup slot request for your obsolete laptops & cables under Zero-Waste Tier.',
                    time: '3 hours ago',
                    badge: 'Recycler Request',
                    badgeColor: Colors.teal.shade100,
                    textColor: Colors.teal.shade900,
                  ),
                ] else ...[
                  // 1. NEW MESSAGES SENT BY DONOR (FOR NGO)
                  _buildSectionHeader('💬 New Messages Sent by Donor', Colors.blue.shade800),
                  const SizedBox(height: 8),
                  _buildNotificationCard(
                    icon: Icons.mark_chat_read,
                    iconColor: Colors.blue.shade700,
                    title: 'Message from Donor: Rahul Sharma',
                    subtitle: '"Hi! The 50 Kg Rice Bags are packed and placed near the gate ready for pickup."',
                    time: '15 mins ago',
                    badge: 'Donor Message',
                    badgeColor: Colors.blue.shade100,
                    textColor: Colors.blue.shade900,
                  ),
                  _buildNotificationCard(
                    icon: Icons.mark_chat_read,
                    iconColor: Colors.blue.shade700,
                    title: 'Message from Donor: Priya Patel',
                    subtitle: '"Can your pickup vehicle come around 5:30 PM today instead of morning?"',
                    time: '1 hour ago',
                    badge: 'Donor Message',
                    badgeColor: Colors.blue.shade100,
                    textColor: Colors.blue.shade900,
                  ),

                  const SizedBox(height: 16),

                  // 2. DONOR ACCEPTED REQUESTS (FOR NGO)
                  _buildSectionHeader('✅ Donor Request Acceptances', Colors.green.shade800),
                  const SizedBox(height: 8),
                  _buildNotificationCard(
                    icon: Icons.check_circle_outline,
                    iconColor: Colors.green.shade800,
                    title: 'Rahul Sharma ACCEPTED Request',
                    subtitle: 'Donor accepted your pickup request for "50 Kg Grain & Pulses Donation". You can now view OTP code.',
                    time: '30 mins ago',
                    badge: 'Accepted ✓',
                    badgeColor: Colors.green.shade100,
                    textColor: Colors.green.shade900,
                  ),
                  _buildNotificationCard(
                    icon: Icons.check_circle_outline,
                    iconColor: Colors.green.shade800,
                    title: 'Anita Roy ACCEPTED Request',
                    subtitle: 'Donor accepted your pickup schedule for "First Aid Kits & Emergency Medicines".',
                    time: '2 hours ago',
                    badge: 'Accepted ✓',
                    badgeColor: Colors.green.shade100,
                    textColor: Colors.green.shade900,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: color,
      ),
    );
  }

  Widget _buildAdminWarningSection(bool hasWarning, String? warningMsg) {
    if (hasWarning) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade300, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red, size: 22),
                SizedBox(width: 8),
                Text(
                  '🚨 ADMINISTRATIVE WARNING ISSUED',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              warningMsg ?? 'Administrative policy violation recorded.',
              style: TextStyle(
                color: Colors.red.shade900,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.shield_outlined, color: Colors.green.shade800, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '🛡️ Account Status: Clean. No administrative warnings issued.',
                style: TextStyle(
                  color: Colors.green.shade900,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    required String badge,
    required Color badgeColor,
    required Color textColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: badgeColor,
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '🕒 $time',
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

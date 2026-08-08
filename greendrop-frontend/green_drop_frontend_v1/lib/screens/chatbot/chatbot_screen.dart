import 'package:flutter/material.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _ctrl = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'sender': 'bot',
      'text':
          'Hello! How can I assist you today? Select a quick question or type below.'
    }
  ];

  void _handleUserQuery(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add({'sender': 'user', 'text': text});
    });

    String reply =
        "I'm here to help! For complex or account-specific inquiries, feel free to reach out to support@greendrop.org.";
    final q = text.toLowerCase();

    if (q.contains('accept') || q.contains('location') || q.contains('address')) {
      reply =
          "Once an NGO requests your donation, tap 'Accept Request' on the item card. This safely reveals your pickup address to the verified NGO and unlocks 1-on-1 chat!";
    } else if (q.contains('disaster') || q.contains('emergency') || q.contains('relief') || q.contains('flood')) {
      reply =
          "NGOs in emergency situations can toggle 'Disaster Relief Mode' to broadcast a real-time 32px emergency ticker banner across the top of the dashboard for all donors!";
    } else if (q.contains('donate') || q.contains('post') || q.contains('item') || q.contains('add')) {
      reply =
          "To donate an item: Tap the green '+' button on the Home screen, upload a photo using your camera or phone gallery, fill in the category & details, and tap 'Post Donation'!";
    } else if (q.contains('qr') || q.contains('code') || q.contains('pass') || q.contains('verification') || q.contains('handshake')) {
      reply =
          "Every claimed donation generates a 6-Digit Verification Pass. When the NGO volunteer arrives at your door, share or scan your 6-digit code to complete the handover securely!";
    } else if (q.contains('impact') || q.contains('co2') || q.contains('point') || q.contains('landfill') || q.contains('water')) {
      reply =
          "Your Impact Score tracks CO₂ emissions prevented and landfill waste diverted! Check the 'Impact' tab on the bottom bar to watch your environmental score count up live!";
    } else if (q.contains('ngo') || q.contains('darpan') || q.contains('verify') || q.contains('trust')) {
      reply =
          "All NGOs on GreenDrop are pre-verified with official NITI Aayog DARPAN Portal IDs, 80G tax exemptions, and government certificates to ensure 100% trust and safety.";
    } else if (q.contains('chat') || q.contains('message') || q.contains('contact')) {
      reply =
          "You can chat 1-on-1 with an NGO once a donation request is accepted! Go to the donation card or tap the Chat icon to coordinate doorstep pickup timing.";
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _messages.add({'sender': 'bot', 'text': reply}));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length,
            itemBuilder: (c, i) {
              final isBot = _messages[i]['sender'] == 'bot';
              return Align(
                alignment:
                    isBot ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isBot ? Colors.green.shade100 : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_messages[i]['text'] ?? ''),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  decoration: const InputDecoration(
                    hintText: 'Ask GreenDrop AI...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  _handleUserQuery(_ctrl.text);
                  _ctrl.clear();
                },
              ),
            ],
          ),
        )
      ],
    );
  }
}

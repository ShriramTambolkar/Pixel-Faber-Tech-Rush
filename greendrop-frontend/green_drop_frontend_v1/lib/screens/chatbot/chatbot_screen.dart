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
        "I'm here to help! Contact support@greendrop.org for complex queries.";
    final q = text.toLowerCase();
    if (q.contains('accept') || q.contains('location')) {
      reply =
          "Once an NGO requests your donation, click 'Accept Request' on the item card. This automatically reveals your pickup address to the NGO and unlocks chat!";
    } else if (q.contains('disaster')) {
      reply =
          "NGOs in emergency situations can activate Disaster Mode to broadcast urgent supply demands directly onto the main items dashboard.";
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

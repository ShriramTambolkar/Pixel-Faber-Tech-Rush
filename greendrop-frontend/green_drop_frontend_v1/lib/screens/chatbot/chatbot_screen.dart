import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _ctrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  final List<Map<String, String>> _messages = [
    {
      'sender': 'bot',
      'text':
          '🤖 Welcome to GreenDrop Master AI Assistant!\n\nI am your 24/7 smart concierge. Ask me anything about 80G tax receipts, 2-way verification passcodes, Porter/Uber courier dispatch, MapmyIndia navigation, or disaster relief drives!'
    }
  ];

  final List<String> _quickPrompts = [
    '📜 How do 80G Tax Receipts work?',
    '🔐 What is the 2-Way Passcode Handshake?',
    '🚚 How to dispatch Porter or Uber Courier?',
    '🗺️ How to view NGO offices on MapmyIndia?',
    '🚨 How does Disaster Relief Ticker work?',
    '📄 How can Admin view NGO legal documents?',
    '📋 How to respond to NGO Demand Requests?',
  ];

  Widget _buildFormattedText(String text, bool isBot) {
    // Remove raw ** asterisks cleanly so no literal asterisks show on screen
    final cleanText = text.replaceAll('**', '').replaceAll('*', '•');
    return Text(
      cleanText,
      style: TextStyle(
        color: isBot ? Colors.black87 : Colors.white,
        fontSize: 13.5,
        height: 1.45,
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _isThinking = false;

  Future<void> _handleUserQuery(String text) async {
    if (text.trim().isEmpty || _isThinking) return;

    final userQuery = text.trim();
    setState(() {
      _messages.add({'sender': 'user', 'text': userQuery});
      _isThinking = true;
    });
    _scrollToBottom();

    String reply = '';

    // 1. Direct Generative Google Gemini 3.6 Flash AI Call
    try {
      final res = await ApiService.post('/chatbot/gemini', {'prompt': userQuery});
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['reply'] != null && data['reply'].toString().isNotEmpty) {
          reply = data['reply'].toString().trim();
        }
      }
    } catch (e) {
      // Offline fallback
    }

    // 2. Intelligent fallback ONLY if network or API is completely unavailable
    if (reply.isEmpty) {
      final q = userQuery.toLowerCase();
      if (q.contains('donor') || q.contains('how to use') || q.contains('guide')) {
        reply =
            "🙋 **GreenDrop Donor Guide**:\n\n1. Tap '+' to list unused items.\n2. Local verified NGOs browse and request your item.\n3. Accept request & share 6-digit QR Pass at doorstep.\n4. Earn live 80G tax receipt and CO₂ impact points!";
      } else if (q.contains('tax') || q.contains('80g')) {
        reply = "📜 **80G Tax Receipts**: Generated automatically under Profile after completing donation handovers with verified NGOs.";
      } else if (q.contains('courier') || q.contains('porter') || q.contains('uber')) {
        reply = "🚚 **Courier Dispatch**: NGOs can dispatch Porter or Uber Connect couriers directly from the donation feed with live driver tracking!";
      } else if (q.contains('disaster') || q.contains('relief')) {
        reply = "🚨 **Disaster Relief**: NGOs toggle emergency mode to broadcast a 32px top ticker across all donor screens for instant supply matching.";
      } else {
        reply = "🤖 I am GreenDrop AI! I can guide you on donation listings, 80G tax receipts, Porter courier dispatches, 2-way passcodes, and disaster relief drives.";
      }
    }

    if (!mounted) return;
    setState(() {
      _isThinking = false;
      _messages.add({'sender': 'bot', 'text': reply});
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // QUICK PROMPTS HORIZONTAL CAROUSEL
        Container(
          height: 48,
          color: Colors.green.shade50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            itemCount: _quickPrompts.length,
            itemBuilder: (c, i) {
              final prompt = _quickPrompts[i];
              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: ActionChip(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.green.shade600),
                  label: Text(
                    prompt,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                  ),
                  onPressed: () => _handleUserQuery(prompt),
                ),
              );
            },
          ),
        ),

        // CHAT MESSAGES LIST
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length,
            itemBuilder: (c, i) {
              final m = _messages[i];
              final isBot = m['sender'] == 'bot';
              return Align(
                alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isBot ? Colors.white : Colors.green.shade800,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(14),
                      topRight: const Radius.circular(14),
                      bottomLeft: isBot ? Radius.zero : const Radius.circular(14),
                      bottomRight: isBot ? const Radius.circular(14) : Radius.zero,
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                    ],
                    border: isBot ? Border.all(color: Colors.green.shade300) : null,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isBot) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/ai_chat_icon.png',
                            height: 24,
                            width: 24,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: _buildFormattedText(m['text'] ?? '', isBot),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (_isThinking) const LinearProgressIndicator(color: Colors.green, minHeight: 3),

        // INPUT BAR
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  onSubmitted: (val) {
                    _handleUserQuery(val);
                    _ctrl.clear();
                  },
                  decoration: InputDecoration(
                    hintText: 'Ask GreenDrop Master AI Bot...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.green.shade800,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 18),
                  onPressed: () {
                    _handleUserQuery(_ctrl.text);
                    _ctrl.clear();
                  },
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

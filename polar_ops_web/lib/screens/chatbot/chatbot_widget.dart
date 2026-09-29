import 'package:flutter/material.dart';
import '../../services/chatbot_service.dart';

class ChatbotWidget extends StatefulWidget {
  const ChatbotWidget({super.key});

  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  final TextEditingController _ctrl = TextEditingController();
  final ChatbotService _service = ChatbotService();
  final List<String> _msgs = ["System: Hello! How can I assist you with POLAR-OPS today?"];
  bool _isTyping = false;

  void _send() async {
    if (_ctrl.text.isEmpty) return;
    String userText = _ctrl.text;
    setState(() {
      _msgs.add("You: $userText");
      _ctrl.clear();
      _isTyping = true;
    });

    await Future.delayed(const Duration(milliseconds: 600));

    ChatResponse response = _service.processMessage(userText);
    setState(() {
      _isTyping = false;
      _msgs.add("Bot: ${response.text}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 400, height: 600,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor,
              child: const Row(
                children: [
                  Icon(Icons.smart_toy, color: Colors.white),
                  SizedBox(width: 8),
                  Text('POLAR-AI Assistant', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _msgs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(_msgs[index], style: TextStyle(color: _msgs[index].startsWith("You") ? Colors.blue : Colors.white)),
                  );
                },
              ),
            ),
            if (_isTyping) const Padding(padding: EdgeInsets.all(8), child: Align(alignment: Alignment.centerLeft, child: Text('typing...', style: TextStyle(color: Colors.grey)))),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8,
                children: [
                  ActionChip(label: const Text('Where is CARGO-1042?'), onPressed: () { _ctrl.text = 'Where is CARGO-1042?'; _send(); }),
                  ActionChip(label: const Text('मुझे Bharati का low-stock inventory दिखाओ'), onPressed: () { _ctrl.text = 'मुझे Bharati का low-stock inventory दिखाओ'; _send(); }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(hintText: 'Type your message...', border: OutlineInputBorder()),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.send), onPressed: _send),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

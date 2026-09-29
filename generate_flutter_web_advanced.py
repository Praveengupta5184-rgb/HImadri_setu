import os

base_dir = "polar_ops_web/lib"

def write_file(path, content):
    full_path = os.path.join(base_dir, path)
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, "w", encoding="utf-8") as f:
        f.write(content)

# 1. Chatbot Service with NLP
write_file("services/chatbot_service.dart", """class ChatResponse {
  final String text;
  final String action;
  final dynamic data;
  ChatResponse({required this.text, required this.action, this.data});
}

class ChatbotService {
  ChatResponse processMessage(String msg) {
    String message = msg.toLowerCase();
    
    if (message.contains('where is cargo') || message.contains('cargo')) {
      return ChatResponse(
        text: 'Cargo CARGO-1042 is currently IN_TRANSIT at Mumbai Port. Expected delivery: 2026-10-15.',
        action: 'SHOW_CARGO',
        data: {'id': 'CARGO-1042'}
      );
    }
    
    if (message.contains('low-stock') || message.contains('inventory') || message.contains('मुझे') || message.contains('दिखाओ')) {
      return ChatResponse(
        text: '12 items are low stock in Bharati Station. Showing details...',
        action: 'SHOW_INVENTORY',
        data: []
      );
    }
    
    if (message.contains('fire') || message.contains('emergency')) {
      return ChatResponse(
        text: 'Emergency incident created for fire in Lab 2. Response team dispatched.',
        action: 'SHOW_EMERGENCY',
        data: {}
      );
    }
    
    return ChatResponse(
      text: 'I did not understand. Please try: "Where is cargo CARGO-1042?" or "मुझे Bharati का low-stock inventory दिखाओ"',
      action: 'NONE',
    );
  }
}
""")

# 2. Chatbot Widget Update
write_file("screens/chatbot/chatbot_widget.dart", """import 'package:flutter/material.dart';
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
""")

# 3. 3D Digital Twin Vector Representation
write_file("screens/twin/digital_twin_screen.dart", """import 'package:flutter/material.dart';

class DigitalTwinScreen extends StatefulWidget {
  const DigitalTwinScreen({super.key});
  @override
  State<DigitalTwinScreen> createState() => _DigitalTwinScreenState();
}

class _DigitalTwinScreenState extends State<DigitalTwinScreen> {
  String? selectedRoom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('3D Digital Twin - Maitri Station', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  ElevatedButton.icon(icon: const Icon(Icons.layers), label: const Text('Toggle Assets'), onPressed: () {}),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(icon: const Icon(Icons.warning, color: Colors.red), label: const Text('Evacuation Route'), onPressed: () {}),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey), color: Colors.black26),
                    child: Stack(
                      children: [
                        Center(child: Text('Interactive 3D Isometric View\\n(Use mouse to pan/zoom)', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600]))),
                        // Simulating 3D cubes using isometric transform
                        Positioned(top: 100, left: 150, child: Transform(transform: Matrix4.identity()..rotateX(0.5)..rotateZ(0.5), child: _buildCube('Lab 1', Colors.green))),
                        Positioned(top: 250, left: 250, child: Transform(transform: Matrix4.identity()..rotateX(0.5)..rotateZ(0.5), child: _buildCube('Lab 2 (Fire)', Colors.red))),
                        Positioned(top: 100, left: 350, child: Transform(transform: Matrix4.identity()..rotateX(0.5)..rotateZ(0.5), child: _buildCube('Main Storage', Colors.orange))),
                        Positioned(top: 250, left: 450, child: Transform(transform: Matrix4.identity()..rotateX(0.5)..rotateZ(0.5), child: _buildCube('Living Quarters', Colors.green))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 1,
                  child: selectedRoom == null 
                    ? const Center(child: Text('Click a room for details')) 
                    : _buildRoomDetails(),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCube(String name, Color statusColor) {
    return InkWell(
      onTap: () { setState(() { selectedRoom = name; }); },
      child: Container(
        width: 150, height: 150,
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.4),
          border: Border.all(color: statusColor, width: 2),
        ),
        child: Center(child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center)),
      ),
    );
  }

  Widget _buildRoomDetails() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Room: $selectedRoom', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            const Text('Inventory Levels:', style: TextStyle(fontWeight: FontWeight.bold)),
            const LinearProgressIndicator(value: 0.3, color: Colors.orange, backgroundColor: Colors.grey),
            const SizedBox(height: 16),
            const Text('Personnel: 2', style: TextStyle(fontWeight: FontWeight.bold)),
            const ListTile(leading: Icon(Icons.person), title: Text('Dr. Sharma')),
            const Divider(),
            const Text('Emergency Equipment:', style: TextStyle(fontWeight: FontWeight.bold)),
            const Text('✅ Fire Extinguisher (Inspected)\\n✅ Medical Kit (Fully Stocked)'),
            const Spacer(),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(double.infinity, 50)),
              child: const Text('TRIGGER SOS HERE'),
            )
          ],
        ),
      ),
    );
  }
}
""")

print("Advanced Web modifications generated successfully.")

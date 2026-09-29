class ChatResponse {
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

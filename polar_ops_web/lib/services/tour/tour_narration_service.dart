import 'package:flutter_tts/flutter_tts.dart';

class TourNarrationService {
  static final FlutterTts _tts = FlutterTts();
  static bool _isEnabled = true;

  static Future<void> initialize() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (!enabled) stop();
  }

  static Future<void> speak(String text) async {
    if (!_isEnabled) return;
    await stop();
    await _tts.speak(text);
  }

  static Future<void> stop() async {
    await _tts.stop();
  }
}

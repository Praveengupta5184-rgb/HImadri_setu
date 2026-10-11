import 'package:shared_preferences/shared_preferences.dart';

class TourService {
  static const String _tourVersionKey = 'polar_ops_tour_version';
  static const int _currentTourVersion = 1;

  static Future<bool> shouldShowTour() async {
    final prefs = await SharedPreferences.getInstance();
    final savedVersion = prefs.getInt(_tourVersionKey) ?? 0;
    return savedVersion < _currentTourVersion;
  }

  static Future<void> markTourCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tourVersionKey, _currentTourVersion);
  }
}

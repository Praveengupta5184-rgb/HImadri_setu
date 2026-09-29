import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  bool isOffline = true;
  String currentStation = "Maitri";

  void toggleOfflineMode() {
    isOffline = !isOffline;
    notifyListeners();
  }
}

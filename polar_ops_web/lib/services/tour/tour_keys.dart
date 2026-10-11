import 'package:flutter/material.dart';

class TourKeys {
  static final GlobalKey dashboard = GlobalKey();
  static final GlobalKey mission = GlobalKey();
  static final GlobalKey personnel = GlobalKey();
  static final GlobalKey cargo = GlobalKey();
  static final GlobalKey inventory = GlobalKey();
  static final GlobalKey asset = GlobalKey();
  static final GlobalKey emergency = GlobalKey();
  static final GlobalKey map = GlobalKey();
  static final GlobalKey twin = GlobalKey();
  static final GlobalKey ai = GlobalKey();
  static final GlobalKey reports = GlobalKey();
  static final GlobalKey help = GlobalKey();

  static List<GlobalKey> get allKeys => [
    help,
    dashboard,
    mission,
    cargo,
    inventory,
    personnel,
    asset,
    map,
    emergency,
    twin,
    ai,
    reports
  ];
}

import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../theme/app_theme.dart';
import '../../services/tour/tour_narration_service.dart';

class TourStepWidget extends StatelessWidget {
  final String title;
  final String description;
  final String narration;

  const TourStepWidget({
    super.key,
    required this.title,
    required this.description,
    required this.narration,
  });

  @override
  Widget build(BuildContext context) {
    // Start narration when widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TourNarrationService.speak(narration);
    });

    return Container(
      width: 320,
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.secondaryNavy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.accentCyan,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            description,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: AppTheme.spacingSm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  TourNarrationService.stop();
                  ShowCaseWidget.of(context).previous();
                },
                child: const Text('Back', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ),
              TextButton(
                onPressed: () {
                  TourNarrationService.stop();
                  ShowCaseWidget.of(context).next();
                },
                child: const Text('Skip This Step', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentCyan,
                  foregroundColor: AppTheme.primaryNavy,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                ),
                onPressed: () {
                  TourNarrationService.stop();
                  ShowCaseWidget.of(context).next();
                },
                child: const Text('Next', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Center(
            child: TextButton(
              onPressed: () {
                TourNarrationService.stop();
                ShowCaseWidget.of(context).dismiss();
              },
              child: const Text('Skip Tour', style: TextStyle(color: AppTheme.statusCritical, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../theme/app_theme.dart';
import '../../services/tour/tour_service.dart';

class TourWelcomeWidget extends StatelessWidget {
  const TourWelcomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentCyan, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentCyan.withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'WELCOME TO POLAR-OPS',
            style: TextStyle(
              color: AppTheme.accentCyan,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          const Text(
            "How to Use POLAR-OPS is always available from this Help (?) icon in the top-right corner.",
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          const Text(
            "Use it anytime to restart the interactive guided tour and learn how Mission Management, Teams, Cargo, Inventory, Assets, Emergency Operations, AI Decision Intelligence and Reports work.",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  TourService.markTourCompleted();
                  ShowCaseWidget.of(context).dismiss();
                },
                child: const Text('Explore', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentCyan,
                  foregroundColor: AppTheme.primaryNavy,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onPressed: () {
                  ShowCaseWidget.of(context).next();
                },
                child: const Text('Start Guided Tour', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Center(
            child: TextButton(
              onPressed: () {
                TourService.markTourCompleted();
                ShowCaseWidget.of(context).dismiss();
              },
              child: const Text("Don't Show Again", style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
            ),
          ),
        ],
      ),
    );
  }
}

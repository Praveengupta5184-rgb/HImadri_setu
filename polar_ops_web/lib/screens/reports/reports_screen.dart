import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingXl),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(children: [
                      Icon(Icons.assessment_outlined,
                          size: 32, color: AppTheme.accentCyan),
                      SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                          child: Text('REPORTING STATUS',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold))),
                    ]),
                    SizedBox(height: AppTheme.spacingLg),
                    Text(
                        'No report-generation endpoint is available in the connected command service.',
                        style:
                            TextStyle(fontSize: 16, color: AppTheme.textMain)),
                    SizedBox(height: AppTheme.spacingSm),
                    Text(
                        'Export controls are intentionally unavailable so that this interface never presents a non-functional report action as complete.',
                        style:
                            TextStyle(color: AppTheme.textMuted, height: 1.45)),
                    SizedBox(height: AppTheme.spacingLg),
                    Divider(),
                    SizedBox(height: AppTheme.spacingSm),
                    Text('AVAILABLE OPERATIONAL VIEWS',
                        style: TextStyle(
                            color: AppTheme.accentCyan,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                    SizedBox(height: AppTheme.spacingSm),
                    Text(
                        'Mission Command, Cargo Operations, Inventory, Personnel, Assets, Emergency Operations, Digital Twin and Mission Simulator display their data in-app.',
                        style:
                            TextStyle(color: AppTheme.textMuted, height: 1.45)),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}

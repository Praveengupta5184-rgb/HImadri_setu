import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/components/state_widgets.dart';

class ModulePlaceholderScreen extends StatelessWidget {
  final String title;

  const ModulePlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textMain,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Expanded(
            child: Card(
              child: StateWidgets.emptyState(
                message: '$title Module Under Construction (Phase 2)',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

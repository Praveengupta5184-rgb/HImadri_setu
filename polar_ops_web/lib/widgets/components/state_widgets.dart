import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class StateWidgets {
  static Widget emptyState({String message = 'No data available'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inventory_2_outlined,
              size: 64, color: AppTheme.textMuted),
          const SizedBox(height: AppTheme.spacingMd),
          Text(message,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 16)),
        ],
      ),
    );
  }

  static Widget loadingState({String message = 'Loading...'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppTheme.accentCyan),
          const SizedBox(height: AppTheme.spacingMd),
          Text(message,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 16)),
        ],
      ),
    );
  }

  static Widget errorState({
    String message = 'Unable to load this operational view.',
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_outlined,
              size: 52, color: AppTheme.statusWarning),
          const SizedBox(height: AppTheme.spacingMd),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textMain, fontSize: 16)),
          const SizedBox(height: AppTheme.spacingSm),
          const Text('Check your connection and try again.',
              style: TextStyle(color: AppTheme.textMuted)),
          if (onRetry != null) ...[
            const SizedBox(height: AppTheme.spacingMd),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('TRY AGAIN'),
            ),
          ],
        ],
      ),
    );
  }
}

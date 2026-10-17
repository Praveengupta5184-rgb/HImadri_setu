import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_theme.dart';

class JudgeDemoSection extends StatelessWidget {
  final void Function(String email, String password) onFillCredentials;

  static const String demoEmail = 'judge.demo@polarops.gov.in';
  static const String demoPassword = 'JudgeDemo@2026';
  static const bool enableDemoAccess = true;

  const JudgeDemoSection({
    super.key,
    required this.onFillCredentials,
  });

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                size: 18, color: AppTheme.accentCyan),
            const SizedBox(width: 8),
            Text(
              '$label copied to clipboard',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F1E36),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1800),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: AppTheme.accentCyan.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!JudgeDemoSection.enableDemoAccess) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B172A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentCyan.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentCyan.withValues(alpha: 0.1),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 13,
                  color: AppTheme.accentCyan,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'JUDGE DEMO ACCESS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppTheme.accentCyan,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF475569),
                    width: 0.8,
                  ),
                ),
                child: const Text(
                  'SIH 2026',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Role tag
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.accentCyan.withValues(alpha: 0.5),
                    width: 0.9,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.rate_review_outlined,
                      size: 13,
                      color: AppTheme.accentCyan,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Judge Evaluator (Mission Officer)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          const Text(
            'Least-privilege operational mission command access for SIH evaluation.',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF94A3B8),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // Email credential row
          _buildCredentialRow(
            context: context,
            icon: Icons.alternate_email,
            label: 'Email',
            value: demoEmail,
            displayValue: demoEmail,
          ),
          const SizedBox(height: 8),

          // Password credential row
          _buildCredentialRow(
            context: context,
            icon: Icons.key_outlined,
            label: 'Password',
            value: demoPassword,
            displayValue: demoPassword,
          ),
          const SizedBox(height: 12),

          // "1-Click Fill Demo Credentials" Button
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              onPressed: () => onFillCredentials(
                demoEmail,
                demoPassword,
              ),
              icon: const Icon(Icons.flash_on, size: 16),
              label: const Text(
                '1-Click Fill Demo Credentials',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCyan.withValues(alpha: 0.2),
                foregroundColor: AppTheme.accentCyan,
                side: BorderSide(
                  color: AppTheme.accentCyan.withValues(alpha: 0.6),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required String displayValue,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF030A17).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF1E293B),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayValue,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          InkWell(
            onTap: () => _copyToClipboard(context, value, label),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  const Icon(
                    Icons.copy,
                    size: 13,
                    color: AppTheme.accentCyan,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Copy',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.accentCyan,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

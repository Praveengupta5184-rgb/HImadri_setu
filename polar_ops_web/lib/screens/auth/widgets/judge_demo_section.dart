import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../theme/app_theme.dart';

class JudgeDemoSection extends StatefulWidget {
  final void Function(String email, String password) onFillCredentials;

  static const String demoEmail = 'judge.demo@polarops.gov.in';
  static const String demoPassword = 'JudgeDemo@2026';
  static const bool enableDemoAccess = true;

  const JudgeDemoSection({
    super.key,
    required this.onFillCredentials,
  });

  @override
  State<JudgeDemoSection> createState() => _JudgeDemoSectionState();
}

class _JudgeDemoSectionState extends State<JudgeDemoSection> {
  int _selectedAccountIndex = 0; // 0 = Judge, 1 = Admin

  final List<Map<String, String>> _accounts = [
    {
      'role': 'Mission Officer (Evaluator)',
      'badge': 'JUDGE DEMO',
      'email': 'judge.demo@polarops.gov.in',
      'password': 'JudgeDemo@2026',
      'description':
          'Least-privilege operational mission command access for SIH evaluation.',
    },
    {
      'role': 'System Administrator',
      'badge': 'ADMIN ROOT',
      'email': 'admin@polarops.gov.in',
      'password': 'password',
      'description':
          'Full administrative system privileges (user approvals, system telemetry).',
    },
  ];

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

    final currentAccount = _accounts[_selectedAccountIndex];

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
                'DEMO LOGIN CREDENTIALS',
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
          const SizedBox(height: 12),

          // Role Switcher Chips
          Row(
            children: [
              _buildRoleChip(0, 'Judge Evaluator', Icons.rate_review_outlined),
              const SizedBox(width: 8),
              _buildRoleChip(1, 'Administrator', Icons.admin_panel_settings_outlined),
            ],
          ),
          const SizedBox(height: 10),

          Text(
            currentAccount['description']!,
            style: const TextStyle(
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
            value: currentAccount['email']!,
            displayValue: currentAccount['email']!,
          ),
          const SizedBox(height: 8),

          // Password credential row
          _buildCredentialRow(
            context: context,
            icon: Icons.key_outlined,
            label: 'Password',
            value: currentAccount['password']!,
            displayValue: currentAccount['password']!,
          ),
          const SizedBox(height: 12),

          // "1-Click Fill Demo Credentials" Button
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              onPressed: () => widget.onFillCredentials(
                currentAccount['email']!,
                currentAccount['password']!,
              ),
              icon: const Icon(Icons.flash_on, size: 16),
              label: Text(
                '1-Click Fill (${currentAccount['badge']})',
                style: const TextStyle(
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

  Widget _buildRoleChip(int index, String title, IconData icon) {
    final isSelected = _selectedAccountIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedAccountIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.accentCyan.withValues(alpha: 0.18)
                : const Color(0xFF071224).withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected
                  ? AppTheme.accentCyan
                  : const Color(0xFF334155),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected ? AppTheme.accentCyan : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
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

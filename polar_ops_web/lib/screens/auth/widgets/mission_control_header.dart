import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class MissionControlHeader extends StatelessWidget {
  final bool compact;
  const MissionControlHeader({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // SIH 2026 + MoES / NCPOR Pill Badges
        Wrap(
          spacing: 8,
          runSpacing: 6,
          alignment: compact ? WrapAlignment.center : WrapAlignment.start,
          children: [
            _buildBadge(
              icon: Icons.verified_outlined,
              label: 'SIH 2026 • Problem ID: 26062',
              borderColor: AppTheme.accentCyan.withValues(alpha: 0.5),
              textColor: AppTheme.accentCyan,
              bgColor: AppTheme.accentCyan.withValues(alpha: 0.12),
            ),
            _buildBadge(
              icon: Icons.account_balance_outlined,
              label: 'MoES • NCPOR',
              borderColor: const Color(0xFF3B82F6).withValues(alpha: 0.4),
              textColor: const Color(0xFF93C5FD),
              bgColor: const Color(0xFF1E3A8A).withValues(alpha: 0.3),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Brand Emblem and Title Row
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment:
              compact ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            _buildMissionEmblem(),
            const SizedBox(width: 14),
            Flexible(
              child: Column(
                crossAxisAlignment: compact
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'POLAR',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3.0,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: '-OPS',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3.0,
                            color: AppTheme.accentCyan,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Integrated Polar Expedition Logistics & Asset Management',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 0.6,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMissionEmblem() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppTheme.secondaryNavy,
            const Color(0xFF0D254C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppTheme.accentCyan.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentCyan.withValues(alpha: 0.25),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle rotating ring illusion
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
                width: 1,
              ),
            ),
          ),
          const Icon(
            Icons.explore,
            size: 24,
            color: AppTheme.accentCyan,
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color borderColor,
    required Color textColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

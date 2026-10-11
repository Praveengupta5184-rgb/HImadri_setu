import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'mission_control_header.dart';

class MissionInfoPanel extends StatelessWidget {
  const MissionInfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Branding Emblem & Header
          const MissionControlHeader(),
          const SizedBox(height: 36),

          // Main Headline
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Colors.white,
                Color(0xFFE2E8F0),
                Color(0xFFBAE6FD),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Text(
              'Command Every Expedition.',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.15,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Supporting Text
          const Text(
            'One unified platform for polar expedition logistics, personnel, cargo, assets, and emergency response across extreme environments.',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF94A3B8),
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 32),

          // Three Feature Highlights
          _buildFeatureTile(
            icon: Icons.qr_code_scanner,
            iconColor: AppTheme.accentCyan,
            title: 'Intelligent Cargo Tracking',
            description:
                'End-to-end QR/AR automated telemetry with environmental hazard & damage alerts.',
          ),
          const SizedBox(height: 16),
          _buildFeatureTile(
            icon: Icons.badge_outlined,
            iconColor: const Color(0xFF60A5FA),
            title: 'Expedition Personnel & Asset Management',
            description:
                'Real-time deployment roster, cold-chain monitoring, and inventory health tracking.',
          ),
          const SizedBox(height: 16),
          _buildFeatureTile(
            icon: Icons.shield_outlined,
            iconColor: const Color(0xFFF59E0B),
            title: 'Emergency Response Coordination',
            description:
                'Instant voice/SOS beacon handling, geospatial distress mapping, and digital twin triage.',
          ),
          const SizedBox(height: 36),

          // Subtle Antarctic Station Grid Status (Realistic & Grounded)
          _buildStationStatusGrid(),
        ],
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E36).withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationStatusGrid() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF071224).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppTheme.accentCyan.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.statusHealthy,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'POLAR OUTPOST NETWORK • OPERATIONAL',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: AppTheme.accentCyan,
                ),
              ),
              const Spacer(),
              const Text(
                'SECURE RELAY',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStationPill('BHARATI', '69°24\'S', true),
              const SizedBox(width: 8),
              _buildStationPill('MAITRI', '70°45\'S', true),
              const SizedBox(width: 8),
              _buildStationPill('HIMADRI', '78°55\'N', true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStationPill(String name, String coord, bool isOnline) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: const Color(0xFF334155),
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.statusHealthy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              coord,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF64748B),
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

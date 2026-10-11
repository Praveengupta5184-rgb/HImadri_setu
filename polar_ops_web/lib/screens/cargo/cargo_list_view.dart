import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/components/status_badge.dart';
import 'cargo_scanner_screen.dart';

class CargoListView extends StatelessWidget {
  final List<dynamic> cargoList;
  final bool isLoading;
  final VoidCallback onRefresh;
  final Function(int) onViewRisk;
  final Function(int) onViewDetails;

  const CargoListView({
    Key? key,
    required this.cargoList,
    required this.isLoading,
    required this.onRefresh,
    required this.onViewRisk,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondaryNavy,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cargo Registry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_scanner, size: 18),
                    label: const Text('SCAN QR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentCyan,
                      foregroundColor: AppTheme.primaryNavy,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onPressed: () async {
                      final scannedId = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CargoScannerScreen()),
                      );
                      if (scannedId != null) {
                        onRefresh();
                        onViewDetails(scannedId);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppTheme.accentCyan),
                    onPressed: onRefresh,
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (cargoList.isEmpty)
            const Center(child: Text('No cargo found', style: TextStyle(color: Colors.white54)))
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cargoList.length,
              separatorBuilder: (context, index) =>
                  const Divider(color: Colors.white10),
              itemBuilder: (context, index) {
                final cargo = cargoList[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${cargo['cargoId'] ?? 'N/A'} - ${cargo['name'] ?? cargo['category'] ?? 'UNKNOWN'}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Dest: ${cargo['destination'] ?? 'N/A'} | Weight: ${cargo['weight'] ?? 0} kg | Risk: ${cargo['riskScore'] ?? 0}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StatusBadge(
                        label: cargo['currentStatus'] ?? 'UNKNOWN',
                        color: AppTheme.accentCyan,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.local_shipping,
                            color: AppTheme.accentCyan),
                        tooltip: 'View Details & Track',
                        onPressed: () => onViewDetails(cargo['id']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.analytics,
                            color: AppTheme.statusWarning),
                        tooltip: 'View Risk Analysis',
                        onPressed: () => onViewRisk(cargo['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

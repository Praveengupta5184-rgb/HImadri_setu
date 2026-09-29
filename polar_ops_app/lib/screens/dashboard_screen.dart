import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'cargo_scanner_screen.dart';
import 'cargo/cargo_list_screen.dart';
import 'inventory/inventory_list_screen.dart';
import 'emergency/sos_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('POLAR-OPS Dashboard'),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: appState.isOffline ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: appState.isOffline ? Colors.orange : Colors.green)
            ),
            child: Row(
              children: [
                Icon(appState.isOffline ? Icons.cloud_off : Icons.cloud_done, size: 16, color: appState.isOffline ? Colors.orange : Colors.green),
                const SizedBox(width: 4),
                Text(appState.isOffline ? 'Offline' : 'Online', style: TextStyle(color: appState.isOffline ? Colors.orange : Colors.green, fontSize: 12))
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => context.read<AppState>().toggleOfflineMode(),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async { await Future.delayed(const Duration(seconds: 1)); },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSummaryCards(context),
            const SizedBox(height: 24),
            const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildMenuCard(context, 'Cargo List', Icons.list_alt, CargoListScreen()),
                _buildMenuCard(context, 'Smart Scanner', Icons.qr_code_scanner, const CargoScannerScreen()),
                _buildMenuCard(context, 'Inventory', Icons.inventory, InventoryListScreen()),
                _buildMenuCard(context, 'Emergency SOS', Icons.warning, SosScreen(), color: Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _statCard('In Transit', '15', Colors.blue)),
        const SizedBox(width: 8),
        Expanded(child: _statCard('Low Stock', '12', Colors.orange)),
        const SizedBox(width: 8),
        Expanded(child: _statCard('Emergencies', '1', Colors.red)),
      ],
    );
  }

  Widget _statCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5))
      ),
      child: Column(
        children: [
          Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Widget? targetScreen, {Color? color}) {
    color ??= Theme.of(context).colorScheme.primary;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: targetScreen != null 
            ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => targetScreen))
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

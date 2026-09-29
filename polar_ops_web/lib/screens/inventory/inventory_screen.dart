import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/components/status_badge.dart';
import '../../services/api/api_client.dart';
import '../../services/auth/auth_service.dart';
import '../../widgets/components/state_widgets.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<dynamic> _inventory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInventory();
  }

  Future<void> _fetchInventory() async {
    setState(() => _isLoading = true);
    final response = await ApiClient.get('/inventory');
    if (!mounted) return;
    setState(() {
      _inventory = response.success && response.data != null
          ? response.data as List<dynamic>
          : [];
      _isLoading = false;
    });
  }

  Future<void> _showItemForm() async {
    final name = TextEditingController();
    final category = TextEditingController();
    final quantity = TextEditingController();
    final minimum = TextEditingController();
    final unit = TextEditingController();
    final station = TextEditingController();
    final rate = TextEditingController();
    final saved = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Add Inventory Item'),
                content: SizedBox(
                    width: 440,
                    child: SingleChildScrollView(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                      TextField(
                          controller: name,
                          decoration:
                              const InputDecoration(labelText: 'Item name *')),
                      TextField(
                          controller: category,
                          decoration:
                              const InputDecoration(labelText: 'Category')),
                      TextField(
                          controller: quantity,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Current quantity *')),
                      TextField(
                          controller: minimum,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Minimum stock *')),
                      TextField(
                          controller: unit,
                          decoration: const InputDecoration(labelText: 'Unit')),
                      TextField(
                          controller: station,
                          decoration:
                              const InputDecoration(labelText: 'Station')),
                      TextField(
                          controller: rate,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Daily consumption rate')),
                    ]))),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('CANCEL')),
                  ElevatedButton(
                      onPressed: () async {
                        final q = int.tryParse(quantity.text);
                        final min = int.tryParse(minimum.text);
                        if (name.text.trim().isEmpty ||
                            q == null ||
                            min == null) return;
                        final response = await ApiClient.post('/inventory', {
                          'name': name.text.trim(),
                          'category': category.text.trim(),
                          'quantityAvailable': q,
                          'minimumStockLevel': min,
                          'unit': unit.text.trim(),
                          'station': station.text.trim(),
                          'dailyConsumptionRate': double.tryParse(rate.text)
                        });
                        if (context.mounted)
                          Navigator.pop(context, response.success);
                      },
                      child: const Text('SAVE ITEM'))
                ]));
    if (saved == true) _fetchInventory();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'NORMAL':
        return AppTheme.statusHealthy;
      case 'LOW':
        return AppTheme.statusWarning;
      case 'CRITICAL':
        return AppTheme.statusCritical;
      case 'OUT_OF_STOCK':
        return Colors.grey;
      default:
        return AppTheme.statusNeutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return StateWidgets.loadingState(message: 'Loading inventory records…');
    }

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Inventory Management',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textMain)),
              Row(children: [
                if (AuthService.hasRole(
                    ['ADMIN', 'LOGISTICS_OFFICER', 'STATION_OFFICER']))
                  ElevatedButton.icon(
                      onPressed: _showItemForm,
                      icon: const Icon(Icons.add),
                      label: const Text('ADD ITEM')),
                const SizedBox(width: AppTheme.spacingSm),
                ElevatedButton.icon(
                  onPressed: _fetchInventory,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryNavy,
                    foregroundColor: AppTheme.accentCyan,
                  ),
                )
              ]),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Expanded(
              child: _inventory.isEmpty
                  ? StateWidgets.emptyState(
                      message:
                          'No inventory records in the operational database.')
                  : Card(
                      color: AppTheme.secondaryNavy,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            columns: const [
                              DataColumn(
                                  label: Text('Item',
                                      style: TextStyle(
                                          color: AppTheme.textMuted))),
                              DataColumn(
                                  label: Text('Category',
                                      style: TextStyle(
                                          color: AppTheme.textMuted))),
                              DataColumn(
                                  label: Text('Station',
                                      style: TextStyle(
                                          color: AppTheme.textMuted))),
                              DataColumn(
                                  label: Text('Quantity',
                                      style: TextStyle(
                                          color: AppTheme.textMuted))),
                              DataColumn(
                                  label: Text('Min Level',
                                      style: TextStyle(
                                          color: AppTheme.textMuted))),
                              DataColumn(
                                  label: Text('Status',
                                      style: TextStyle(
                                          color: AppTheme.textMuted))),
                              DataColumn(
                                  label: Text('Estimated Depletion',
                                      style: TextStyle(
                                          color: AppTheme.textMuted))),
                            ],
                            rows: _inventory.map((item) {
                              final status = item['derivedStatus'] ?? 'NORMAL';
                              final depletion = item['estimatedDepletionDate'];
                              return DataRow(
                                cells: [
                                  DataCell(Text(item['name'] ?? '-',
                                      style: const TextStyle(
                                          color: AppTheme.textMain))),
                                  DataCell(Text(item['category'] ?? '-',
                                      style: const TextStyle(
                                          color: Colors.white70))),
                                  DataCell(Text(item['station'] ?? '-',
                                      style: const TextStyle(
                                          color: Colors.white70))),
                                  DataCell(Text(
                                      '${item['quantityAvailable'] ?? 0} ${item['unit'] ?? ''}',
                                      style: const TextStyle(
                                          color: AppTheme.textMain,
                                          fontWeight: FontWeight.bold))),
                                  DataCell(Text(
                                      '${item['minimumStockLevel'] ?? 0}',
                                      style: const TextStyle(
                                          color: Colors.white70))),
                                  DataCell(StatusBadge(
                                      label: status,
                                      color: _getStatusColor(status))),
                                  DataCell(Text(
                                      depletion ?? 'Insufficient Data',
                                      style: TextStyle(
                                          color: depletion != null
                                              ? AppTheme.accentCyan
                                              : AppTheme.textMuted))),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    )),
        ],
      ),
    );
  }
}

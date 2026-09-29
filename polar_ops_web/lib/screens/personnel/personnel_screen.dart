import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/components/status_badge.dart';
import '../../services/api/api_client.dart';
import '../../services/auth/auth_service.dart';
import '../../widgets/components/state_widgets.dart';

class PersonnelScreen extends StatefulWidget {
  const PersonnelScreen({super.key});

  @override
  State<PersonnelScreen> createState() => _PersonnelScreenState();
}

class _PersonnelScreenState extends State<PersonnelScreen> {
  List<dynamic> _personnel = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPersonnel();
  }

  Future<void> _fetchPersonnel() async {
    setState(() => _isLoading = true);
    final response = await ApiClient.get('/personnel');
    if (!mounted) return;
    setState(() {
      _personnel = response.success && response.data != null
          ? response.data as List<dynamic>
          : [];
      _isLoading = false;
    });
  }

  Future<void> _showPersonnelForm() async {
    final name = TextEditingController();
    final role = TextEditingController();
    final organization = TextEditingController();
    final station = TextEditingController();
    final destination = TextEditingController();
    String movement = 'AT_BASE';
    final saved = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
                  title: const Text('Add Personnel'),
                  content: SizedBox(
                      width: 480,
                      child: SingleChildScrollView(
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                        TextField(
                            controller: name,
                            decoration: const InputDecoration(
                                labelText: 'Full name *')),
                        TextField(
                            controller: role,
                            decoration: const InputDecoration(
                                labelText: 'Operational role *')),
                        TextField(
                            controller: organization,
                            decoration: const InputDecoration(
                                labelText: 'Organization')),
                        TextField(
                            controller: station,
                            decoration: const InputDecoration(
                                labelText: 'Current station / base')),
                        TextField(
                            controller: destination,
                            decoration: const InputDecoration(
                                labelText: 'Destination station')),
                        DropdownButtonFormField<String>(
                            initialValue: movement,
                            decoration: const InputDecoration(
                                labelText: 'Movement status'),
                            items: const [
                              'AT_BASE',
                              'MOBILIZING',
                              'IN_TRANSIT',
                              'AT_STATION',
                              'RETURNING'
                            ]
                                .map((v) =>
                                    DropdownMenuItem(value: v, child: Text(v)))
                                .toList(),
                            onChanged: (v) =>
                                setDialogState(() => movement = v!)),
                      ]))),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('CANCEL')),
                    ElevatedButton(
                        onPressed: () async {
                          if (name.text.trim().isEmpty ||
                              role.text.trim().isEmpty) return;
                          final response = await ApiClient.post('/personnel', {
                            'name': name.text.trim(),
                            'role': role.text.trim(),
                            'organization': organization.text.trim(),
                            'currentLocation': station.text.trim(),
                            'destination': destination.text.trim(),
                            'movementStatus': movement,
                            'medicalClearanceStatus': 'PENDING'
                          });
                          if (context.mounted)
                            Navigator.pop(context, response.success);
                        },
                        child: const Text('SAVE PERSONNEL'))
                  ],
                )));
    if (saved == true) _fetchPersonnel();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'AT_STATION':
        return AppTheme.statusHealthy;
      case 'IN_TRANSIT':
        return AppTheme.statusWarning;
      case 'MOBILIZING':
        return AppTheme.statusNeutral;
      case 'RETURNING':
        return Colors.purpleAccent;
      case 'AT_BASE':
        return AppTheme.textMuted;
      default:
        return AppTheme.statusNeutral;
    }
  }

  Future<void> _showKit(Map<String, dynamic> person) async {
    final response =
        await ApiClient.get<List<dynamic>>('/personnel/${person['id']}/kit');
    if (!mounted) return;
    final items = response.data ?? <dynamic>[];
    showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('${person['name']} — Personal Kit'),
              content: SizedBox(
                  width: 460,
                  child: items.isEmpty
                      ? const Text(
                          'No issued items are recorded for this person.')
                      : ListView(
                          shrinkWrap: true,
                          children: items
                              .map((item) => ListTile(
                                    leading:
                                        const Icon(Icons.backpack_outlined),
                                    title: Text(
                                        '${item['itemName']} × ${item['quantity']} ${item['unit'] ?? ''}'),
                                    subtitle: Text(
                                        'Issued ${item['issueDate'] ?? '-'} • ${item['returnStatus'] ?? 'ISSUED'}'),
                                  ))
                              .toList())),
              actions: [
                if (AuthService.hasRole(['ADMIN', 'LOGISTICS_OFFICER']))
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _issueKit(person);
                      },
                      child: const Text('ISSUE ITEM')),
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CLOSE')),
              ],
            ));
  }

  Future<void> _issueKit(Map<String, dynamic> person) async {
    final response = await ApiClient.get<List<dynamic>>('/inventory');
    if (!mounted || !response.success) return;
    final inventory = response.data!
        .where((item) => (item['quantityAvailable'] ?? 0) > 0)
        .toList();
    int? itemId;
    final quantity = TextEditingController(text: '1');
    final issued = await showDialog<bool>(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, update) => AlertDialog(
                  title: const Text('Issue Personal Kit Item'),
                  content: SizedBox(
                      width: 420,
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                                labelText: 'Operational inventory item'),
                            items: inventory
                                .map<
                                    DropdownMenuItem<
                                        int>>((item) => DropdownMenuItem(
                                    value: item['itemId'] as int,
                                    child: Text(
                                        '${item['name']} — ${item['quantityAvailable']} ${item['unit'] ?? ''}')))
                                .toList(),
                            onChanged: (value) => update(() => itemId = value)),
                        TextField(
                            controller: quantity,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Quantity')),
                      ])),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('CANCEL')),
                    ElevatedButton(
                        onPressed: itemId == null
                            ? null
                            : () async {
                                final result = await ApiClient.post(
                                    '/personnel/${person['id']}/kit', {
                                  'inventoryItemId': itemId,
                                  'quantity': int.tryParse(quantity.text) ?? 0
                                });
                                if (context.mounted)
                                  Navigator.pop(context, result.success);
                              },
                        child: const Text('ISSUE'))
                  ],
                )));
    if (issued == true) _showKit(person);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return StateWidgets.loadingState(message: 'Loading personnel records…');
    }

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Personnel Management',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textMain)),
              Row(children: [
                if (AuthService.hasRole(
                    ['ADMIN', 'MISSION_OFFICER', 'STATION_OFFICER']))
                  ElevatedButton.icon(
                      onPressed: _showPersonnelForm,
                      icon: const Icon(Icons.person_add),
                      label: const Text('ADD PERSONNEL')),
                const SizedBox(width: AppTheme.spacingSm),
                ElevatedButton.icon(
                  onPressed: _fetchPersonnel,
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
              child: _personnel.isEmpty
                  ? StateWidgets.emptyState(
                      message:
                          'No personnel records in the operational database.')
                  : Card(
                      color: AppTheme.secondaryNavy,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            columns: const [
                              DataColumn(
                                  label: Text('Name',
                                      style: TextStyle(
                                          color: AppTheme.textMuted))),
                              DataColumn(
                                  label: Text('Role',
                                      style: TextStyle(
                                          color: AppTheme.textMuted))),
                              DataColumn(
                                  label: Text('Organization',
                                      style: TextStyle(
                                          color: AppTheme.textMuted))),
                              DataColumn(
                                  label: Text('Current Location',
                                      style: TextStyle(
                                          color: AppTheme.textMuted))),
                              DataColumn(
                                  label: Text('Destination',
                                      style: TextStyle(
                                          color: AppTheme.textMuted))),
                              DataColumn(
                                  label: Text('Movement Status',
                                      style: TextStyle(
                                          color: AppTheme.textMuted))),
                              DataColumn(
                                  label: Text('Personal Kit',
                                      style: TextStyle(
                                          color: AppTheme.textMuted))),
                            ],
                            rows: _personnel.map((p) {
                              final status = p['movementStatus'] ?? 'UNKNOWN';
                              return DataRow(
                                cells: [
                                  DataCell(Text(p['name'] ?? '-',
                                      style: const TextStyle(
                                          color: AppTheme.textMain,
                                          fontWeight: FontWeight.bold))),
                                  DataCell(Text(p['role'] ?? '-',
                                      style: const TextStyle(
                                          color: Colors.white70))),
                                  DataCell(Text(p['organization'] ?? '-',
                                      style: const TextStyle(
                                          color: Colors.white70))),
                                  DataCell(Text(p['currentLocation'] ?? '-',
                                      style: const TextStyle(
                                          color: AppTheme.textMain))),
                                  DataCell(Text(p['destination'] ?? '-',
                                      style: const TextStyle(
                                          color: Colors.white70))),
                                  DataCell(StatusBadge(
                                      label: status,
                                      color: _getStatusColor(status))),
                                  DataCell(IconButton(
                                      tooltip: 'View issued personal kit',
                                      icon: const Icon(Icons.backpack_outlined),
                                      onPressed: () => _showKit(
                                          Map<String, dynamic>.from(p)))),
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

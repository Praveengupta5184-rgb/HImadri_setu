import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/components/section_header.dart';
import '../../services/api/api_client.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({Key? key}) : super(key: key);

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  String _selectedScenario = 'CARGO_DELAY';
  int _delayHours = 48;
  bool _isRunning = false;
  Map<String, dynamic>? _result;

  final List<String> _scenarios = [
    'CARGO_DELAY',
    'INVENTORY_SHORTAGE',
    'PERSONNEL_MOVEMENT_DISRUPTION',
    'WEATHER_DETERIORATION',
    'ASSET_FAILURE',
    'STATION_EMERGENCY'
  ];

  Future<void> _runSimulation() async {
    setState(() {
      _isRunning = true;
      _result = null;
    });

    try {
      final response = await ApiClient.post('/simulate', {
        'scenario': _selectedScenario,
        'delayHours': _delayHours,
      });

      if (response.success && response.data != null) {
        setState(() {
          _result = response.data as Map<String, dynamic>;
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Simulation failed.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simulation Mode Warning Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: AppTheme.statusWarning.withValues(alpha: 0.2),
              child: const Center(
                child: Text(
                  '⚠ SIMULATION MODE - NOT LIVE DATA ⚠',
                  style: TextStyle(
                    color: AppTheme.statusWarning,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'MISSION WHAT-IF SIMULATOR'),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 1, child: _buildControlPanel()),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: _buildResultsPanel()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
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
          const Text('1. SELECT SCENARIO',
              style: TextStyle(
                  color: AppTheme.accentCyan, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _selectedScenario,
            dropdownColor: AppTheme.secondaryNavy,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              filled: true,
              fillColor: AppTheme.primaryNavy,
              border: OutlineInputBorder(),
            ),
            items: _scenarios
                .map((s) => DropdownMenuItem(
                    value: s, child: Text(s.replaceAll('_', ' '))))
                .toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedScenario = val);
            },
          ),
          const SizedBox(height: 24),
          if (_selectedScenario == 'CARGO_DELAY') ...[
            const Text('2. PARAMETERS',
                style: TextStyle(
                    color: AppTheme.accentCyan, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Delay (Hours):',
                style: TextStyle(color: Colors.white70)),
            Slider(
              value: _delayHours.toDouble(),
              min: 12,
              max: 168,
              divisions: 13,
              label: '$_delayHours hours',
              activeColor: AppTheme.accentCyan,
              onChanged: (val) => setState(() => _delayHours = val.toInt()),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isRunning ? null : _runSimulation,
              icon: _isRunning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.play_arrow),
              label: Text(_isRunning ? 'CALCULATING...' : 'RUN SIMULATION'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCyan,
                foregroundColor: AppTheme.primaryNavy,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildResultsPanel() {
    if (_result == null && !_isRunning) {
      return Container(
        height: 400,
        decoration: BoxDecoration(
          color: AppTheme.secondaryNavy,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white10),
        ),
        child: const Center(
          child: Text('Run a simulation to view projected impact.',
              style: TextStyle(color: Colors.white54)),
        ),
      );
    }

    if (_isRunning) {
      return const SizedBox(
        height: 400,
        child: Center(
            child: CircularProgressIndicator(color: AppTheme.accentCyan)),
      );
    }

    final data = _result!;
    final base = data['baselineState'] as Map<String, dynamic>;
    final sim = data['simulatedState'] as Map<String, dynamic>;
    final affected = List<String>.from(data['affectedEntities'] ?? []);
    final actions = List<String>.from(data['possibleActions'] ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Transparency Section
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
              color: AppTheme.secondaryNavy,
              borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TRANSPARENCY REPORT',
                  style: TextStyle(
                      color: AppTheme.accentCyan,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5)),
              const Divider(color: Colors.white10, height: 24),
              _buildProp('Scenario', data['description']),
              _buildProp('Input', data['input']),
              _buildProp('Assumptions', data['assumptions']),
              _buildProp('Calculation Engine', data['calculationMethod']),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Before/After State
        Row(
          children: [
            Expanded(
                child: _buildStateCard('BASELINE STATE', base,
                    data['baselineRisk'], AppTheme.statusHealthy)),
            const SizedBox(width: 16),
            const Icon(Icons.arrow_forward, color: Colors.white54),
            const SizedBox(width: 16),
            Expanded(
                child: _buildStateCard('PROJECTED STATE', sim,
                    data['simulatedRisk'], AppTheme.statusCritical)),
          ],
        ),
        const SizedBox(height: 24),

        // Impact & Actions
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: AppTheme.secondaryNavy,
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('AFFECTED RESOURCES',
                        style: TextStyle(
                            color: AppTheme.statusWarning,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...affected.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text('• $e',
                            style: const TextStyle(color: Colors.white)))),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    color: AppTheme.secondaryNavy,
                    borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('RECOMMENDED ACTIONS',
                        style: TextStyle(
                            color: AppTheme.accentCyan,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...actions.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text('• $e',
                            style: const TextStyle(color: Colors.white)))),
                  ],
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildStateCard(
      String title, Map<String, dynamic> state, int risk, Color riskColor) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.secondaryNavy,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.white10, height: 24),
          ...state.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key, style: const TextStyle(color: Colors.white54)),
                    Text(e.value.toString(),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Risk Score', style: TextStyle(color: Colors.white54)),
              Text('$risk/100',
                  style: TextStyle(
                      color: riskColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildProp(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 140,
              child:
                  Text(label, style: const TextStyle(color: Colors.white54))),
          Expanded(
              child: Text(value, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}

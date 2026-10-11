import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../services/cargo_service.dart';
import '../../../services/auth/auth_service.dart';
import '../../../widgets/components/section_header.dart';

class CreateCargoView extends StatefulWidget {
  final VoidCallback onCargoCreated;

  const CreateCargoView({Key? key, required this.onCargoCreated}) : super(key: key);

  @override
  State<CreateCargoView> createState() => _CreateCargoViewState();
}

class _CreateCargoViewState extends State<CreateCargoView> {
  final _formKey = GlobalKey<FormState>();
  final _cargoIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final _weightController = TextEditingController();
  final _quantityController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priorityController = TextEditingController();

  bool _isHazardous = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _cargoIdController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _originController.dispose();
    _destinationController.dispose();
    _weightController.dispose();
    _quantityController.dispose();
    _categoryController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    final payload = {
      'cargoId': _cargoIdController.text,
      'name': _nameController.text,
      'description': _descController.text,
      'origin': _originController.text,
      'destination': _destinationController.text,
      'weight': double.tryParse(_weightController.text) ?? 0.0,
      'quantity': int.tryParse(_quantityController.text) ?? 1,
      'category': _categoryController.text,
      'priority': _priorityController.text.isNotEmpty ? _priorityController.text : 'NORMAL',
      'hazardousStatus': _isHazardous,
      'currentStatus': 'CREATED',
      'createdBy': AuthService.currentUserRole ?? 'UNKNOWN'
    };

    try {
      final response = await CargoService.createCargo(payload);
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cargo created successfully')));
        _formKey.currentState!.reset();
        setState(() {
          _isHazardous = false;
        });
        widget.onCargoCreated();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${response.error}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthService.hasRole(['LOGISTICS_OFFICER', 'ADMIN'])) {
      return const Center(child: Text('Access Denied. Required Role: LOGISTICS_OFFICER', style: TextStyle(color: AppTheme.statusCritical)));
    }

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'CREATE NEW CARGO'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField(_cargoIdController, 'Cargo ID (e.g. PKG-1001)', required: true)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(_nameController, 'Cargo Name', required: true)),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(_descController, 'Description', maxLines: 3),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField(_originController, 'Origin')),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(_destinationController, 'Destination', required: true)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField(_weightController, 'Weight (kg)', isNumber: true, required: true)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(_quantityController, 'Quantity', isNumber: true, required: true)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildTextField(_categoryController, 'Category (e.g. FOOD, EQUIPMENT, MEDICAL)')),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(_priorityController, 'Priority (LOW, NORMAL, HIGH, CRITICAL)')),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Hazardous Material', style: TextStyle(color: Colors.white)),
              value: _isHazardous,
              activeColor: AppTheme.statusCritical,
              onChanged: (val) => setState(() => _isHazardous = val),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCyan,
                foregroundColor: AppTheme.primaryNavy,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: _isSubmitting ? const CircularProgressIndicator() : const Text('CREATE CARGO ENTRY'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false, bool required = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accentCyan.withValues(alpha: 0.3))),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accentCyan)),
        errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppTheme.statusCritical)),
      ),
      validator: required ? (value) {
        if (value == null || value.isEmpty) return 'Required field';
        return null;
      } : null,
    );
  }
}

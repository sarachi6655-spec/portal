import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/sample_controller.dart';

class AddSampleDialog extends StatefulWidget {
  final SampleController controller;

  const AddSampleDialog({super.key, required this.controller});

  @override
  State<AddSampleDialog> createState() => _AddSampleDialogState();
}

class _AddSampleDialogState extends State<AddSampleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _sampleNameController = TextEditingController();
  final _sampleItemController = TextEditingController();
  final _referenceNoController = TextEditingController();
  final _itemTypeController = TextEditingController();
  final _sampleTypeController = TextEditingController(text: 'Water');
  final _subTypeController = TextEditingController();

  String _selectedCategory = 'Sample Point';
  String _selectedStatus = 'Pending';
  bool _isSubmitting = false;

  final List<String> _categories = ['Sample Point', 'Item', 'Equipment', 'Chemicals', 'Environmental'];
  late final List<String> _statuses;

  @override
  void initState() {
    super.initState();
    final dynamicStatuses = widget.controller.availableStatusFilters
        .where((s) => s.toLowerCase() != 'all')
        .toList();
    _statuses = dynamicStatuses.isNotEmpty
        ? dynamicStatuses
        : ['Pending', 'In Progress', 'Completed', 'Hold'];
    if (!_statuses.contains(_selectedStatus) && _statuses.isNotEmpty) {
      _selectedStatus = _statuses.first;
    }
  }

  @override
  void dispose() {
    _sampleNameController.dispose();
    _sampleItemController.dispose();
    _referenceNoController.dispose();
    _itemTypeController.dispose();
    _sampleTypeController.dispose();
    _subTypeController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final payload = {
      "ERPID": "0",
      "ERPSource": "Rest API",
      "SampleCategory": _selectedCategory,
      "SampleItem": _sampleItemController.text.trim().isEmpty ? _sampleNameController.text.trim() : _sampleItemController.text.trim(),
      "SampleName": _sampleNameController.text.trim(),
      "SampleStatus": _selectedStatus,
      "TestLimits": "Standard Parameter Test",
      "SpecType": "Others",
      "Instrument": "Standard Equipment",
      "ItemType": _itemTypeController.text.trim(),
      "Item": _sampleItemController.text.trim(),
      "CompanyType": "Customer",
      "Company": "Al Jawhara Centre",
      "Equipment": "General",
      "EquipmentType": "Testing",
      "EquipmentSubType": "General",
      "SampleType": _sampleTypeController.text.trim(),
      "SampleSubType": _subTypeController.text.trim(),
      "ReferenceNo": _referenceNoController.text.trim(),
    };

    final success = await widget.controller.createSample(payload);

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sample registered successfully'),
            backgroundColor: AppColors.statusSuccessText,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.controller.errorMessage ?? 'Failed to register sample'),
            backgroundColor: AppColors.statusFailedText,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 20,
      backgroundColor: Colors.white,
      child: Container(
        width: 580,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderLight)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF0FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: const Icon(Icons.add_circle_outline, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Add New Sample',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkSlateTitle,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Modal Body Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category dropdown
                      _buildLabel('Sample Category *'),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        items: _categories.map((cat) {
                          return DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13)));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                        decoration: const InputDecoration(),
                      ),
                      const SizedBox(height: 16),

                      // Sample Name
                      _buildLabel('Sample Name *'),
                      TextFormField(
                        controller: _sampleNameController,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(hintText: 'Enter sample name'),
                        validator: (val) => val == null || val.trim().isEmpty ? 'Please enter sample name' : null,
                      ),
                      const SizedBox(height: 16),

                      // Sample Type & SubType
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Sample Type'),
                                TextFormField(
                                  controller: _sampleTypeController,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: const InputDecoration(hintText: 'e.g. Water, Oil, Food'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Sample Sub Type'),
                                TextFormField(
                                  controller: _subTypeController,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: const InputDecoration(hintText: 'e.g. Drinking Water'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Status & Reference No
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Sample Status'),
                                DropdownButtonFormField<String>(
                                  value: _selectedStatus,
                                  items: _statuses.map((st) {
                                    return DropdownMenuItem(value: st, child: Text(st, style: const TextStyle(fontSize: 13)));
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedStatus = val);
                                  },
                                  decoration: const InputDecoration(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Reference No'),
                                TextFormField(
                                  controller: _referenceNoController,
                                  style: const TextStyle(fontSize: 13),
                                  decoration: const InputDecoration(hintText: 'REF-2026-001'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Modal Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderLight)),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Save Sample', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.darkSlateTitle,
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gear_mate/services/gear_api.dart';
import 'package:gear_mate/services/firefighter_api.dart';
import 'package:gear_mate/services/inspection_api.dart';

class InspectionLogPage extends StatefulWidget {
  static const route = '/inspection';
  const InspectionLogPage({super.key});

  @override
  State<InspectionLogPage> createState() => _InspectionLogPageState();
}

class _InspectionLogPageState extends State<InspectionLogPage> {
  final _form = GlobalKey<FormState>();
  final _dateCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  int? _selectedGearId;
  String? _selectedGearName;
  int? _selectedInspectorId;
  String? _selectedInspectorName;
  String? _inspectionType;

  List<Map<String, dynamic>> _gears = [];
  bool _isLoadingGears = true;
  List<Map<String, dynamic>> _inspectors = [];
  bool _isLoadingInspectors = true;
  final _types = const [
    'Routine',
    'Post-Repair',
    'Safety Recall',
    'Deep Clean',
  ];

  @override
  void initState() {
    super.initState();
    _loadGears();
    _loadInspectors();
  }

  Future<void> _loadGears() async {
    try {
      final gears = await GearApi.fetchGears('Name');
      setState(() {
        _gears = gears;
        _isLoadingGears = false;
      });
    } catch (e) {
      setState(() => _isLoadingGears = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load gears: $e')),
        );
      }
    }
  }

  Future<void> _loadInspectors() async {
    try {
      final people = await FirefighterApi.fetchFirefighters();
      setState(() {
        _inspectors = people;
        _isLoadingInspectors = false;
      });
    } catch (e) {
      setState(() => _isLoadingInspectors = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load inspectors: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      ctrl.text =
          "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  void _clear() {
    _form.currentState?.reset();
    _dateCtrl.clear();
    _notesCtrl.clear();
    setState(() {
      _selectedGearId = null;
      _selectedGearName = null;
      _selectedInspectorId = null;
      _selectedInspectorName = null;
      _inspectionType = null;
    });
  }

  void _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Validate required fields
      if (_selectedGearId == null) {
        throw Exception('Please select a gear');
      }
      if (_selectedInspectorId == null) {
        throw Exception('Please select an inspector');
      }

      // Create inspection
      await InspectionApi.createInspection(
        gearId: _selectedGearId!,
        inspectionDate: _dateCtrl.text,
        inspectorId: _selectedInspectorId,
        inspectionType: _inspectionType,
        conditionNotes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
        result: 'Pending', // Default result
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inspection submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Pop back to history page and signal refresh
        Navigator.pop(context, true);
      }
      // No need to clear after successful submit; page will close.
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Repair & Inspection Log'),
      ),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _Label('Gear'),
              _isLoadingGears
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : DropdownButtonFormField<String>(
                      value: _selectedGearName,
                      isExpanded: true,
                      items: _gears
                          .map((gear) => DropdownMenuItem(
                                value: gear['gear_name'] as String,
                                child: Text(
                                  'ID ${gear['id']} - ${gear['gear_name']}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedGearName = v;
                          if (v != null) {
                            _selectedGearId = _gears.firstWhere(
                              (g) => g['gear_name'] == v,
                            )['id'] as int;
                          } else {
                            _selectedGearId = null;
                          }
                        });
                      },
                      decoration: const InputDecoration(hintText: 'Select gear'),
                      validator: (v) => v == null ? 'Please select a gear' : null,
                    ),
              const SizedBox(height: 16),
              const _Label('Inspection Date'),
              TextFormField(
                controller: _dateCtrl,
                readOnly: true,
                onTap: () => _pickDate(_dateCtrl),
                decoration: const InputDecoration(
                  hintText: 'Select inspection date',
                  suffixIcon: Icon(Icons.calendar_today_rounded),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Please choose a date' : null,
              ),
              const SizedBox(height: 16),
              const _Label('Inspector'),
              _isLoadingInspectors
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : DropdownButtonFormField<String>(
                      value: _selectedInspectorName,
                      isExpanded: true,
                      items: _inspectors
                          .map((p) => DropdownMenuItem(
                                value: p['name'] as String,
                                child: Text(
                                  'ID ${p['id']} - ${p['name']}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ))
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedInspectorName = v;
                          if (v != null) {
                            _selectedInspectorId = _inspectors.firstWhere(
                              (p) => p['name'] == v,
                            )['id'] as int;
                          } else {
                            _selectedInspectorId = null;
                          }
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Select inspector',
                      ),
                      validator: (v) => v == null ? 'Please select inspector' : null,
                    ),
              const SizedBox(height: 16),
              const _Label('Inspection Type'),
              DropdownButtonFormField<String>(
                value: _inspectionType,
                items: _types
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _inspectionType = v),
                decoration: const InputDecoration(
                  hintText: 'Select inspection type',
                ),
                validator: (v) => v == null ? 'Please select type' : null,
              ),
              const SizedBox(height: 16),
              const _Label('Notes'),
              TextFormField(
                controller: _notesCtrl,
                minLines: 4,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Explain the conditions...',
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).scaffoldBackgroundColor,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        side: const BorderSide(color: Colors.black26),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: _clear,
                      child: const Text('Clear All'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).scaffoldBackgroundColor,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        side: const BorderSide(color: Colors.black26),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: _submit,
                      child: const Text('Submit Inspection'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
  );
}

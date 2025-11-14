import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gear_mate/services/damage_report_api.dart';
import 'package:gear_mate/services/gear_api.dart';

class DamageReportPage extends StatefulWidget {
  static const route = '/damage';
  const DamageReportPage({super.key});

  @override
  State<DamageReportPage> createState() => _DamageReportPageState();
}

class _DamageReportPageState extends State<DamageReportPage> {
  final _form = GlobalKey<FormState>();
  final _reportDateCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String? _selectedGearName;
  int? _selectedGearId;
  String? _reporterId;
  File? _photo;

  List<Map<String, dynamic>> _gears = [];
  bool _isLoadingGears = true;

  final _reporters = const [
    'Mark Johnson',
    'Ton Danai',
    'Minnie Aleenta',
    'Sang Nuntaphop',
    'P Pongpon',
    'Pon Phonlaphat',
  ];

  @override
  void initState() {
    super.initState();
    _loadGears();
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

  @override
  void dispose() {
    _reportDateCtrl.dispose();
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

  Future<void> _choose(ImageSource src) async {
    final x = await ImagePicker().pickImage(source: src, imageQuality: 80);
    if (x != null) setState(() => _photo = File(x.path));
  }

  void _clear() {
    _form.currentState?.reset();
    _reportDateCtrl.clear();
    _notesCtrl.clear();
    setState(() {
      _selectedGearId = null;
      _selectedGearName = null;
      _reporterId = null;
      _photo = null;
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

      // Use the selected gear ID from the dropdown
      if (_selectedGearId == null) {
        throw Exception('Please select a gear');
      }

      // Create damage report with reporter name
      await DamageReportApi.createDamageReport(
        gearId: _selectedGearId!,
        reportDate: _reportDateCtrl.text,
        reporterName: _reporterId, // Now sending the name directly
        notes: _notesCtrl.text.isNotEmpty ? _notesCtrl.text : null,
        photoUrl: _photo != null ? _photo!.path : null,
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Damage report submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      _clear();
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
      appBar: AppBar(title: const Text('Quick Damage Report')),
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
                      items: _gears
                          .map((gear) => DropdownMenuItem(
                                value: gear['gear_name'] as String,
                                child: Text('${gear['gear_name']} (${gear['equipment_type'] ?? ''})'),
                              ))
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedGearName = v;
                          _selectedGearId = _gears.firstWhere(
                            (gear) => gear['gear_name'] == v,
                          )['id'] as int;
                        });
                      },
                      decoration: const InputDecoration(hintText: 'Select gear'),
                      validator: (v) => v == null ? 'Please select a gear' : null,
                    ),
              const SizedBox(height: 16),
              const _Label('Report Date'),
              TextFormField(
                controller: _reportDateCtrl,
                readOnly: true,
                onTap: () => _pickDate(_reportDateCtrl),
                decoration: const InputDecoration(
                  hintText: 'Select report date',
                  suffixIcon: Icon(Icons.calendar_today_rounded),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Please choose a date' : null,
              ),
              const SizedBox(height: 16),
              const _Label('Reporter Name'),
              DropdownButtonFormField<String>(
                value: _reporterId,
                items: _reporters
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _reporterId = v),
                decoration: const InputDecoration(
                  hintText: 'Select reporter name',
                ),
                validator: (v) => v == null ? 'Please select reporter' : null,
              ),
              const SizedBox(height: 16),
              const _Label('Notes'),
              TextFormField(
                controller: _notesCtrl,
                minLines: 4,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Explain the damage...',
                ),
              ),
              const SizedBox(height: 16),
              const _Label('Upload Photo'),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Take Photo'),
                      onPressed: () => _choose(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Choose from Gallery'),
                      onPressed: () => _choose(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              if (_photo != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_photo!, height: 120, fit: BoxFit.cover),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _clear,
                      child: const Text('Clear All', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _submit,
                      child: const Text('Report Damage', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        selectedItemColor: Color(0xFFFF473F),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          } else if (index == 2) {
            Navigator.pushNamed(context, '/schedule');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/servicehistory');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Gear'),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem),
            label: 'Report',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'History'),
        ],
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

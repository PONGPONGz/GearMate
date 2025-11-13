import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  String? _gearId;
  String? _reporterId;
  File? _photo;

  final _gears = const [
    'Helmet A12',
    'SCBA Tank 4',
    'Nozzle 2-inch',
    'Gloves – Pair 7',
  ];
  final _reporters = const ['1001', '1002', '1003'];

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
      _gearId = null;
      _reporterId = null;
      _photo = null;
    });
  }

  void _submit() {
    if (!(_form.currentState?.validate() ?? false)) return;
    final payload = {
      'gearId': _gearId,
      'reportDate': _reportDateCtrl.text,
      'reporterId': _reporterId,
      'notes': _notesCtrl.text,
      'hasPhoto': _photo != null,
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Damage reported $payload')));
    _clear();
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
              const _Label('Gear ID'),
              DropdownButtonFormField<String>(
                value: _gearId,
                items: _gears
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _gearId = v),
                decoration: const InputDecoration(hintText: 'Select gear ID'),
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
              const _Label('Reporter ID'),
              DropdownButtonFormField<String>(
                value: _reporterId,
                items: _reporters
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _reporterId = v),
                decoration: const InputDecoration(
                  hintText: 'Select reporter ID',
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
                      child: const Text('Report Damage'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            label: 'Gear',
          ),
          NavigationDestination(
            icon: Icon(Icons.report_gmailerrorred_outlined),
            label: 'Report',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_available_outlined),
            label: 'Schedule',
          ),
        ],
        selectedIndex: 1,
        backgroundColor: Colors.white,
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

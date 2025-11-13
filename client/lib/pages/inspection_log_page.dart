import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  String? _gearId;
  String? _inspectorId;
  String? _inspectionType;

  final _gears = const [
    'Helmet A12',
    'SCBA Tank 4',
    'Nozzle 2-inch',
    'Gloves – Pair 7',
  ];
  final _inspectors = const ['2001', '2002', '2003'];
  final _types = const [
    'Routine',
    'Post-Repair',
    'Safety Recall',
    'Deep Clean',
  ];

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
      _gearId = null;
      _inspectorId = null;
      _inspectionType = null;
    });
  }

  void _submit() {
    if (!(_form.currentState?.validate() ?? false)) return;
    final payload = {
      'gearId': _gearId,
      'inspectionDate': _dateCtrl.text,
      'inspectorId': _inspectorId,
      'inspectionType': _inspectionType,
      'notes': _notesCtrl.text,
    };
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Inspection submitted $payload')));
    _clear();
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
              const _Label('Inspector ID'),
              DropdownButtonFormField<String>(
                value: _inspectorId,
                items: _inspectors
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _inspectorId = v),
                decoration: const InputDecoration(
                  hintText: 'Select inspector ID',
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

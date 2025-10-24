import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddMaintenanceSchedulePage extends StatefulWidget {
  const AddMaintenanceSchedulePage({super.key, this.onSaved});

  final void Function(MaintenanceSchedule data)? onSaved;

  @override
  State<AddMaintenanceSchedulePage> createState() =>
      _AddMaintenanceSchedulePageState();
}

class _AddMaintenanceSchedulePageState
    extends State<AddMaintenanceSchedulePage> {
  final _formKey = GlobalKey<FormState>();

  final _gearIdCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  DateTime? _scheduledDate;

  final _frequencies = const [
    'Daily',
    'Weekly',
    'Monthly',
    'Quarterly',
    'Yearly',
    'Custom',
  ];
  String? _frequency;

  bool? _sharedAcrossDept; // true / false

  final _df = DateFormat('yyyy-MM-dd');

  @override
  void dispose() {
    _gearIdCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() {
        _scheduledDate = picked;
        _dateCtrl.text = _df.format(picked);
      });
    }
  }

  void _clearAll() {
    setState(() {
      _gearIdCtrl.clear();
      _scheduledDate = null;
      _dateCtrl.clear();
      _frequency = null;
      _sharedAcrossDept = null;
    });
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) return;

    final data = MaintenanceSchedule(
      gearId: _gearIdCtrl.text.trim(),
      scheduledDate: _scheduledDate!,
      frequency: _frequency!,
      sharedAcrossDepartment: _sharedAcrossDept ?? false,
    );

    widget.onSaved?.call(data);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Schedule saved')));
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE85B4B),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Add Maintenance Schedule',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              _SectionLabel('Gear ID'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _gearIdCtrl,
                textInputAction: TextInputAction.next,
                decoration: _fieldDecoration(hint: 'Enter gear id'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Gear ID is required'
                    : null,
              ),
              const SizedBox(height: 20),

              _SectionLabel('Scheduled Date'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dateCtrl,
                readOnly: true,
                onTap: _pickDate,
                decoration: _fieldDecoration(
                  hint: 'Select scheduled date',
                  suffixIcon: IconButton(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today_outlined),
                  ),
                ),
                validator: (_) =>
                    _scheduledDate == null ? 'Please pick a date' : null,
              ),
              const SizedBox(height: 20),

              _SectionLabel('Frequency'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _frequency,
                decoration: _fieldDecoration(
                  hint: 'Select frequency',
                ).copyWith(suffixIcon: const Icon(Icons.keyboard_arrow_down)),
                items: _frequencies
                    .map(
                      (f) => DropdownMenuItem<String>(value: f, child: Text(f)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _frequency = v),
                validator: (v) =>
                    v == null ? 'Please select a frequency' : null,
              ),
              const SizedBox(height: 24),

              _SectionLabel('Shared Across Department'),
              const SizedBox(height: 8),
              Row(
                children: [
                  _RadioPill<bool>(
                    title: 'True',
                    value: true,
                    groupValue: _sharedAcrossDept,
                    onChanged: (v) => setState(() => _sharedAcrossDept = v),
                  ),
                  const SizedBox(width: 16),
                  _RadioPill<bool>(
                    title: 'False',
                    value: false,
                    groupValue: _sharedAcrossDept,
                    onChanged: (v) => setState(() => _sharedAcrossDept = v),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearAll,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE85B4B)),
                        foregroundColor: const Color(0xFFE85B4B),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        'Clear All',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const StadiumBorder(),
                        elevation: 2,
                        textStyle: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      child: const Text('Save Schedule'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({required String hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE85B4B), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}

class _RadioPill<T> extends StatelessWidget {
  const _RadioPill({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String title;
  final T value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () => onChanged(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<T>(
            value: value,
            groupValue: groupValue,
            onChanged: onChanged,
            visualDensity: VisualDensity.compact,
          ),
          Text(title, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

/// Simple data model for the page
class MaintenanceSchedule {
  final String gearId;
  final DateTime scheduledDate;
  final String frequency;
  final bool sharedAcrossDepartment;

  MaintenanceSchedule({
    required this.gearId,
    required this.scheduledDate,
    required this.frequency,
    required this.sharedAcrossDepartment,
  });

  @override
  String toString() =>
      'MaintenanceSchedule(gearId: $gearId, date: $scheduledDate, '
      'frequency: $frequency, sharedAcrossDepartment: $sharedAcrossDepartment)';
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gear_mate/services/gear_api.dart';

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

  final _df = DateFormat('yyyy-MM-dd');

  bool _prefilledFromArgs = false;
  bool _saving = false;

  @override
  void dispose() {
    _gearIdCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Prefill gear id from Navigator arguments if provided
    if (!_prefilledFromArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map) {
        final dynamic val = args['gearId'];
        if (val != null) {
          _gearIdCtrl.text = val.toString();
        }
      }
      _prefilledFromArgs = true;
    }
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
    });
  }

  Future<void> _save() async {
    if (_formKey.currentState?.validate() != true) return;

    // Resolve gear_id: accept numeric id
    final raw = _gearIdCtrl.text.trim();
    int? gearId = int.tryParse(raw);

    if (gearId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid Gear ID. Enter a numeric id or a known serial number.',
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await GearApi.createSchedule(
        gearId: gearId,
        scheduledDate: _scheduledDate!,
      );

      widget.onSaved?.call(
        MaintenanceSchedule(gearId: raw, scheduledDate: _scheduledDate!),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Schedule saved')));

      // Navigate back to home and signal refresh
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(
        context,
      ).pushReplacementNamed('/', arguments: {'refresh': true});
    } catch (e) {
      final msg = e.toString();
      // Surface a friendly message for conflict (one active schedule rule)
      final friendly =
          msg.contains('409')
              ? 'This gear already has a pending schedule. Complete or cancel it first.'
              : 'Failed to save schedule: $msg';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendly)));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
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
                validator: (_) {
                  if (_scheduledDate == null) return 'Please pick a date';
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final picked = DateTime(
                    _scheduledDate!.year,
                    _scheduledDate!.month,
                    _scheduledDate!.day,
                  );
                  if (picked.isBefore(today)) {
                    return 'Date cannot be in the past';
                  }
                  return null;
                },
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
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const StadiumBorder(),
                        elevation: 2,
                        textStyle: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      child:
                          _saving
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text('Save Schedule'),
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

/// Simple data model for the page
class MaintenanceSchedule {
  final String gearId;
  final DateTime scheduledDate;

  MaintenanceSchedule({required this.gearId, required this.scheduledDate});

  @override
  String toString() =>
      'MaintenanceSchedule(gearId: $gearId, date: $scheduledDate)';
}

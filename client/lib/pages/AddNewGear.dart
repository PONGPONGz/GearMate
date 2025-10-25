import 'package:flutter/material.dart';
import 'package:gear_mate/services/gear_api.dart';

class addnewgearpage extends StatefulWidget {
  @override
  _AddGearPageState createState() => _AddGearPageState();
}

class _AddGearPageState extends State<addnewgearpage> {
  final _formKey = GlobalKey<FormState>();

  String? selectedStation;
  String? selectedGearType;

  DateTime? purchaseDate;
  DateTime? expiryDate;
  DateTime? maintenanceDate;

  final TextEditingController _gearNameController = TextEditingController();
  final TextEditingController _serialController = TextEditingController();

  Future<void> _selectDate(
    BuildContext context,
    DateTime? currentDate,
    Function(DateTime) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) onDateSelected(picked);
  }

  @override
  void dispose() {
    _gearNameController.dispose();
    _serialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFF473F),
        title: const Text(
          "Add Gear",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  label: "Gear Name",
                  hint: "Enter gear name",
                  controller: _gearNameController,
                  validator:
                      (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                _buildTextField(
                  label: "Serial Number",
                  hint: "Enter serial number",
                  controller: _serialController,
                ),
                _buildDropdown("Station Number", ["Station 1", "Station 2"], (
                  value,
                ) {
                  setState(() => selectedStation = value);
                }),
                _buildDropdown("Gear Type", ["Helmet", "Hose", "Oxygen Tank"], (
                  value,
                ) {
                  setState(() => selectedGearType = value);
                }),
                _buildDatePicker(
                  "Purchase Date",
                  purchaseDate,
                  (date) => setState(() => purchaseDate = date),
                ),
                _buildDatePicker(
                  "Expiry Date",
                  expiryDate,
                  (date) => setState(() => expiryDate = date),
                ),
                _buildDatePicker(
                  "Maintenance Date",
                  maintenanceDate,
                  (date) => setState(() => maintenanceDate = date),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Upload Photo",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildButton(Icons.camera_alt, "Take Photo"),
                    const SizedBox(width: 10),
                    _buildButton(Icons.photo_library, "Choose from Gallery"),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _actionButton(
                      "Clear All",
                      Colors.white,
                      Color(0xFFFF473F),
                      Color(0xFFFF473F),
                    ),
                    _actionButton(
                      "Save Gear",
                      const Color.fromARGB(255, 0, 0, 0),
                      Colors.white,
                      Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        value: null,
        onChanged: onChanged,
        items:
            items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime? date,
    Function(DateTime) onDateSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => _selectDate(context, date, onDateSelected),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date == null
                    ? "Select $label".replaceAll("Select ", "")
                    : date.toString().split(' ')[0],
              ),
              const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(IconData icon, String text) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: const BorderSide(color: Colors.grey),
      ),
    );
  }

  Widget _actionButton(
    String text,
    Color background,
    Color borderColor,
    Color textColor,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () async {
            if (text == 'Clear All') {
              _gearNameController.clear();
              _serialController.clear();
              setState(() {
                selectedStation = null;
                selectedGearType = null;
                purchaseDate = null;
                expiryDate = null;
                maintenanceDate = null;
              });
              return;
            }

            // Save Gear
            if (!_formKey.currentState!.validate()) return;

            if (selectedStation == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please select a Station Number')),
              );
              return;
            }

            try {
              final stationMatch = RegExp(r"\d+").firstMatch(selectedStation!);
              final stationId =
                  stationMatch != null ? int.parse(stationMatch.group(0)!) : 1;

              String? fmt(DateTime? d) =>
                  d == null ? null : d.toIso8601String().split('T').first;

              final payload = <String, dynamic>{
                'station_id': stationId,
                'gear_name': _gearNameController.text.trim(),
                if (_serialController.text.trim().isNotEmpty)
                  'serial_number': _serialController.text.trim(),
                if (selectedGearType != null)
                  'equipment_type': selectedGearType,
                if (purchaseDate != null) 'purchase_date': fmt(purchaseDate),
                if (expiryDate != null) 'expiry_date': fmt(expiryDate),
              };

              final created = await GearApi.createGear(payload);
              final gearId = created['id'] as int;

              if (maintenanceDate != null) {
                await GearApi.createSchedule(
                  gearId: gearId,
                  scheduledDate: maintenanceDate!,
                );
              }

              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gear saved successfully')),
              );
              Navigator.pop(context, true);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to save gear: $e')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: background,
            foregroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: borderColor),
            ),
          ),
          child: Text(text),
        ),
      ),
    );
  }
}

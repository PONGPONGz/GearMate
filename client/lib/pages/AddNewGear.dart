import 'package:flutter/material.dart';

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

  Future<void> _selectDate(BuildContext context, DateTime? currentDate, Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) onDateSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFF473F),
        title: const Text("Add Gear", style: TextStyle(
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
                _buildTextField("Gear Name", "Enter gear name"),
                _buildTextField("Serial Number", "Enter serial number"),
                _buildDropdown("Station Number", ["Station 1", "Station 2"], (value) {
                  setState(() => selectedStation = value);
                }),
                _buildDropdown("Gear Type", ["Helmet", "Hose", "Oxygen Tank"], (value) {
                  setState(() => selectedGearType = value);
                }),
                _buildDatePicker("Purchase Date", purchaseDate, (date) => setState(() => purchaseDate = date)),
                _buildDatePicker("Expiry Date", expiryDate, (date) => setState(() => expiryDate = date)),
                _buildDatePicker("Maintenance Date", maintenanceDate, (date) => setState(() => maintenanceDate = date)),
                const SizedBox(height: 10),
                const Text("Upload Photo", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildButton(Icons.camera_alt, "Take Photo"),
                    const SizedBox(width: 10),
                    _buildButton(Icons.photo_library, "Choose from Gallery"),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Status", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildStatus("OK", Colors.greenAccent),
                    _buildStatus("Due Soon", Colors.amberAccent),
                    _buildStatus("Needs Service", Colors.redAccent),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _actionButton("Clear All", Colors.white,Color(0xFFFF473F),Color(0xFFFF473F)),
                    _actionButton("Save Gear", const Color.fromARGB(255, 0, 0, 0), Colors.white, Colors.white),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        value: null,
        onChanged: onChanged,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, Function(DateTime) onDateSelected) {
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
              Text(date == null ? "Select $label".replaceAll("Select ", "") : date.toString().split(' ')[0]),
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

  Widget _buildStatus(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _actionButton(String text, Color background, Color borderColor, Color textColor) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () {},
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

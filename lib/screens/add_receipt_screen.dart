import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/database_helper.dart';
import '../../models/receipt_model.dart';

class AddReceiptScreen extends StatefulWidget {
  const AddReceiptScreen({super.key});

  @override
  State<AddReceiptScreen> createState() => _AddReceiptScreenState();
}

class _AddReceiptScreenState extends State<AddReceiptScreen> {
  final _storeController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Food & Drink';
  DateTime _selectedDate = DateTime.now();
  
  final List<String> _categories = [
    'Food & Drink',
    'Groceries',
    'Transport',
    'Electronics',
    'Bills',
    'Shopping',
    'Other'
  ];

  Future<void> _saveReceipt() async {
    if (_storeController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final newReceipt = Receipt(
      storeName: _storeController.text,
      amount: double.tryParse(_amountController.text) ?? 0.0,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      category: _selectedCategory,
    );

    await DatabaseHelper.instance.addReceipt(newReceipt);

    if (mounted) {
      Navigator.pop(context, true); // Return "true" to indicate refresh needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Add Receipt"),
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Placeholder for Camera View
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white24),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt, size: 40, color: Colors.white54),
                  SizedBox(height: 10),
                  Text("Tap to Scan Receipt", style: TextStyle(color: Colors.white54)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            const Text("Verify Details", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            _buildTextField("Store Name", Icons.store, _storeController),
            const SizedBox(height: 15),
            _buildTextField("Amount", Icons.attach_money, _amountController, isNumber: true),
            const SizedBox(height: 15),
            
            // Category Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(12)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  dropdownColor: const Color(0xFF2E004B),
                  style: const TextStyle(color: Colors.white),
                  isExpanded: true,
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
              ),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurpleAccent),
                onPressed: _saveReceipt,
                child: const Text("Save Receipt", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon, TextEditingController controller, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white54),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/database_helper.dart';
import '../../models/receipt_model.dart';
import '../../services/ocr_service.dart';
import '../../services/sassy_coach_service.dart';

class AddReceiptScreen extends StatefulWidget {
  const AddReceiptScreen({super.key});

  @override
  State<AddReceiptScreen> createState() => _AddReceiptScreenState();
}

class _AddReceiptScreenState extends State<AddReceiptScreen> {
  // Services
  final _ocrService = OcrService();
  final _coachService = SassyCoachService();
  final _picker = ImagePicker();

  // Controllers & State
  final _storeController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Food & Drink';
  final DateTime _selectedDate = DateTime.now();
  
  File? _image;
  String? _roastMessage; 
  bool _isScanning = false;

  final List<String> _categories = [
    'Food & Drink', 'Groceries', 'Transport', 'Electronics',
    'Bills', 'Shopping', 'Other'
  ];

  @override
  void dispose() {
    _ocrService.dispose();
    _storeController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // --- Logic: Pick Image, OCR, and Roast ---
  Future<void> _pickAndAnalyzeImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
      
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isScanning = true;
          _roastMessage = null; // Clear old roast
        });

        // 1. Run OCR
        final text = await _ocrService.scanReceipt(pickedFile.path);
        
        // 2. Simple Auto-fill Attempt (Regex to find the biggest price)
        final priceRegex = RegExp(r'(\d+[.,]\d{2})');
        final matches = priceRegex.allMatches(text);
        if (matches.isNotEmpty) {
           // Takes the last price found, often the total
           String probablePrice = matches.last.group(0)!.replaceAll(',', '.');
           _amountController.text = probablePrice;
        }

        // 3. Trigger the Roast
        final roast = await _coachService.sendMessage(text);

        if (mounted) {
          setState(() {
            _roastMessage = roast;
            _isScanning = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _roastMessage = "Even the AI is speechless (Error: $e)";
        });
      }
    }
  }

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
      currency: 'RON',
    );

    await DatabaseHelper.instance.addReceipt(newReceipt);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  // --- UI Construction ---
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
            // 1. Camera / Image Area
            GestureDetector(
              onTap: _isScanning ? null : _pickAndAnalyzeImage,
              child: Container(
                height: 200, 
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white24),
                  image: _image != null 
                    ? DecorationImage(image: FileImage(_image!), fit: BoxFit.cover, opacity: 0.5)
                    : null
                ),
                child: _isScanning 
                  ? const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_image == null ? Icons.camera_alt : Icons.refresh, size: 40, color: Colors.white54),
                        const SizedBox(height: 10),
                        Text(
                          _image == null ? "Tap to Scan Receipt" : "Tap to Retake", 
                          style: const TextStyle(color: Colors.white54)
                        ),
                      ],
                    ),
              ),
            ),
            
            // 2. The Roast Card (Appears after scan)
            if (_roastMessage != null) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.withOpacity(0.2), Colors.orange.withOpacity(0.1)],
                  ),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text("🔥 FINANCIAL REALITY CHECK 🔥", 
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _roastMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],

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
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurpleAccent),
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
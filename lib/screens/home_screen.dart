import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/receipt_model.dart';
import '../../data/database_helper.dart';
import '../../main.dart';
import '../screens/add_receipt_screen.dart';
import '../screens/statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _totalSpent = 0.0;
  List<Receipt> _recentReceipts = [];
  
  // Default currency
  String _selectedCurrency = 'USD';

  // Approximate Exchange Rates (Base: USD)
  // You can update these with real API data in the future
  final Map<String, double> _exchangeRates = {
    'USD': 1.00,
    'EUR': 0.95, // 1 USD = 0.95 Euro
    'RON': 4.78, // 1 USD = 4.78 Lei
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final total = await DatabaseHelper.instance.getTotalSpending();
    final receipts = await DatabaseHelper.instance.getAllReceipts();
    if (mounted) {
      setState(() {
        _totalSpent = total;
        _recentReceipts = receipts.take(5).toList(); // Show top 5
      });
    }
  }

  // Helper to get the correct symbol
  String get _currencySymbol {
    switch (_selectedCurrency) {
      case 'EUR': return '€';
      case 'RON': return 'RON ';
      default: return '\$';
    }
  }

  // Helper to convert amounts for display
  String _formatAmount(double amount) {
    double converted = amount * (_exchangeRates[_selectedCurrency] ?? 1.0);
    return "${_currencySymbol}${converted.toStringAsFixed(2)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.deepPurpleAccent,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Welcome back,", style: TextStyle(fontSize: 12, color: Colors.white70)),
                Text(widget.user.fullName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ],
        ),
        actions: [
          // Currency Selector
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCurrency,
                dropdownColor: const Color(0xFF2E004B),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                items: _exchangeRates.keys.map((String currency) {
                  return DropdownMenuItem<String>(
                    value: currency,
                    child: Text(currency),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCurrency = newValue;
                    });
                  }
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Total Spending Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF4A148C)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Spent", style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 8),
                        // Use the format helper here
                        Text(_formatAmount(_totalSpent), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.camera_alt_outlined, 
                          label: "Scan Receipt", 
                          color: Colors.blueAccent,
                          onTap: () async {
                            // Navigate to Add Receipt and wait for result
                            final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddReceiptScreen()));
                            if (result == true) _loadData(); // Refresh if new receipt added
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.bar_chart, 
                          label: "Analytics", 
                          color: Colors.orangeAccent,
                          onTap: () {
                             Navigator.push(context, MaterialPageRoute(builder: (_) => const StatisticsScreen()));
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Recent List
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Recent Activity", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: _recentReceipts.isEmpty 
                    ? const Center(child: Text("No receipts yet. Start scanning!", style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        itemCount: _recentReceipts.length,
                        itemBuilder: (context, index) {
                          final receipt = _recentReceipts[index];
                          return TransactionTile(
                            store: receipt.storeName, 
                            category: receipt.category, 
                            // Use the format helper here
                            amount: "-${_formatAmount(receipt.amount)}", 
                            date: receipt.date,
                            icon: Icons.receipt
                          );
                        },
                      ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
            final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddReceiptScreen()));
            if (result == true) _loadData();
        },
        backgroundColor: Colors.deepPurpleAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF120024),
        shape: const CircularNotchedRectangle(),
        child: SizedBox(height: 60),
      ),
    );
  }
}

// Reuse Helper Widgets
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final String store;
  final String category;
  final String amount;
  final String date;
  final IconData icon;

  const TransactionTile({super.key, required this.store, required this.category, required this.amount, required this.date, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: Colors.white70, size: 20)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(store, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), Text(category, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12))])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(amount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), Text(date, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12))]),
        ],
      ),
    );
  }
}

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Color(0xFF120024), Color(0xFF2E004B)],
          stops: [0.3, 0.7, 1.0],
        ),
      ),
    );
  }
}
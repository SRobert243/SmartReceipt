import 'package:flutter/material.dart';
import 'package:smart_receipt/data/database_helper.dart';
import 'package:smart_receipt/models/user_model.dart';
import 'package:smart_receipt/screens/home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _startApp() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    // Creăm un utilizator "dummy".
    // Email-ul și parola sunt completate automat în spate, utilizatorul nu le vede.
    final user = User(
      fullName: _nameController.text.trim(),
      email: "user@local.app", 
      password: "password123",     
    );

    // Salvăm în baza de date
    await DatabaseHelper.instance.registerUser(user);
    
    // Recuperăm utilizatorul salvat (pentru a avea ID-ul corect)
    final savedUser = await DatabaseHelper.instance.getCurrentUser();

    if (!mounted) return;
    
    if (savedUser != null) {
      // Mergem direct la Home
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (_) => HomeScreen(user: savedUser))
      );
    } else {
       setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wallet, size: 80, color: Colors.deepPurpleAccent),
              const SizedBox(height: 20),
              const Text(
                "SmartReceipt", 
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)
              ),
              const SizedBox(height: 10),
              const Text(
                "What's yo name?", 
                style: TextStyle(color: Colors.white54)
              ),
              const SizedBox(height: 40),
              
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Your name",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              
              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _startApp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("STARTT"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
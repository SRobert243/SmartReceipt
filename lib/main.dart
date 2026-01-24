import 'package:flutter/material.dart';
import 'package:smart_receipt/data/database_helper.dart';
import 'package:smart_receipt/models/user_model.dart';
import 'package:smart_receipt/screens/home_screen.dart';
import 'package:smart_receipt/screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Aici este magia: verificăm baza de date înainte să pornească aplicația
  final user = await DatabaseHelper.instance.getCurrentUser();

  runApp(SmartReceiptApp(initialUser: user));
}

class SmartReceiptApp extends StatelessWidget {
  final User? initialUser;
  
  const SmartReceiptApp({super.key, this.initialUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartReceipt',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      // Decidem ecranul de start
      home: initialUser != null 
          ? HomeScreen(user: initialUser!) 
          : const WelcomeScreen(),
    );
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to El Nada Market',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

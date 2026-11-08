
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final Future<void> Function() onLogout;

  const HomeScreen({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () async {
              await onLogout();
            },
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

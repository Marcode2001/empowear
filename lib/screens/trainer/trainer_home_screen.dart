import 'package:flutter/material.dart';

class TrainerHomeScreen extends StatelessWidget {
  const TrainerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainer Dashboard'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text('Trainer Home Screen - قيد التطوير'),
      ),
    );
  }
}
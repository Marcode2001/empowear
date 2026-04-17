import 'package:flutter/material.dart';

class TraineeHomeScreen extends StatelessWidget {
  const TraineeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trainee Dashboard'),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text('Trainee Home Screen - قيد التطوير'),
      ),
    );
  }
}
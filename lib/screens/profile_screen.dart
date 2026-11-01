import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TextField(decoration: InputDecoration(labelText: 'Name')),
          const TextField(
            decoration: InputDecoration(labelText: 'Phone number'),
            keyboardType: TextInputType.phone,
          ),
          const TextField(decoration: InputDecoration(labelText: 'City')),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {}, // TODO: update user
            child: const Text('Save'),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {}, // TODO: firebase_auth.signOut()
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../profile_screen.dart';
import '../publish_gig_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gig Finder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Hello, [name]'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PublishGigScreen(),
                ),
              );
            },
            child: const Text('Publish Gig'),
          ),
          ElevatedButton(
            onPressed: () {}, // TODO: change to Search Gigs tab
            child: const Text('Search Gig'),
          ),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(child: _CounterCard(label: 'My active Gigs')),
              Expanded(child: _CounterCard(label: 'Active Gigs on my city')),
            ],
          ),
        ],
      ),
    );
  }
}

class _CounterCard extends StatelessWidget {
  const _CounterCard({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [const Text('0'), Text(label)]),
      ),
    );
  }
}

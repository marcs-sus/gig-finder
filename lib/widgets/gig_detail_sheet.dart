import 'package:flutter/material.dart';

class GigDetailSheet extends StatelessWidget {
  const GigDetailSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Gig Title'),
          const SizedBox(height: 8),
          const Text('Tag1 · Tag2'),
          const SizedBox(height: 8),
          const Text('Complete gig description...'),
          const SizedBox(height: 8),
          const Text('Neighborhood'),
          const Text('Prince range'),
          // TODO: show when location != null
          const Text('Available on map'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {}, // TODO: url_launcher → wa.me
            child: const Text('Contact'),
          ),
        ],
      ),
    );
  }
}

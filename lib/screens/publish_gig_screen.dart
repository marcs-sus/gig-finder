import 'package:flutter/material.dart';

class PublishGigScreen extends StatelessWidget {
  const PublishGigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publish Gig')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const TextField(decoration: InputDecoration(labelText: 'Title')),
          const TextField(
            decoration: InputDecoration(labelText: 'Description'),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          const Text('Tags'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tag in const ['tag1', 'tag2', 'tag3'])
                Chip(label: Text(tag)),
              ActionChip(
                label: const Text('add +'),
                onPressed: () {}, // TODO: open dialog for the new tag
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Include in map'),
            value: false, // TODO: control by local state
            onChanged: (_) {},
          ),
          // TODO: show only when switch is on
          const Placeholder(fallbackHeight: 200),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(labelText: 'Neighborhood (optional)'),
          ),
          const TextField(
            decoration: InputDecoration(labelText: 'Price range (optional)'),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {}, // TODO: write on Firestore
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

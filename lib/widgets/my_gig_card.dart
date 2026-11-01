import 'package:flutter/material.dart';

class MyGigCard extends StatelessWidget {
  const MyGigCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Text('Gig Title'),
        subtitle: const Text('Tags · Time · Status'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              tooltip: 'End',
              onPressed: () {}, // TODO: status = closed
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: () {}, // TODO: remover documento
            ),
          ],
        ),
      ),
    );
  }
}

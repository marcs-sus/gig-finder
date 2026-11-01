import 'package:flutter/material.dart';

import 'gig_detail_sheet.dart';

class GigCard extends StatelessWidget {
  const GigCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Text('Gig Title'),
        subtitle: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tag1 · Tag2'),
            Text('Neighborhood · Price range'),
            Text('Description preview...'),
          ],
        ),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          builder: (_) => const GigDetailSheet(),
        ),
      ),
    );
  }
}

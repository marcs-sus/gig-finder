import 'package:flutter/material.dart';

import '../models/gig_model.dart';
import 'gig_detail_sheet.dart';

class GigCard extends StatelessWidget {
  const GigCard({super.key, required this.gig});

  final GigModel gig;

  @override
  Widget build(BuildContext context) {
    final info = [
      if (gig.neighborhood != null && gig.neighborhood!.isNotEmpty)
        gig.neighborhood!,
      if (gig.priceRange != null && gig.priceRange!.isNotEmpty) gig.priceRange!,
    ].join(' · ');

    return Card(
      child: ListTile(
        title: Text(gig.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (gig.tags.isNotEmpty) Text(gig.tags.join(' · ')),
            if (info.isNotEmpty) Text(info),
            Text(
              gig.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        onTap: () => GigDetailSheet.show(context, gig),
      ),
    );
  }
}

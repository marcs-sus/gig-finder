import 'package:flutter/material.dart';

import '../../widgets/gig_card.dart';

class SearchGigsTab extends StatelessWidget {
  const SearchGigsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search Gigs'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Map'),
              Tab(text: 'Search'),
            ],
          ),
        ),
        body: const TabBarView(children: [MapTab(), ListTab()]),
      ),
    );
  }
}

class MapTab extends StatelessWidget {
  const MapTab({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: change to FlutterMap with MarkerLayer for active gigs
    // each marker opens a GigDetailSheet
    return const Placeholder();
  }
}

class ListTab extends StatelessWidget {
  const ListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search by title',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              for (final tag in const ['tag1', 'tag2', 'tag3'])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(tag),
                    selected: false,
                    onSelected: (_) {}, // TODO: change filter
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView(children: const [GigCard(), GigCard(), GigCard()]),
        ),
      ],
    );
  }
}

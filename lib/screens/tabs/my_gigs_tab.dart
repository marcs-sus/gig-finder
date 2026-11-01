import 'package:flutter/material.dart';

import '../../widgets/my_gig_card.dart';
import '../publish_gig_screen.dart';

class MyGigsTab extends StatelessWidget {
  const MyGigsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Gigs')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PublishGigScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: ListView(children: const [MyGigCard(), MyGigCard()]),
    );
  }
}

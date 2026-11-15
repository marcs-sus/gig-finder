import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/gig_model.dart';

class GigRepository {
  final FirebaseFirestore _db;

  GigRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference get _gigsRef => _db.collection('gigs');

  /// Create a new gig. Its ID is created trough Firestore.
  Future<void> createGig(GigModel gig) async {
    await _gigsRef.add(gig.toFirestore());
  }

  /// Stream of the authenticated user's gigs, ordered by creation date (most recent first).
  Stream<List<GigModel>> streamMyGigs(String ownerId) {
    return _gigsRef
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => GigModel.fromFirestore(doc)).toList(),
        );
  }

  /// Stream of the active city's gigs, ordered by creation date (most recent first).
  Stream<List<GigModel>> streamActiveGigsByCity(String city) {
    return _gigsRef
        .where('city', isEqualTo: city)
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => GigModel.fromFirestore(doc)).toList(),
        );
  }

  /// Update the status of a gig.
  Future<void> updateGigStatus(String gigId, String newStatus) async {
    await _gigsRef.doc(gigId).update({'status': newStatus});
  }

  /// Delete a gig.
  Future<void> deleteGig(String gigId) async {
    await _gigsRef.doc(gigId).delete();
  }
}

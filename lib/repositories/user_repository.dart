import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _db;

  UserRepository({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  CollectionReference get _usersRef => _db.collection('users');

  /// Stream of the current user's document.
  Stream<UserModel?> streamCurrentUser(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  /// Update the user's profile.
  Future<void> updateProfile(UserModel user) async {
    await _usersRef.doc(user.uid).update(user.toFirestore());
  }
}

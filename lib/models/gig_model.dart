import 'package:cloud_firestore/cloud_firestore.dart';

class GigModel {
  final String id;
  final String ownerId;
  final String? ownerName;
  final String title;
  final String category;
  final String description;
  final String? neighborhood;
  final String? priceRange;
  final String? photoUrl;
  final String city;
  final GeoPoint? location;
  final String status; // 'active' | 'closed'
  final DateTime createdAt;

  GigModel({
    required this.id,
    required this.ownerId,
    this.ownerName,
    required this.title,
    required this.category,
    required this.description,
    this.neighborhood,
    this.priceRange,
    this.photoUrl,
    required this.city,
    this.location,
    this.status = 'active',
    required this.createdAt,
  });

  factory GigModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return GigModel(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      ownerName: data['ownerName'] as String?,
      title: data['title'] as String? ?? '',
      category: data['category'] as String? ?? '',
      description: data['description'] as String? ?? '',
      neighborhood: data['neighborhood'] as String?,
      priceRange: data['priceRange'] as String?,
      photoUrl: data['photoUrl'] as String?,
      city: data['city'] as String? ?? '',
      location: data['location'] as GeoPoint?,
      status: data['status'] as String? ?? 'active',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'ownerName': ownerName,
      'title': title,
      'category': category,
      'description': description,
      'neighborhood': neighborhood,
      'priceRange': priceRange,
      'photoUrl': photoUrl,
      'city': city,
      'location': location,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

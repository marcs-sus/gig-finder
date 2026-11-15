import 'package:cloud_firestore/cloud_firestore.dart';

class _Sentinel {
  const _Sentinel();
}

const _sentinel = _Sentinel();

class Gig {
  static const String statusActive = 'active';
  static const String statusClosed = 'closed';
  static const Set<String> validStatuses = {statusActive, statusClosed};

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
  final String status;
  final DateTime createdAt;

  Gig({
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
    this.status = statusActive,
    required this.createdAt,
  }) {
    if (!validStatuses.contains(status)) {
      throw ArgumentError.value(
        status,
        'status',
        'O status deve ser "active" ou "closed".',
      );
    }
  }

  /// Cria uma instância de [Gig] a partir de um [DocumentSnapshot] do Firestore.
  /// Lança [FormatException] se [createdAt] ou [status] forem inválidos ou ausentes.
  factory Gig.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};

    final status = data['status'] as String?;
    if (status == null || !validStatuses.contains(status)) {
      throw FormatException(
        'Status inválido ou ausente no documento ${doc.id}: "$status". '
        'Valores aceitos: "active", "closed".',
      );
    }

    final rawCreatedAt = data['createdAt'];
    if (rawCreatedAt is! Timestamp) {
      throw FormatException(
        'O campo "createdAt" é obrigatório e deve ser um Timestamp válido '
        'no documento ${doc.id}, mas foi encontrado: $rawCreatedAt',
      );
    }

    return Gig(
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
      status: status,
      createdAt: rawCreatedAt.toDate(),
    );
  }

  /// Converte o objeto [Gig] em um [Map<String, dynamic>] para gravação no Firestore.
  /// O campo [id] é omitido pois é a chave do documento e não deve ser persistido internamente.
  Map<String, dynamic> toFirestore() {
    if (!validStatuses.contains(status)) {
      throw StateError(
        'Tentativa de gravar status inválido no Firestore: "$status".',
      );
    }

    return {
      'ownerId': ownerId,
      if (ownerName != null) 'ownerName': ownerName,
      'title': title,
      'category': category,
      'description': description,
      if (neighborhood != null) 'neighborhood': neighborhood,
      if (priceRange != null) 'priceRange': priceRange,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'city': city,
      if (location != null) 'location': location,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Cria uma cópia da instância atual com campos modificados.
  ///
  /// Para campos opcionais ([ownerName], [neighborhood], [priceRange], [photoUrl], [location]):
  /// - Omitir o parâmetro: mantém o valor atual.
  /// - Passar `null`: limpa o valor (define como `null`).
  /// - Passar um valor: atualiza para o novo valor.
  Gig copyWith({
    String? id,
    String? ownerId,
    Object? ownerName = _sentinel,
    String? title,
    String? category,
    String? description,
    Object? neighborhood = _sentinel,
    Object? priceRange = _sentinel,
    Object? photoUrl = _sentinel,
    String? city,
    Object? location = _sentinel,
    String? status,
    DateTime? createdAt,
  }) {
    return Gig(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerName: identical(ownerName, _sentinel)
          ? this.ownerName
          : ownerName as String?,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      neighborhood: identical(neighborhood, _sentinel)
          ? this.neighborhood
          : neighborhood as String?,
      priceRange: identical(priceRange, _sentinel)
          ? this.priceRange
          : priceRange as String?,
      photoUrl: identical(photoUrl, _sentinel)
          ? this.photoUrl
          : photoUrl as String?,
      city: city ?? this.city,
      location: identical(location, _sentinel)
          ? this.location
          : location as GeoPoint?,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

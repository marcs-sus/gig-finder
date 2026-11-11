/// Bico publicado por um contratante (coleção `gigs/{gigId}`).
class Gig {
  const Gig({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.category,
    required this.description,
    required this.city,
    this.ownerName,
    this.ownerPhone,
    this.neighborhood,
    this.priceRange,
    this.photoUrl,
    this.latitude,
    this.longitude,
    this.status = 'active',
  });

  final String id;
  final String ownerId;
  final String? ownerName;

  /// Telefone do dono em E.164 (ex.: "+5547999999999"), vem de `users/{ownerId}`.
  final String? ownerPhone;

  final String title;

  /// Tags separadas por vírgula (ex.: "reforma,montagem").
  final String category;
  final String description;
  final String? neighborhood;
  final String? priceRange;
  final String? photoUrl;
  final String city;
  final double? latitude;
  final double? longitude;

  /// `active` ou `closed`.
  final String status;

  List<String> get tags => category
      .split(',')
      .map((t) => t.trim())
      .where((t) => t.isNotEmpty)
      .toList();

  bool get hasLocation => latitude != null && longitude != null;

  bool get hasPhoto => photoUrl != null && photoUrl!.trim().isNotEmpty;

  bool get isActive => status == 'active';
}

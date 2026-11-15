import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/gig_model.dart';

class GigService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  GigService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  /// Referência da coleção de anúncios de bicos
  CollectionReference<Map<String, dynamic>> get _gigsRef =>
      _firestore.collection('gigs');

  /// Referência da coleção de usuários
  CollectionReference<Map<String, dynamic>> get _usersRef =>
      _firestore.collection('users');

  /// Retorna o UID do usuário atualmente autenticado
  String? get currentUserId => _auth.currentUser?.uid;

  /// Valida se há usuário autenticado e retorna o UID.
  /// Lança [StateError] caso não haja sessão ativa.
  String _requireAuth() {
    final uid = currentUserId;
    if (uid == null) {
      throw StateError('Operação requer um usuário autenticado no Firebase.');
    }
    return uid;
  }

  /// Retorna o perfil completo do usuário autenticado em `users/{uid}`
  Future<Map<String, dynamic>?> getUserProfile() async {
    final uid = _requireAuth();
    final doc = await _usersRef.doc(uid).get();
    return doc.data();
  }

  /// Retorna a cidade cadastrada no perfil do usuário autenticado.
  /// Lança [StateError] se não houver perfil cadastrado ou cidade válida.
  Future<String> getUserCity() async {
    final uid = _requireAuth();
    final profile = await getUserProfile();

    if (profile == null) {
      throw StateError(
        'Perfil do usuário ($uid) não encontrado em "users/$uid". '
        'Complete seu cadastro antes de continuar.',
      );
    }

    final rawCity = profile['city'] as String?;
    if (rawCity == null || rawCity.trim().isEmpty) {
      throw StateError(
        'O perfil do usuário ($uid) não possui uma cidade válida cadastrada.',
      );
    }

    return rawCity.trim();
  }

  /// Cria e publica um novo anúncio de bico.
  ///
  /// - A cidade é obtida diretamente do perfil autenticado (`getUserCity()`).
  /// - `displayName` com espaços em branco é tratado, usando o Firebase Auth como fallback.
  /// - `neighborhood` e `priceRange` são salvos com `trim()`.
  Future<String> createGig({
    required String title,
    required String category,
    required String description,
    String? neighborhood,
    String? priceRange,
    String? photoUrl,
    GeoPoint? location,
  }) async {
    final uid = _requireAuth();
    final profile = await getUserProfile();

    if (profile == null) {
      throw StateError(
        'Perfil de usuário ($uid) não encontrado em "users/$uid". '
        'É obrigatório ter um perfil cadastrado para publicar bicos.',
      );
    }

    // Validação e obtenção da cidade do perfil
    final rawCity = profile['city'] as String?;
    if (rawCity == null || rawCity.trim().isEmpty) {
      throw StateError(
        'O usuário não possui uma cidade cadastrada em seu perfil. '
        'Atualize sua cidade no perfil antes de publicar um bico.',
      );
    }
    final city = rawCity.trim();

    // Tratamento do displayName com fallback para FirebaseAuth
    final profileName = (profile['displayName'] as String?)?.trim();
    final authName = _auth.currentUser?.displayName?.trim();
    final ownerName = (profileName != null && profileName.isNotEmpty)
        ? profileName
        : ((authName != null && authName.isNotEmpty) ? authName : null);

    // Sanitização com trim() de neighborhood e priceRange
    final cleanNeighborhood = neighborhood?.trim();
    final finalNeighborhood =
        (cleanNeighborhood != null && cleanNeighborhood.isNotEmpty)
        ? cleanNeighborhood
        : null;

    final cleanPriceRange = priceRange?.trim();
    final finalPriceRange =
        (cleanPriceRange != null && cleanPriceRange.isNotEmpty)
        ? cleanPriceRange
        : null;

    final cleanPhotoUrl = photoUrl?.trim();
    final finalPhotoUrl = (cleanPhotoUrl != null && cleanPhotoUrl.isNotEmpty)
        ? cleanPhotoUrl
        : null;

    final newDocRef = _gigsRef.doc();
    final gig = Gig(
      id: newDocRef.id,
      ownerId: uid,
      ownerName: ownerName,
      title: title.trim(),
      category: category.trim(),
      description: description.trim(),
      city: city,
      neighborhood: finalNeighborhood,
      priceRange: finalPriceRange,
      photoUrl: finalPhotoUrl,
      location: location,
      status: Gig.statusActive,
      createdAt: DateTime.now(),
    );

    await newDocRef.set(gig.toFirestore());
    return newDocRef.id;
  }

  /// Retorna um Stream com os bicos publicados pelo usuário autenticado.
  Stream<List<Gig>> getMyGigs() {
    final uid = _requireAuth();

    return _gigsRef.where('ownerId', isEqualTo: uid).snapshots().map((
      snapshot,
    ) {
      final gigs = snapshot.docs.map((doc) => Gig.fromFirestore(doc)).toList();

      // Ordenação em memória: mais recentes primeiro
      gigs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return gigs;
    });
  }

  /// Atualiza os dados de um anúncio existente.
  ///
  /// - Impede a edição de anúncios já encerrados (`status == closed`).
  /// - O `status` não é alterado (responsabilidade exclusiva de [closeGig]).
  /// - A cidade é atualizada com base no perfil oficial do autor (`getUserCity()`).
  /// - `ownerId` e `createdAt` originais são preservados intactos.
  /// - Campos opcionais nulos são removidos no Firestore via [FieldValue.delete()].
  Future<void> updateGig(Gig gig) async {
    final uid = _requireAuth();

    final docSnapshot = await _gigsRef.doc(gig.id).get();
    if (!docSnapshot.exists || docSnapshot.data() == null) {
      throw StateError('Bico com ID "${gig.id}" não encontrado.');
    }

    final currentData = docSnapshot.data()!;
    final currentOwnerId = currentData['ownerId'] as String?;

    if (currentOwnerId != uid) {
      throw StateError('Usuário não tem permissão para editar este bico.');
    }

    // Bloqueia reabertura ou edição de anúncio já fechado
    final currentStatus = currentData['status'] as String? ?? Gig.statusActive;
    if (currentStatus == Gig.statusClosed) {
      throw StateError(
        'Não é permitido editar ou reabrir um anúncio já encerrado.',
      );
    }

    // Cidade obtida diretamente do perfil autenticado
    final currentCity = await getUserCity();

    // Sanitização com trim() dos campos opcionais
    final cleanNeighborhood = gig.neighborhood?.trim();
    final finalNeighborhood =
        (cleanNeighborhood != null && cleanNeighborhood.isNotEmpty)
        ? cleanNeighborhood
        : null;

    final cleanPriceRange = gig.priceRange?.trim();
    final finalPriceRange =
        (cleanPriceRange != null && cleanPriceRange.isNotEmpty)
        ? cleanPriceRange
        : null;

    final cleanPhotoUrl = gig.photoUrl?.trim();
    final finalPhotoUrl = (cleanPhotoUrl != null && cleanPhotoUrl.isNotEmpty)
        ? cleanPhotoUrl
        : null;

    final cleanOwnerName = gig.ownerName?.trim();
    final finalOwnerName = (cleanOwnerName != null && cleanOwnerName.isNotEmpty)
        ? cleanOwnerName
        : null;

    // Monta o payload de atualização
    final updateData = <String, dynamic>{
      'title': gig.title.trim(),
      'category': gig.category.trim(),
      'description': gig.description.trim(),
      'city': currentCity,
      // 'status', 'ownerId' e 'createdAt' são preservados omitindo-os do mapa
      'ownerName': finalOwnerName ?? FieldValue.delete(),
      'neighborhood': finalNeighborhood ?? FieldValue.delete(),
      'priceRange': finalPriceRange ?? FieldValue.delete(),
      'photoUrl': finalPhotoUrl ?? FieldValue.delete(),
      'location': gig.location ?? FieldValue.delete(),
    };

    await _gigsRef.doc(gig.id).update(updateData);
  }

  /// Encerra um bico (muda o status para 'closed').
  Future<void> closeGig(String gigId) async {
    final uid = _requireAuth();

    final docSnapshot = await _gigsRef.doc(gigId).get();
    if (!docSnapshot.exists || docSnapshot.data() == null) {
      throw StateError('Bico não encontrado.');
    }

    final currentOwnerId = docSnapshot.data()!['ownerId'] as String?;
    if (currentOwnerId != uid) {
      throw StateError('Usuário não tem permissão para encerrar este bico.');
    }

    await _gigsRef.doc(gigId).update({'status': Gig.statusClosed});
  }

  /// Exclui permanentemente um anúncio de bico.
  Future<void> deleteGig(String gigId) async {
    final uid = _requireAuth();

    final docSnapshot = await _gigsRef.doc(gigId).get();
    if (!docSnapshot.exists || docSnapshot.data() == null) {
      throw StateError('Bico não encontrado.');
    }

    final currentOwnerId = docSnapshot.data()!['ownerId'] as String?;
    if (currentOwnerId != uid) {
      throw StateError('Usuário não tem permissão para excluir este bico.');
    }

    await _gigsRef.doc(gigId).delete();
  }
}

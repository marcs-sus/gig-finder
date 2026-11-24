import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/gig_model.dart';
import '../../models/user_model.dart';
import '../../repositories/gig_repository.dart';
import '../../repositories/user_repository.dart';
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
    // each marker opens GigDetailSheet.show(context, gig)
    return const Placeholder();
  }
}

/// Pesquisa de Bicos (RF06): bicos ativos da cidade, com busca por título e
/// filtro por tags. A cidade padrão é a do perfil do usuário.
class ListTab extends StatefulWidget {
  const ListTab({super.key});

  @override
  State<ListTab> createState() => _ListTabState();
}

class _ListTabState extends State<ListTab> with AutomaticKeepAliveClientMixin {
  final _gigRepo = GigRepository();
  final _userRepo = UserRepository();

  Stream<UserModel?>? _userStream;

  /// Cidade escolhida manualmente; null = usar a cidade do perfil.
  String? _cityOverride;
  String _query = '';
  final Set<String> _selectedTags = {}; // em minúsculas

  // Mantém o stream de bicos estável enquanto a cidade não muda.
  String? _streamCity;
  Stream<List<GigModel>>? _gigsStream;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) _userStream = _userRepo.streamCurrentUser(uid);
  }

  Stream<List<GigModel>> _gigsFor(String city) {
    if (_streamCity != city) {
      _streamCity = city;
      _gigsStream = _gigRepo.streamActiveGigsByCity(city);
    }
    return _gigsStream!;
  }

  Future<void> _changeCity(String currentCity) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _CityDialog(initial: currentCity),
    );
    if (result == null || !mounted) return; // cancelado
    setState(() {
      _cityOverride = result.isEmpty ? null : result;
      _selectedTags.clear();
    });
  }

  List<GigModel> _applyFilters(List<GigModel> gigs) {
    final q = _query.trim().toLowerCase();
    return gigs.where((g) {
      if (q.isNotEmpty && !g.title.toLowerCase().contains(q)) return false;
      // Com tags selecionadas, mostra bicos que tenham qualquer uma delas.
      if (_selectedTags.isNotEmpty &&
          !g.tags.any((t) => _selectedTags.contains(t.toLowerCase()))) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final userStream = _userStream;
    if (userStream == null) {
      return const _Message(
        icon: Icons.lock_outline,
        text: 'Faça login para pesquisar bicos.',
      );
    }

    return StreamBuilder<UserModel?>(
      stream: userStream,
      builder: (context, userSnap) {
        final profileCity = userSnap.data?.city.trim() ?? '';
        final city = (_cityOverride ?? profileCity).trim();
        final loadingProfile =
            userSnap.connectionState == ConnectionState.waiting &&
            _cityOverride == null;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Buscar por título',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.place_outlined, size: 20),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      city.isEmpty ? 'Nenhuma cidade selecionada' : city,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _changeCity(city),
                    child: const Text('Alterar'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: loadingProfile
                  ? const Center(child: CircularProgressIndicator())
                  : city.isEmpty
                  ? const _Message(
                      icon: Icons.location_city,
                      text:
                          'Defina sua cidade no perfil ou toque em "Alterar" '
                          'para ver os bicos.',
                    )
                  : _buildGigs(city),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGigs(String city) {
    return StreamBuilder<List<GigModel>>(
      stream: _gigsFor(city),
      builder: (context, snap) {
        if (snap.hasError) {
          return const _Message(
            icon: Icons.error_outline,
            text: 'Não foi possível carregar os bicos. Tente novamente.',
          );
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final all = snap.data!;
        if (all.isEmpty) {
          return _Message(
            icon: Icons.inbox_outlined,
            text: 'Nenhum bico ativo em $city por enquanto.',
          );
        }

        final filtered = _applyFilters(all);

        return Column(
          children: [
            _TagFilterBar(
              gigs: all,
              selected: _selectedTags,
              onToggle: (tag, on) => setState(() {
                on ? _selectedTags.add(tag) : _selectedTags.remove(tag);
              }),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? const _Message(
                      icon: Icons.search_off,
                      text: 'Nenhum bico encontrado com esses filtros.',
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, i) => GigCard(
                        key: ValueKey(filtered[i].id),
                        gig: filtered[i],
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// Chips de tags montados a partir dos bicos da cidade (mais usadas primeiro).
class _TagFilterBar extends StatelessWidget {
  const _TagFilterBar({
    required this.gigs,
    required this.selected,
    required this.onToggle,
  });

  final List<GigModel> gigs;
  final Set<String> selected;
  final void Function(String tag, bool on) onToggle;

  @override
  Widget build(BuildContext context) {
    final labels = <String, String>{};
    final counts = <String, int>{};
    for (final gig in gigs) {
      for (final tag in gig.tags) {
        final key = tag.toLowerCase();
        labels.putIfAbsent(key, () => tag);
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }
    if (labels.isEmpty) return const SizedBox.shrink();

    final keys = labels.keys.toList()
      ..sort((a, b) {
        final byCount = counts[b]!.compareTo(counts[a]!);
        return byCount != 0 ? byCount : a.compareTo(b);
      });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          for (final key in keys)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(labels[key]!),
                selected: selected.contains(key),
                onSelected: (on) => onToggle(key, on),
              ),
            ),
        ],
      ),
    );
  }
}

/// Diálogo para trocar a cidade. Retorna o nome digitado, '' para voltar à
/// cidade do perfil, ou null se cancelado.
class _CityDialog extends StatefulWidget {
  const _CityDialog({required this.initial});

  final String initial;

  @override
  State<_CityDialog> createState() => _CityDialogState();
}

class _CityDialogState extends State<_CityDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply() {
    final city = _controller.text.trim();
    if (city.isNotEmpty) Navigator.pop(context, city);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cidade'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(labelText: 'Nome da cidade'),
        onSubmitted: (_) => _apply(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, ''),
          child: const Text('Minha cidade'),
        ),
        FilledButton(onPressed: _apply, child: const Text('Aplicar')),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

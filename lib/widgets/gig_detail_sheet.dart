import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/gig_model.dart';

const _appName = 'BicoLocal';

/// Bottom sheet com os detalhes completos de um bico.
///
/// Uso (lista ou marcador do mapa): `GigDetailSheet.show(context, gig);`
class GigDetailSheet extends StatelessWidget {
  const GigDetailSheet({super.key, required this.gig});

  final GigModel gig;

  static Future<void> show(BuildContext context, GigModel gig) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => GigDetailSheet(gig: gig),
    );
  }

  /// Link do WhatsApp com a mensagem pré-preenchida (RF07).
  /// Retorna null se o dono não tiver telefone válido.
  static Uri? whatsappUri(GigModel gig) {
    final digits = (gig.ownerPhone ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    final msg =
        'Olá! Vi seu bico ${gig.title} no $_appName e tenho interesse. '
        'Podemos conversar?';
    return Uri.https('wa.me', '/$digits', {'text': msg});
  }

  Future<void> _contact(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = whatsappUri(gig);
    var opened = false;
    if (uri != null) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        opened = false;
      }
    }
    if (!opened) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canContact = whatsappUri(gig) != null;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (gig.hasPhoto) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AspectRatio(
                        aspectRatio: 16 / 10,
                        child: Image.network(
                          gig.photoUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) =>
                              progress == null
                              ? child
                              : const Center(
                                  child: CircularProgressIndicator(),
                                ),
                          errorBuilder: (context, error, stack) => Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(gig.title, style: theme.textTheme.headlineSmall),
                  if (gig.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final tag in gig.tags) Chip(label: Text(tag)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(gig.description, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  if (gig.neighborhood != null &&
                      gig.neighborhood!.trim().isNotEmpty)
                    _InfoRow(
                      icon: Icons.place_outlined,
                      text: '${gig.neighborhood} · ${gig.city}',
                    )
                  else
                    _InfoRow(icon: Icons.place_outlined, text: gig.city),
                  if (gig.priceRange != null &&
                      gig.priceRange!.trim().isNotEmpty)
                    _InfoRow(
                      icon: Icons.payments_outlined,
                      text: gig.priceRange!,
                    ),
                  if (gig.ownerName != null && gig.ownerName!.trim().isNotEmpty)
                    _InfoRow(
                      icon: Icons.person_outline,
                      text: 'Publicado por ${gig.ownerName}',
                    ),
                  if (gig.hasLocation)
                    const _InfoRow(
                      icon: Icons.map_outlined,
                      text: 'Disponível no mapa',
                    ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: FilledButton.icon(
              onPressed: canContact ? () => _contact(context) : null,
              icon: const Icon(Icons.chat),
              label: Text(
                canContact ? 'Entrar em contato' : 'Contato indisponível',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

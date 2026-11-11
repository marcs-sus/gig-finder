import '../models/gig.dart';

// TODO: remover quando a listagem vier do Firestore.
const sampleGigs = <Gig>[
  Gig(
    id: '1',
    ownerId: 'u1',
    ownerName: 'Marcos',
    ownerPhone: '+5547999999999',
    title: 'Montagem de guarda-roupa',
    category: 'montagem,reforma',
    description:
        'Preciso montar um guarda-roupa de 6 portas e uma cômoda. '
        'Já tenho todas as peças e o manual, só falta a mão de obra. '
        'Serviço para um período da tarde.',
    neighborhood: 'Centro',
    priceRange: 'R\$ 150 - R\$ 250',
    city: 'Itajaí',
    latitude: -26.9078,
    longitude: -48.6619,
    photoUrl: 'https://picsum.photos/seed/guarda-roupa/800/500',
  ),
  Gig(
    id: '2',
    ownerId: 'u2',
    ownerName: 'Ana',
    ownerPhone: '+5547988887777',
    title: 'Limpeza pós-obra',
    category: 'limpeza',
    description: 'Apartamento de 70 m² recém reformado, precisa de limpeza pesada.',
    neighborhood: 'Fazenda',
    city: 'Itajaí',
  ),
  Gig(
    id: '3',
    ownerId: 'u3',
    title: 'Cuidar do jardim',
    category: 'jardinagem,outros',
    description: 'Poda de plantas e corte de grama em casa com quintal médio.',
    priceRange: 'A combinar',
    city: 'Itajaí',
    latitude: -26.9,
    longitude: -48.67,
  ),
];

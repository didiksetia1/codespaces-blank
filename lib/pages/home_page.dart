import 'package:flutter/material.dart';

import '../models/agenda_item.dart';
import '../widgets/agenda_card.dart';
import '../widgets/header_card.dart';
import '../widgets/popular_agenda_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/section_title.dart';
import '../services/auth_service_sanctum.dart';
import 'aduan_hub_page.dart';
import 'agenda_page.dart';
import 'aspirasi_page.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/home';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<_HomeUserData> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUser();
  }

  Future<_HomeUserData> _loadUser() async {
    final service = SanctumAuthService(SanctumAuthService.apiBaseUrl);
    final user = await service.fetchUser();
    return _HomeUserData.fromJson(user);
  }

  static const List<AgendaItem> latestAgendas = <AgendaItem>[
    AgendaItem(
      title: 'Seminar Inspiratif: Membangun Karier di Era Digital',
      dateLabel: '12 Mei 2026',
      likesCount: 128,
      hasImage: true,
      accent: Color(0xFFDC2626),
    ),
    AgendaItem(
      title: 'Diskusi Publik: Ruang Aspirasi Mahasiswa',
      dateLabel: '10 Mei 2026',
      likesCount: 89,
      hasImage: false,
      accent: Color(0xFF991B1B),
    ),
    AgendaItem(
      title: 'Workshop Produktivitas dan Kolaborasi Tim',
      dateLabel: '09 Mei 2026',
      likesCount: 64,
      hasImage: true,
      accent: Color(0xFFB91C1C),
    ),
  ];

  static const AgendaItem popularAgenda = AgendaItem(
    title: 'Rapat Terbuka: Penguatan Suara Mahasiswa',
    dateLabel: 'Sedang hangat dibicarakan',
    likesCount: 324,
    commentsCount: 48,
    description:
        'Agenda ini menjadi pusat diskusi mahasiswa karena membahas partisipasi aktif, masukan, dan tindak lanjut aspirasi.',
    accent: Color(0xFF7F1D1D),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Talkyu'),
        backgroundColor: const Color(0xFFFDF2F2),
        surfaceTintColor: const Color(0xFFFDF2F2),
        actions: <Widget>[
          IconButton(
            tooltip: 'Agenda',
            onPressed: () => Navigator.of(context).pushNamed(AgendaPage.routeName),
            icon: const Icon(Icons.campaign_outlined),
          ),
          IconButton(
            tooltip: 'Aspirasi',
            onPressed: () => Navigator.of(context).pushNamed(AspirasiPage.routeName),
            icon: const Icon(Icons.record_voice_over_outlined),
          ),
          IconButton(
            tooltip: 'Aduan',
            onPressed: () => Navigator.of(context).pushNamed(AduanHubPage.routeName),
            icon: const Icon(Icons.assignment_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                      FutureBuilder<_HomeUserData>(
                        future: _userFuture,
                        builder: (context, snapshot) {
                          final user = snapshot.data ?? _HomeUserData.fallback();

                          if (snapshot.connectionState != ConnectionState.done) {
                            return const _HeaderLoadingCard();
                          }

                          return HeaderCard(
                            name: user.name,
                            nim: user.nim,
                            jurusan: user.jurusan,
                            prodi: user.prodi,
                          );
                        },
                      ),
                    const SizedBox(height: 16),
                    const Row(
                      children: <Widget>[
                        Expanded(
                          child: QuickActionCard(
                            icon: Icons.assignment_outlined,
                            title: 'Aduan',
                            subtitle: 'Kirim keluhan',
                            destination: AduanHubPage.routeName,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: QuickActionCard(
                            icon: Icons.record_voice_over_outlined,
                            title: 'Aspirasi',
                            subtitle: 'Lihat suara',
                            destination: null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  <Widget>[
                    const SectionTitle(
                      icon: Icons.campaign_outlined,
                      title: 'Agenda Terkini',
                    ),
                    const SizedBox(height: 14),
                    ...latestAgendas.map(
                      (AgendaItem agenda) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: AgendaCard(agenda: agenda),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const SectionTitle(
                      icon: Icons.local_fire_department_outlined,
                      title: 'Sedang Hangat Dibicarakan',
                    ),
                    const SizedBox(height: 14),
                    const PopularAgendaCard(agenda: popularAgenda),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeUserData {
  const _HomeUserData({
    required this.name,
    required this.nim,
    required this.jurusan,
    required this.prodi,
  });

  final String name;
  final String nim;
  final String jurusan;
  final String prodi;

  factory _HomeUserData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return _HomeUserData.fallback();

    String readField(List<String> keys, String fallback) {
      for (final key in keys) {
        final value = json[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
      return fallback;
    }

    return _HomeUserData(
      name: readField(<String>['name', 'nama', 'full_name'], 'Mahasiswa'),
      nim: readField(<String>['nim', 'student_id'], '-'),
      jurusan: readField(<String>['jurusan', 'faculty', 'fakultas'], '-'),
      prodi: readField(<String>['prodi', 'program_studi', 'program'], '-'),
    );
  }

  factory _HomeUserData.fallback() {
    return const _HomeUserData(
      name: 'Mahasiswa',
      nim: '-',
      jurusan: '-',
      prodi: '-',
    );
  }
}

class _HeaderLoadingCard extends StatelessWidget {
  const _HeaderLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF7F1D1D), Color(0xFFDC2626)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const SizedBox(
        height: 150,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }
}

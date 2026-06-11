import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/agenda_item.dart';
import '../widgets/agenda_card.dart';
import '../widgets/header_card.dart';
import '../widgets/popular_agenda_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/section_title.dart';
import '../services/auth_service_sanctum.dart';
import '../services/agenda_service.dart';
import '../models/agenda.dart';
import 'aduan_hub_page.dart';
import 'agenda_page.dart';
import 'aspirasi_page.dart';
import 'agenda_detail_sheet.dart';

// Top-level helpers (can't be static inside a class)
dynamic _jsonDecode(String source) {
  try {
    return jsonDecode(source);
  } catch (_) {
    return null;
  }
}

AgendaItem _mapAgenda(Map<String, dynamic> json) {
  final imgSrc = json['image_source']?.toString();
  return AgendaItem(
    id: json['id']?.toString(),
    title: json['title']?.toString() ?? 'Tanpa Judul',
    dateLabel: json['created_at']?.toString().substring(0, 10) ?? '',
    likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
    commentsCount: (json['comments_count'] as num?)?.toInt(),
    description: json['content']?.toString() ?? json['description']?.toString(),
    hasImage: imgSrc != null && imgSrc.isNotEmpty,
    imageUrl: (imgSrc != null && imgSrc.isNotEmpty)
        ? (imgSrc.startsWith('http') ? imgSrc : '${SanctumAuthService.apiBaseUrl}/storage/$imgSrc')
        : null,
    accent: const Color(0xFFDC2626),
  );
}

class HomePage extends StatefulWidget {
  static const String routeName = '/home';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<_HomeData> _homeFuture;

  @override
  void initState() {
    super.initState();
    _homeFuture = _loadHomeData();
  }

  Future<_HomeData> _loadHomeData() async {
    final service = SanctumAuthService(SanctumAuthService.apiBaseUrl);
    final user = await service.fetchUser();

    String readField(List<String> keys, String fallback) {
      if (user == null) return fallback;
      for (final key in keys) {
        final value = user[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
      return fallback;
    }

    final userData = _HomeUserData(
      name: readField(['name', 'nama', 'full_name'], 'Mahasiswa'),
      nim: readField(['nim', 'student_id'], '-'),
      jurusan: readField(['jurusan', 'faculty', 'fakultas'], '-'),
      prodi: readField(['prodi', 'program_studi', 'program'], '-'),
    );

    // Fetch latest agendas from API
    List<AgendaItem> latest = [];
    AgendaItem? popular;
    try {
      final agendaResponse = await service.getApi('/api/agenda', auth: true);
      if (agendaResponse.statusCode == 200 && agendaResponse.body.isNotEmpty) {
        final body = agendaResponse.body;
        try {
          final decoded = _jsonDecode(body);
          List<dynamic> items = [];
          if (decoded is List) {
            items = decoded;
          } else if (decoded is Map && decoded['data'] is List) {
            items = decoded['data'] as List;
          }

          latest = items
              .take(3)
              .map((e) => _mapAgenda(e as Map<String, dynamic>))
              .toList();

          // Find popular (most likes)
          if (items.isNotEmpty) {
            final sorted = List<Map<String, dynamic>>.from(
              items.map((e) => e as Map<String, dynamic>),
            );
            sorted.sort((a, b) {
              final aLikes = (a['likes_count'] as num?) ?? 0;
              final bLikes = (b['likes_count'] as num?) ?? 0;
              return bLikes.compareTo(aLikes);
            });
            popular = _mapAgenda(sorted.first);
          }
        } catch (_) {}
      }
    } catch (_) {}

    return _HomeData(
      user: userData,
      latestAgendas: latest,
      popularAgenda: popular,
    );
  }

  void _openAgendaDetail(BuildContext context, AgendaItem agendaItem) {
    if (agendaItem.id == null) return;
    // Buat Agenda sementara dari AgendaItem untuk dikirim ke sheet
    final agenda = Agenda(
      id: agendaItem.id!,
      judul: agendaItem.title,
      kategori: 'Agenda Kampus',
      deskripsi: agendaItem.description ?? '',
      imageUrl: agendaItem.imageUrl,
      tanggal: DateTime.tryParse(agendaItem.dateLabel) ?? DateTime.now(),
      likes: agendaItem.likesCount,
      comments: agendaItem.commentsCount ?? 0,
    );
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AgendaDetailSheet(
        agendaService: AgendaService(),
        agenda: agenda,
        onChanged: () async {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F2),
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            // App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFB91C1C), Color(0xFFEF4444)],
                      ).createShader(bounds),
                      child: const Text(
                        'Talkyu',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Agenda',
                          onPressed: () =>
                              Navigator.of(context).pushNamed(AgendaPage.routeName),
                          icon: const Icon(Icons.campaign_outlined,
                              color: Color(0xFF7F1D1D)),
                        ),
                        IconButton(
                          tooltip: 'Aspirasi',
                          onPressed: () =>
                              Navigator.of(context).pushNamed(AspirasiPage.routeName),
                          icon: const Icon(Icons.record_voice_over_outlined,
                              color: Color(0xFF7F1D1D)),
                        ),
                        IconButton(
                          tooltip: 'Aduan',
                          onPressed: () =>
                              Navigator.of(context).pushNamed(AduanHubPage.routeName),
                          icon: const Icon(Icons.assignment_outlined,
                              color: Color(0xFF7F1D1D)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Content: Header + Quick Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: FutureBuilder<_HomeData>(
                  future: _homeFuture,
                  builder: (context, snapshot) {
                    final data = snapshot.data ?? _HomeData.fallback();

                    if (snapshot.connectionState != ConnectionState.done) {
                      return const _LoadingCard();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HeaderCard(
                          name: data.user.name,
                          nim: data.user.nim,
                          jurusan: data.user.jurusan,
                          prodi: data.user.prodi,
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
                                destination: AspirasiPage.routeName,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // Dashboard: Latest Agendas + Popular
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: SliverToBoxAdapter(
                child: FutureBuilder<_HomeData>(
                  future: _homeFuture,
                  builder: (context, snapshot) {
                    final data = snapshot.data ?? _HomeData.fallback();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(
                          icon: Icons.campaign_outlined,
                          title: 'Agenda Terkini',
                        ),
                        const SizedBox(height: 14),
                        if (data.latestAgendas.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color:
                                    const Color(0xFFDC2626).withOpacity(0.1),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Belum ada agenda terbaru.',
                                style: TextStyle(
                                  color:
                                      const Color(0xFF7F1D1D).withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          )
                        else
                          ...data.latestAgendas.map(
                            (agenda) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: AgendaCard(
                                agenda: agenda,
                                onTap: () => _openAgendaDetail(context, agenda),
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                        if (data.popularAgenda != null) ...[
                          const SectionTitle(
                            icon: Icons.local_fire_department_outlined,
                            title: 'Sedang Hangat Dibicarakan',
                          ),
                          const SizedBox(height: 14),
                          PopularAgendaCard(
                            agenda: data.popularAgenda!,
                            onTap: () => _openAgendaDetail(context, data.popularAgenda!),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeData {
  const _HomeData({
    required this.user,
    required this.latestAgendas,
    this.popularAgenda,
  });

  final _HomeUserData user;
  final List<AgendaItem> latestAgendas;
  final AgendaItem? popularAgenda;

  factory _HomeData.fallback() {
    return _HomeData(
      user: _HomeUserData.fallback(),
      latestAgendas: const [],
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

  factory _HomeUserData.fallback() {
    return const _HomeUserData(
      name: 'Mahasiswa',
      nim: '-',
      jurusan: '-',
      prodi: '-',
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFDC2626).withOpacity(0.12),
        ),
      ),
      child: const SizedBox(
        height: 180,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC2626)),
          ),
        ),
      ),
    );
  }
}

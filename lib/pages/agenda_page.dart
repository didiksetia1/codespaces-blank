import 'package:flutter/material.dart';

import '../models/agenda.dart';
import '../services/agenda_service.dart';
import '../widgets/agenda_list_card.dart';
import '../widgets/agenda_states.dart';
import 'agenda_detail_sheet.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  static const String routeName = '/agenda';

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  final AgendaService _agendaService = AgendaService();
  late Future<List<Agenda>> _agendaFuture;

  @override
  void initState() {
    super.initState();
    _agendaFuture = _loadAgendas();
  }

  Future<List<Agenda>> _loadAgendas() async {
    return _agendaService.fetchAgendas();
  }

  Future<void> _refreshAgendas() async {
    setState(() {
      _agendaFuture = _loadAgendas();
    });
    await _agendaFuture;
  }

  void _openDetail(Agenda agenda) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AgendaDetailSheet(
        agendaService: _agendaService,
        agenda: agenda,
        onChanged: _refreshAgendas,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        backgroundColor: const Color(0xFFFDF2F2),
        surfaceTintColor: const Color(0xFFFDF2F2),
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Agenda>>(
          future: _agendaFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFC41C1C)),
                ),
              );
            }

            if (snapshot.hasError) {
              return ErrorState(
                message: snapshot.error.toString(),
                onRetry: _refreshAgendas,
              );
            }

            final agendas = snapshot.data ?? <Agenda>[];

            if (agendas.isEmpty) {
              return EmptyState(onRetry: _refreshAgendas);
            }

            return RefreshIndicator(
              onRefresh: _refreshAgendas,
              color: const Color(0xFFC41C1C),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: <Widget>[
                  const Text(
                    'Agenda & Berita',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF7F1D1D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Jelajahi informasi acara dan berita terbaru seputar kampus.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8A4A4A),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...agendas.map(
                    (agenda) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: AgendaListCard(
                        agenda: agenda,
                        onTap: () => _openDetail(agenda),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}


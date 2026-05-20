import 'package:flutter/material.dart';

import '../widgets/hub_choice_card.dart';
import 'aduan_create_page.dart';
import 'aduan_history_page.dart';
import 'home_page.dart';

class AduanHubPage extends StatelessWidget {
  const AduanHubPage({super.key});

  static const String routeName = '/aduan';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aduan'),
        backgroundColor: const Color(0xFFFDF2F2),
        surfaceTintColor: const Color(0xFFFDF2F2),
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Home',
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const HomePage(),
              ),
            ),
            icon: const Icon(Icons.home_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xFFB91C1C), Color(0xFF7F1D1D)],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Pusat Layanan Pengaduan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pilih menu di bawah ini untuk membuat aduan baru atau mengecek status aduan Anda.',
                    style: TextStyle(
                      color: Color(0xFFFDE8E8),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool wide = constraints.maxWidth >= 760;

                final List<Widget> cards = <Widget>[
                  Expanded(
                    child: HubChoiceCard(
                      icon: Icons.add,
                      title: 'Buat Aduan Baru',
                      description:
                          'Sampaikan keluhan, kritik, atau saran terkait perkuliahan dan administrasi akademik.',
                      onTap: () => Navigator.of(context).pushNamed(AduanCreatePage.routeName),
                    ),
                  ),
                  const SizedBox(width: 18, height: 18),
                  Expanded(
                    child: HubChoiceCard(
                      icon: Icons.access_time,
                      title: 'Riwayat Aduan Saya',
                      description:
                          'Pantau status perkembangan dan penyelesaian dari aduan-aduan yang telah Anda kirimkan.',
                      onTap: () => Navigator.of(context).pushNamed(AduanHistoryPage.routeName),
                    ),
                  ),
                ];

                if (wide) {
                  return Row(children: cards);
                }

                return Column(
                  children: <Widget>[
                    cards[0],
                    const SizedBox(height: 18),
                    cards[2],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

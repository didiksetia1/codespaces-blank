import 'package:flutter/material.dart';

import 'pages/aduan_create_page.dart';
import 'pages/aduan_history_page.dart';
import 'pages/aduan_hub_page.dart';
import 'pages/agenda_page.dart';
import 'pages/aspirasi_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/aspirasi_detail_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final String previewPage = Uri.base.queryParameters['page'] ?? '';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Talkyu',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB91C1C),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFDF2F2),
      ),
      home: switch (previewPage) {
        'login' => const LoginPage(),
        'register' => const RegisterPage(),
        'aduan' => const AduanHubPage(),
        'aduan-baru' => const AduanCreatePage(),
        'aduan-riwayat' => const AduanHistoryPage(),
        'agenda' => const AgendaPage(),
        'aspirasi' => const AspirasiPage(),
        'home' => const HomePage(),
        _ => const LoginPage(),
      },
      routes: <String, WidgetBuilder>{
        LoginPage.routeName: (BuildContext context) => const LoginPage(),
        HomePage.routeName: (BuildContext context) => const HomePage(),
        RegisterPage.routeName: (BuildContext context) => const RegisterPage(),
        AduanHubPage.routeName: (BuildContext context) => const AduanHubPage(),
        AduanCreatePage.routeName: (BuildContext context) => const AduanCreatePage(),
        AduanHistoryPage.routeName: (BuildContext context) => const AduanHistoryPage(),
        AgendaPage.routeName: (BuildContext context) => const AgendaPage(),
        AspirasiPage.routeName: (BuildContext context) => const AspirasiPage(),
        AspirasiDetailPage.routeName: (BuildContext context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return AspirasiDetailPage(aspirasiId: args);
        },
      },
    );
  }
}

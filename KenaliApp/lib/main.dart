import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

// Import semua layar yang digunakan
import 'screens/intro_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_page.dart';
import 'screens/detail_prediksi.dart';
import 'screens/menu_prediksi.dart'; // Pastikan path-nya sesuai
import 'screens/riwayat_prediksi.dart'; // Pastikan path-nya sesuai

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const KenaliApp());
}

class KenaliApp extends StatelessWidget {
  const KenaliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/', // Mulai dari onboarding screen
      routes: {
        '/': (context) => const IntroScreen(), // Pastikan class ini sudah benar
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfilePage(),
        '/detail_prediksi': (context) => const DetailPrediksi(),
        '/menu_prediksi': (context) => const MenuPrediksi(), // Tambahkan route untuk MenuPrediksi
        '/riwayat_prediksi': (context) => const RiwayatPrediksi(), // Tambahkan route untuk RiwayatPrediksi
      },
    );
  }
}
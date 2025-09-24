import 'package:flutter/material.dart';
import 'package:kenali_app/screens/profile_page.dart';
// atau nama file yang benar

void main() {
  runApp(const KenaliApp());
}

class KenaliApp extends StatelessWidget {
  const KenaliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const MenuBeranda(),
        '/profile': (context) => const ProfilePage(),
        '/detail_prediksi': (context) => const DetailPrediksi(),
        // '/detail_transaksi': (context) => const DetailTransaksi(),
      },
    );
  }
}

class MenuBeranda extends StatelessWidget {
  const MenuBeranda({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Beranda'),
        backgroundColor: const Color(0xFF67DCA8),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuItem(
            context,
            title: 'Prediksi 1',
            subtitle: 'Berisi hasil prediksi yang telah dilakukan',
            icon: Icons.analytics,
            routeName: '/detail_prediksi',
          ),
          const SizedBox(height: 16),
          _buildMenuItem(
            context,
            title: 'Prediksi 2',
            subtitle: 'Berisi hasil untuk prediksi kedua',
            icon: Icons.bar_chart,
            routeName: '/detail_transaksi',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String routeName,
  }) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, routeName),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFF67DCA8),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 14, color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.black54, size: 16),
          ],
        ),
      ),
    );
  }
}

class DetailPrediksi extends StatelessWidget {
  const DetailPrediksi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Prediksi'),
        backgroundColor: const Color(0xFF67DCA8),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Detail Prediksi'),
                content: const Text('Apakah Anda ingin melihat profil pengguna?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/profile');
                    },
                    child: const Text('Lihat Profil'),
                  ),
                ],
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF67DCA8),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            'Detail Prediksi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class DetailTransaksi extends StatelessWidget {
  const DetailTransaksi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        backgroundColor: const Color(0xFF67DCA8),
      ),
      body: const Center(
        child: Text(
          'Halaman Detail Transaksi',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

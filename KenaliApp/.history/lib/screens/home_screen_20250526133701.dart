import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import HTTP package
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel_slider;

import 'menu_prediksi.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _username = 'Pengguna';
  final carousel_slider.CarouselSliderController _controller = carousel_slider.CarouselSliderController();
  int _currentArticleIndex = 0;
  
  // List untuk menyimpan artikel
  List<Map<String, dynamic>> newsList = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchArticles(); // Ambil artikel saat inisialisasi
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      setState(() {
        _username = userData['name'] ?? 'Pengguna';
      });
    }
  }

  Future<void> _fetchArticles() async {
    try {
      final response = await http.post(Uri.parse('http://127.0.0.1:8000/api/artikel')); // Ganti URL sesuai
      if (response.statusCode == 200) {
        final List<dynamic> articles = jsonDecode(response.body)['data'];
        setState(() {
          newsList = articles.take(5).map((article) {
            return {
              "title": article['judul'],
              "description": article['deskripsi'],
              "url": article['sumber'],
            };
          }).toList();
        });
      } else {
        print('Gagal mengambil artikel: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildRealTimeClock() {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        final now = DateTime.now();
        final time = DateFormat.Hm().format(now);
        final date = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(now);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              date,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetectionCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MenuPrediksi()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Deteksi Dini Stroke',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A9A9E),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Ketahui risiko stroke Anda dengan melakukan deteksi dini',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF67DCA8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'KLIK DISINI UNTUK MEMULAI DETEKSI',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> news) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi tentang Stroke',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 150, // Atur tinggi sesuai kebutuhan
            child: ListView.builder(
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                final news = newsList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF67DCA8),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      "• ${news['title']}",
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                    onTap: () => _showNewsDialog(news['title']!, news['url']!),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Revisi: klik icon Dashboard sekarang ke RiwayatPrediksi
  void _onNavTapped(int index) {
    if (index == 1) return;
    if (index == 0) {
      Navigator.pushNamed(context, '/riwayat_prediksi');
    } else if (index == 2) {
      Navigator.pushNamed(context, '/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF67DCA8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF2A9A9E),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Selamat Datang,\n$_username',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildRealTimeClock(),
                ],
              ),
              const SizedBox(height: 25),
              _buildDetectionCard(),
              const SizedBox(height: 25),
              _buildNewsCarousel(), // Menampilkan carousel artikel
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF64D2A3),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 1,
        onTap: _onNavTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}

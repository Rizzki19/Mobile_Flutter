import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart' as carousel_slider;
import 'package:fl_chart/fl_chart.dart';

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
  List<Map<String, dynamic>> newsList = [];
  Map<int, int> detectionData = {};
  String? _userId;
  bool isLoading = true; // Indikator loading
  String? errorMessage; // Pesan error jika API gagal

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchArticles();
    _fetchDetectionData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      if (mounted) {
        setState(() {
          _username = userData['name'] ?? 'Pengguna';
          _userId = userData['id']?.toString();
        });
      }
    }
  }

  Future<void> _fetchArticles() async {
    try {
      final response = await http
          .post(Uri.parse('http://127.0.0.1:8000/api/artikel'))
          .timeout(const Duration(seconds: 10)); // Timeout 10 detik
      if (mounted) {
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
          setState(() {
            errorMessage = 'Gagal mengambil artikel: ${response.statusCode}';
          });
          print('Gagal mengambil artikel: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error mengambil artikel: $e';
        });
        print('Error: $e');
      }
    }
  }

  Future<void> _fetchDetectionData() async {
    if (_userId == null) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'User ID tidak tersedia';
        });
      }
      return;
    }

    try {
      final response = await http
          .post(
            Uri.parse('http://127.0.0.1:8000/api/deteksi_per_bulan'),
            body: {'user_id': _userId},
          )
          .timeout(const Duration(seconds: 10)); // Timeout 10 detik

      if (mounted) {
        setState(() {
          isLoading = false;
        });
        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          print('Response detection data: $responseData'); // Debugging
          if (responseData['status'] == 'success') {
            final Map<String, dynamic> data = responseData['data'];
            setState(() {
              detectionData = {
                for (var entry in data.entries) int.parse(entry.key): entry.value
              };
            });
          } else {
            setState(() {
              errorMessage = responseData['message'] ?? 'Gagal mengambil data deteksi';
            });
          }
        } else {
          setState(() {
            errorMessage = 'Gagal mengambil data deteksi: ${response.statusCode}';
          });
          print('Gagal mengambil data deteksi: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Error mengambil data deteksi: $e';
        });
        print('Error fetching detection data: $e');
      }
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              news['title'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              news['description'] ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _launchURL(news['url'] ?? ''),
              child: const Text(
                'Baca Selengkapnya',
                style: TextStyle(color: Color(0xFF2A9A9E)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsCarousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            'Artikel Kesehatan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        carousel_slider.CarouselSlider(
          carouselController: _controller,
          options: carousel_slider.CarouselOptions(
            height: 280,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.8,
            onPageChanged: (index, reason) {
              if (mounted) {
                setState(() {
                  _currentArticleIndex = index;
                });
              }
            },
          ),
          items: newsList.map((news) => _buildNewsCard(news)).toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: newsList.asMap().entries.map((entry) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentArticleIndex == entry.key
                    ? Colors.white
                    : Colors.white.withOpacity(0.4),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDetectionChart() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 14),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8, top: 20, bottom: 8),
          child: Text(
            'Jumlah Deteksi Per Bulan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
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
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (detectionData.values.isNotEmpty
                      ? detectionData.values.reduce((a, b) => a > b ? a : b)
                      : 10)
                  .toDouble(),
              barGroups: List.generate(12, (index) {
                final month = index + 1;
                final count = detectionData[month]?.toDouble() ?? 0;
                return BarChartGroupData(
                  x: month,
                  barRods: [
                    BarChartRodData(
                      toY: count,
                      color: const Color(0xFF2A9A9E),
                      width: 15,
                    ),
                  ],
                );
              }),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      const months = [
                        'Jan',
                        'Feb',
                        'Mar',
                        'Apr',
                        'Mei',
                        'Jun',
                        'Jul',
                        'Agu',
                        'Sep',
                        'Okt',
                        'Nov',
                        'Des'
                      ];
                      return Text(
                        months[value.toInt() - 1],
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ],
    );
  }

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
              _buildNewsCarousel(),
              const SizedBox(height: 25),
              _buildDetectionChart(),
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
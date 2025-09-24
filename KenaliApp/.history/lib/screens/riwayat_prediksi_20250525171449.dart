import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RiwayatPrediksi extends StatefulWidget {
  const RiwayatPrediksi({super.key});

  @override
  State<RiwayatPrediksi> createState() => _RiwayatPrediksiState();
}

class _RiwayatPrediksiState extends State<RiwayatPrediksi> {
  late String currentTime;
  late String currentDate;
  late Timer timer;
  String? userId;
  String? userName;
  List<dynamic> riwayatList = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateDateTime());
    _loadUserData();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    final timeFormat = DateFormat('HH:mm');
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
    setState(() {
      currentTime = timeFormat.format(now);
      currentDate = dateFormat.format(now);
    });
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        setState(() {
          userId = userData['id'];
          userName = userData['name'];
        });
        _fetchRiwayatDeteksi();
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> _fetchRiwayatDeteksi() async {
    if (userId == null) return;

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/riwayat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          riwayatList = responseData['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  void _showDetailDialog(dynamic item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detail Riwayat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hasil Deteksi: ${item['prediction']}'),
            Text('Tanggal: ${DateFormat('dd MMMM yyyy HH:mm', 'id_ID').format(DateTime.parse(item['created_at']))}'),
            Text('Usia: ${item['age']} tahun'),
            Text('Jenis Kelamin: ${item['gender']}'),
            Text('Hipertensi: ${item['hypertension']}'),
            Text('Penyakit Jantung: ${item['heart_disease']}'),
            Text('Status Menikah: ${item['ever_married']}'),
            Text('Pekerjaan: ${item['work_type']}'),
            Text('Tinggal: ${item['Residence_type']}'),
            Text('Gula Darah: ${item['avg_glucose_level']}'),
            Text('BMI: ${item['bmi']}'),
            Text('Merokok: ${item['smoking_status']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2FDF6),
      body: SafeArea(
        child: Column(
          children: [
            HeaderSection(
              currentTime: currentTime,
              currentDate: currentDate,
              userName: userName ?? 'User Kenali',
            ),
            InfoBox(predictionCount: riwayatList.length),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : hasError
                      ? const Center(child: Text('Gagal memuat data'))
                      : riwayatList.isEmpty
                          ? const Center(child: Text('Tidak ada riwayat ditemukan'))
                          : _buildRiwayatList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF45BF8C),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 1,
        onTap: _onNavTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildRiwayatList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: riwayatList.length,
      itemBuilder: (context, index) {
        final item = riwayatList[index];
        return GestureDetector(
          onTap: () => _showDetailDialog(item),
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hasil: ${item['prediction']}',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tanggal: ${DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(DateTime.parse(item['created_at']))}',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Usia: ${item['age']} tahun',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onNavTapped(int index) {
    switch (index) {
      case 1:
        Navigator.pushNamed(context, '/home');
        break;
      case 2:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }
}

class HeaderSection extends StatelessWidget {
  final String currentTime;
  final String currentDate;
  final String userName;

  const HeaderSection({
    super.key,
    required this.currentTime,
    required this.currentDate,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF45BF8C),
            radius: 24,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Selamat Datang,\n$userName',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currentTime,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                ),
              ),
              Text(
                currentDate,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InfoBox extends StatelessWidget {
  final int predictionCount;

  const InfoBox({super.key, required this.predictionCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDCF2EA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'Prediksi Dibuat: $predictionCount',
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
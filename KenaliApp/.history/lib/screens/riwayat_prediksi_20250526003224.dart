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

  bool _isRiskyPrediction(String? prediction) {
    if (prediction == null) return false;
    return prediction.toLowerCase().contains('anda beresiko terkena stroke');
  }

  bool _isSafePrediction(String? prediction) {
    if (prediction == null) return false;
    return prediction.toLowerCase().contains('anda tidak beresiko');
  }

  Widget _buildPredictionResult(String? prediction) {
    final isRisky = _isRiskyPrediction(prediction);
    final isSafe = _isSafePrediction(prediction);
    
    Color textColor = Colors.black;
    Color bgColor = Colors.grey[200]!;
    IconData icon = Icons.help_outline;

    if (isRisky) {
      textColor = Colors.red;
      bgColor = const Color(0xFFFFEBEE);
      icon = Icons.warning;
    } else if (isSafe) {
      textColor = Colors.green;
      bgColor = const Color(0xFFE8F5E9);
      icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Hasil Deteksi: ${prediction ?? 'Tidak ada hasil'}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDetailRiwayat(BuildContext context, dynamic data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Detail Riwayat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF45BF8C),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const Divider(thickness: 1),
                    const SizedBox(height: 10),
                    
                    _buildPredictionResult(data['prediction']?.toString()),
                    
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: [
                        _buildDetailItem('Tanggal', DateFormat('dd MMM yyyy HH:mm', 'id_ID').format(DateTime.parse(data['created_at']))),
                        _buildDetailItem('Usia', '${data['age']?.toString() ?? '-'} tahun'),
                        _buildDetailItem('Jenis Kelamin', _mapGender(data['sex'])),
                        _buildDetailItem('Hipertensi', _mapBool(data['hypertension'])),
                        _buildDetailItem('Riwayat Penyakit Jantung', _mapBool(data['heart_disease'])),
                        _buildDetailItem('Status Menikah', _mapBool(data['ever_married'])),
                        _buildDetailItem('Pekerjaan', _mapWorkType(data['work_type'])),
                        _buildDetailItem('Area Tinggal', _mapResidence(data['Residence_type'])),
                        _buildDetailItem('Gula Darah', data['avg_glucose_level']?.toString() ?? '-'),
                        _buildDetailItem('BMI', data['bmi']?.toString() ?? '-'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFF45BF8C),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Tutup',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11, // Ukuran font diperkecil
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13, // Ukuran font diperkecil
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
                          ? const Center(
                              child: Text('Tidak ada riwayat ditemukan'))
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
          BottomNavigationBarItem(
            icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(
            icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Profil'),
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
        final prediction = item['prediction']?.toString();
        final isRisky = _isRiskyPrediction(prediction);
        final isSafe = _isSafePrediction(prediction);
        
        Color textColor = Colors.black;
        Color iconColor = Colors.grey;
        IconData icon = Icons.help_outline;

        if (isRisky) {
          textColor = Colors.red;
          iconColor = Colors.red;
          icon = Icons.warning;
        } else if (isSafe) {
          textColor = Colors.green;
          iconColor = Colors.green;
          icon = Icons.check_circle;
        }

        return GestureDetector(
          onTap: () => _showDetailRiwayat(context, item),
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
                  Row(
                    children: [
                      Icon(icon, color: iconColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Hasil: ${prediction ?? 'Tidak ada hasil'}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
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
                    'Usia: ${item['age']?.toString() ?? '-'} tahun',
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

  String _mapGender(dynamic gender) {
  if (gender == null) return '-';
  if (gender.toString() == '1') return 'Laki-laki';
  if (gender.toString() == '0') return 'Perempuan';
  switch (gender.toString().toLowerCase()) {
    case 'male': return 'Laki-laki';
    case 'female': return 'Perempuan';
    default: return gender.toString();
  }
}

  String _mapBool(dynamic value) {
    if (value == null) return '-';
    if (value is bool) return value ? 'Ya' : 'Tidak';
    if (value.toString() == '1' || value.toString().toLowerCase() == 'yes' || value.toString().toLowerCase() == 'true') {
      return 'Ya';
    }
    if (value.toString() == '0' || value.toString().toLowerCase() == 'no' || value.toString().toLowerCase() == 'false') {
      return 'Tidak';
    }
    return value.toString();
  }

  String _mapWorkType(dynamic workType) {
  if (workType == null) return '-';
  switch (workType.toString()) {
    case '0': return 'Tidak Bekerja';
    case '1': return 'Anak-anak';
    case '2': return 'PNS';
    case '3': return 'Wiraswasta';
    default:
      switch (workType.toString().toLowerCase()) {
        case 'private': return 'Swasta';
        case 'self-employed': return 'Wiraswasta';
        case 'children': return 'Anak-anak';
        case 'govt_job': return 'PNS';
        case 'never_worked': return 'Belum Pernah Bekerja';
        default: return workType.toString();
      }
  }
}

  String _mapResidence(dynamic residence) {
  if (residence == null) return '-';
  if (residence.toString() == '1') return 'Perkotaan';
  if (residence.toString() == '0') return 'Pedesaan';
  switch (residence.toString().toLowerCase()) {
    case 'urban': return 'Perkotaan';
    case 'rural': return 'Pedesaan';
    default: return residence.toString();
  }
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
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'editable_dropdown_field.dart';
import 'home_screen.dart';

class MenuPrediksi extends StatefulWidget {
  const MenuPrediksi({super.key});

  @override
  State<MenuPrediksi> createState() => _MenuPrediksiState();
}

class _MenuPrediksiState extends State<MenuPrediksi> {
  final TextEditingController usiaController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();
  final TextEditingController gulaDarahController = TextEditingController();

  String genderValue = '';
  String hipertensiValue = '';
  String jantungValue = '';
  String menikahValue = '';
  String pekerjaanValue = '';
  String areaValue = '';
  String rokokValue = '';

  bool isLoading = false;

  bool _isNumberValid(String val) {
    if (val.isEmpty) return false;
    final number = num.tryParse(val);
    return number != null;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  int _mapWorkType(String val) {
    switch (val) {
      case 'tidak bekerja':
        return 0;
      case 'anak-anak':
        return 1;
      case 'PNS':
        return 2;
      case 'wiraswasta':
        return 3;
      default:
        return 0;
    }
  }

  int _mapResidence(String val) {
    return val == 'perkotaan' ? 1 : 0;
  }

  int _mapBool(String val) {
    return val == 'iya' ? 1 : 0;
  }

  void _resetForm() {
    setState(() {
      usiaController.clear();
      bmiController.clear();
      gulaDarahController.clear();
      genderValue = '';
      hipertensiValue = '';
      jantungValue = '';
      menikahValue = '';
      pekerjaanValue = '';
      areaValue = '';
      rokokValue = '';
    });
  }

  Future<void> _validateAndConfirm() async {
    final usia = usiaController.text.trim();
    final bmi = bmiController.text.trim();
    final gula = gulaDarahController.text.trim();

    if ([usia, bmi, gula, genderValue, hipertensiValue, jantungValue, menikahValue, pekerjaanValue, areaValue, rokokValue].contains('') ||
        [usia, bmi, gula].any((v) => !_isNumberValid(v))) {
      _showSnackBar('Mohon isi semua data dengan benar!');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi'),
        content: const Text('Apakah data sudah sesuai untuk dilakukan deteksi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Tidak')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya')),
        ],
      ),
    );

    if (confirm == true) _performDetection();
  }

  Future<void> _performDetection() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Sedang Mendeteksi...'),
          ],
        ),
      ),
    );

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = jsonDecode(prefs.getString('user_data') ?? '{}');
      final userId = userData['id'];

      final body = {
        'user_id': userId,
        'sex': genderValue == 'laki-laki' ? 1 : 0,
        'age': double.parse(usiaController.text),
        'hypertension': _mapBool(hipertensiValue),
        'heart_disease': _mapBool(jantungValue),
        'ever_married': _mapBool(menikahValue),
        'work_type': _mapWorkType(pekerjaanValue),
        'Residence_type': _mapResidence(areaValue),
        'avg_glucose_level': double.parse(gulaDarahController.text),
        'bmi': double.parse(bmiController.text),
        'smoking_status': _mapBool(rokokValue),
      };

      final response = await http.post(
        Uri.parse('http://localhost:5000/api/predict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      final result = jsonDecode(response.body);
      if (response.statusCode == 200 && result['status'] == 'success') {
        _showResultDialog(result['prediction']);
        _showSnackBar('Deteksi berhasil!');
      } else {
        _showSnackBar(result['message'] ?? 'Terjadi kesalahan!');
      }
    } catch (_) {
      _showSnackBar('Gagal terhubung ke server.');
    } finally {
      Navigator.pop(context); // Tutup dialog setelah selesai
      setState(() => isLoading = false);
    }
  }

  void _showResultDialog(String result) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hasil Prediksi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(result, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetForm();
            },
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  // Menampilkan pop-up panduan
  void _showGuideDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.blue, size: 24),
            SizedBox(width: 8),
            Text(
              'Panduan Untuk Pengisian Data Deteksi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              // Tempat pengisian panduan
              Text(
                '1. Pastikan semua data yang dimasukkan benar dan sesuai dengan kondisi Anda.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              SizedBox(height: 8),
              Text(
                '2. Jika ada pertanyaan, hubungi tim support kami.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              // Tambahkan panduan lain di sini jika diperlukan
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Mengerti',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF67DCA8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          ),
        ),
        title: const Text(
          'Menu Prediksi',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          Tooltip(
            message: 'Mohon baca panduan sebelum melakukan Deteksi',
            child: IconButton(
              icon: const Icon(
                Icons.info_outline,
                color: Colors.black,
                size: 24,
              ),
              onPressed: _showGuideDialog,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8.0, bottom: 15.0),
              child: Text(
                'Lengkapi Data Anda',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 24.0, bottom: 0),
              child: Text(
                'Jenis kelamin',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 12.0),
              child: DropdownOnlyField(
                label: '',
                value: genderValue,
                options: ['perempuan', 'laki-laki'],
                onChanged: (val) => setState(() => genderValue = val ?? ''),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 4.0, bottom: 0),
              child: Text(
                'Usia',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 12.0),
              child: TextField(
                controller: usiaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Masukkan usia Anda',
                  border: UnderlineInputBorder(),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 4.0, bottom: 0),
              child: Text(
                'Hipertensi',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 12.0),
              child: DropdownOnlyField(
                label: '',
                value: hipertensiValue,
                options: ['tidak', 'iya'],
                onChanged: (val) => setState(() => hipertensiValue = val ?? ''),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 4.0, bottom: 0),
              child: Text(
                'Kadar gula darah',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 12.0),
              child: TextField(
                controller: gulaDarahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Masukkan kadar gula darah',
                  border: UnderlineInputBorder(),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 4.0, bottom: 0),
              child: Text(
                'Riwayat Penyakit jantung',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 0, bottom: 12.0),
              child: DropdownOnlyField(
                label: '',
                value: jantungValue,
                options: ['tidak', 'iya'],
                onChanged: (val) => setState(() => jantungValue = val ?? ''),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 4.0, bottom: 0),
              child: Text(
                'BMI',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 12.0),
              child: TextField(
                controller: bmiController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Masukkan BMI',
                  border: UnderlineInputBorder(),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 4.0, bottom: 0),
              child: Text(
                'Status menikah',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 12.0),
              child: DropdownOnlyField(
                label: '',
                value: menikahValue,
                options: ['tidak', 'iya'],
                onChanged: (val) => setState(() => menikahValue = val ?? ''),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 4.0, bottom: 0),
              child: Text(
                'Pekerjaan',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 12.0),
              child: DropdownOnlyField(
                label: '',
                value: pekerjaanValue,
                options: ['tidak bekerja', 'anak-anak', 'PNS', 'wiraswasta'],
                onChanged: (val) => setState(() => pekerjaanValue = val ?? ''),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 4.0, bottom: 0),
              child: Text(
                'Area tinggal',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 12.0),
              child: DropdownOnlyField(
                label: '',
                value: areaValue,
                options: ['pedesaan', 'perkotaan'],
                onChanged: (val) => setState(() => areaValue = val ?? ''),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 4.0, bottom: 0),
              child: Text(
                'Perokok',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 12.0),
              child: DropdownOnlyField(
                label: '',
                value: rokokValue,
                options: ['tidak', 'iya'],
                onChanged: (val) => setState(() => rokokValue = val ?? ''),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF67DCA8),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isLoading ? null : _validateAndConfirm,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Deteksi',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
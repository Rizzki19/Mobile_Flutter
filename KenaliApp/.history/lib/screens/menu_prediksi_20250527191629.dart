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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lengkapi Data Anda',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Jenis kelamin',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 8),
            DropdownOnlyField(
              label: '',
              value: genderValue,
              options: ['perempuan', 'laki-laki'],
              onChanged: (val) => setState(() => genderValue = val ?? ''),
            ),
            const SizedBox(height: 8),
            const Text(
              'Usia',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: usiaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Masukkan usia Anda',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hipertensi',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 8),
            DropdownOnlyField(
              label: '',
              value: hipertensiValue,
              options: ['tidak', 'iya'],
              onChanged: (val) => setState(() => hipertensiValue = val ?? ''),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kadar gula darah',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: gulaDarahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Masukkan kadar gula darah',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Riwayat Penyakit jantung',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 8),
            DropdownOnlyField(
              label: '',
              value: jantungValue,
              options: ['tidak', 'iya'],
              onChanged: (val) => setState(() => jantungValue = val ?? ''),
            ),
            const SizedBox(height: 8),
            const Text(
              'BMI',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: bmiController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Masukkan BMI',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Status menikah',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 8),
            DropdownOnlyField(
              label: '',
              value: menikahValue,
              options: ['tidak', 'iya'],
              onChanged: (val) => setState(() => menikahValue = val ?? ''),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pekerjaan',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 8),
            DropdownOnlyField(
              label: '',
              value: pekerjaanValue,
              options: ['tidak bekerja', 'anak-anak', 'PNS', 'wiraswasta'],
              onChanged: (val) => setState(() => pekerjaanValue = val ?? ''),
            ),
            const SizedBox(height: 8),
            const Text(
              'Area tinggal',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 8),
            DropdownOnlyField(
              label: '',
              value: areaValue,
              options: ['pedesaan', 'perkotaan'],
              onChanged: (val) => setState(() => areaValue = val ?? ''),
            ),
            const SizedBox(height: 8),
            const Text(
              'Perokok',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 8),
            DropdownOnlyField(
              label: '',
              value: rokokValue,
              options: ['tidak', 'iya'],
              onChanged: (val) => setState(() => rokokValue = val ?? ''),
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
                child: Text(
                  isLoading ? 'Memproses...' : 'Lakukan Deteksi',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Import yang diperlukan
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

  Future<void> _validateAndConfirm() async {
    final usia = usiaController.text.trim();
    final bmi = bmiController.text.trim();
    final gula = gulaDarahController.text.trim();

    if ([
          usia,
          bmi,
          gula,
          genderValue,
          hipertensiValue,
          jantungValue,
          menikahValue,
          pekerjaanValue,
          areaValue,
          rokokValue
        ].contains('') ||
        [usia, bmi, gula].any((v) => !_isNumberValid(v))) {
      _showSnackBar('Mohon isi semua data dengan benar!');
      return;
    }

    final confirm = await showDialog<bool>(
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Konfirmasi'),
        content: Text('Apakah data sudah sesuai untuk dilakukan deteksi?'),
      builder: (_) => AlertDialog(
        title: Text('Konfirmasi'),
        content: Text('Apakah data sudah sesuai untuk dilakukan deteksi?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Tidak')),
          TextButton(
              onPressed: () => Navigator.pop(context, true), child: Text('Ya')),
        ],
      ),
    );

    if (confirm == true) _performDetection();
    if (confirm == true) _performDetection();
  }

  Future<void> _performDetection() async {
    setState(() {
      isLoading = true;
    });

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

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/predict'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
        body: json.encode(body),
      );

      final result = jsonDecode(response.body);
      if (response.statusCode == 200 && result['status'] == 'success') {
        _showResultDialog(result['prediction']);
        _showSnackBar('Deteksi berhasil!');
      final result = jsonDecode(response.body);
      if (response.statusCode == 200 && result['status'] == 'success') {
        _showResultDialog(result['prediction']);
        _showSnackBar('Deteksi berhasil!');
      } else {
        _showSnackBar(result['message'] ?? 'Terjadi kesalahan!');
        _showSnackBar(result['message'] ?? 'Terjadi kesalahan!');
      }
    } catch (e) {
      _showSnackBar('Gagal terhubung ke server.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showResultDialog(String result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hasil Prediksi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          result,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showResultDialog(String result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hasil Prediksi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          result,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _customCardInput({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8FDF2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6DE39D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          ),
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          ),
        ),
        title: const Text('Prediksi Dini',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Lengkapi Data Anda',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _customCardInput(
                  child: DropdownOnlyField(
                      label: 'Jenis kelamin',
                      value: genderValue,
                      options: ['perempuan', 'laki-laki'],
                      onChanged: (val) =>
                          setState(() => genderValue = val ?? ''))),
              _customCardInput(
                  child: TextField(
                      controller: usiaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Usia', border: InputBorder.none))),
              _customCardInput(
                  child: DropdownOnlyField(
                      label: 'Hipertensi',
                      value: hipertensiValue,
                      options: ['tidak', 'iya'],
                      onChanged: (val) =>
                          setState(() => hipertensiValue = val ?? ''))),
              _customCardInput(
                  child: TextField(
                      controller: gulaDarahController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Kadar gula darah',
                          border: InputBorder.none))),
              _customCardInput(
                  child: DropdownOnlyField(
                      label: 'Penyakit jantung',
                      value: jantungValue,
                      options: ['tidak', 'iya'],
                      onChanged: (val) =>
                          setState(() => jantungValue = val ?? ''))),
              _customCardInput(
                  child: TextField(
                      controller: bmiController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'BMI', border: InputBorder.none))),
              _customCardInput(
                  child: DropdownOnlyField(
                      label: 'Status menikah',
                      value: menikahValue,
                      options: ['tidak', 'iya'],
                      onChanged: (val) =>
                          setState(() => menikahValue = val ?? ''))),
              _customCardInput(
                  child: DropdownOnlyField(
                      label: 'Pekerjaan',
                      value: pekerjaanValue,
                      options: [
                        'tidak bekerja',
                        'anak-anak',
                        'PNS',
                        'wiraswasta'
                      ],
                      onChanged: (val) =>
                          setState(() => pekerjaanValue = val ?? ''))),
              _customCardInput(
                  child: DropdownOnlyField(
                      label: 'Area tinggal',
                      value: areaValue,
                      options: ['pedesaan', 'perkotaan'],
                      onChanged: (val) =>
                          setState(() => areaValue = val ?? ''))),
              _customCardInput(
                  child: DropdownOnlyField(
                      label: 'Perokok',
                      value: rokokValue,
                      options: ['tidak', 'iya'],
                      onChanged: (val) =>
                          setState(() => rokokValue = val ?? ''))),
              const SizedBox(height: 24),
              Center(
                child: isLoading
                    ? const CircularProgressIndicator()
                    : GestureDetector(
                        onTap: _validateAndConfirm,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 80, vertical: 18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF6DE39D), Color(0xFF48C78E)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.4),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Prediksi',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              if (predictionResult.isNotEmpty)
                Center(
                  child: Text(
                    'Hasil: $predictionResult',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

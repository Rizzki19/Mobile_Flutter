import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'login_screen.dart';

void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = jsonDecode(prefs.getString('user_data') ?? '{}');
    setState(() {
      _nameController.text = userData['name'] ?? 'User Kenali';
      _emailController.text = userData['email'] ?? 'UserKenali@gmail.com';
      _genderController.text = userData['jenis_kelamin'] ?? 'Laki-laki';
      _birthDateController.text = userData['tanggal_lahir'] ?? '2000-01-20';
      _phoneController.text = userData['no_telepon'] ?? '081234569887';
      _addressController.text = userData['alamat'] ?? 'Jl. Polije';
    });
  }

  Future<void> _saveProfileData() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = jsonDecode(prefs.getString('user_data') ?? '{}');
      final userId = userData['id'];

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/update-profile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'jenis_kelamin': _genderController.text.trim(),
          'tanggal_lahir': _birthDateController.text.trim(),
          'no_telepon': _phoneController.text.trim(),
          'alamat': _addressController.text.trim(),
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['success']) {
        await prefs.setString('user_data', jsonEncode(responseData['user']));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Informasi pengguna berhasil diperbarui')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? 'Gagal memperbarui profil')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _savePassword() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    if (_newPasswordController.text == _confirmPasswordController.text) {
      // Implementasi update password ke server di sini (misalnya endpoint /update-password)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil diperbarui')),
        );
      }
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password baru dan konfirmasi tidak cocok')),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _onNavTapped(int index) {
    if (index == 0) {
      Navigator.pushNamed(context, '/riwayat_prediksi');
    } else if (index == 1) {
      Navigator.pushNamed(context, '/home');
    }
    // Index 2 is Profil, which is the current page, so no action needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFB1F2BC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selamat Datang,',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _nameController.text.isEmpty ? 'Nama Pengguna' : _nameController.text,
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Informasi Pengguna',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              _buildEditableProfileItem(title: 'Nama Lengkap', controller: _nameController, hintText: 'Masukkan nama lengkap Anda'),
              _buildEditableProfileItem(title: 'Email', controller: _emailController, hintText: 'Masukkan email Anda', enabled: false),
              _buildEditableProfileItem(title: 'Jenis Kelamin', controller: _genderController, hintText: 'Masukkan jenis kelamin Anda'),
              _buildEditableProfileItem(title: 'Tanggal Lahir', controller: _birthDateController, hintText: 'Masukkan tanggal lahir Anda (YYYY-MM-DD)'),
              _buildEditableProfileItem(title: 'Nomor Telepon', controller: _phoneController, hintText: 'Masukkan nomor telepon Anda'),
              _buildEditableProfileItem(title: 'Alamat', controller: _addressController, hintText: 'Masukkan alamat Anda'),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfileData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0400FF),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Update Informasi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Ubah Password',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              _buildEditableProfileItem(
                title: 'Password Lama',
                controller: _oldPasswordController,
                hintText: 'Masukkan password lama Anda',
                obscureText: true,
              ),
              _buildEditableProfileItem(
                title: 'Password Baru',
                controller: _newPasswordController,
                hintText: 'Masukkan password baru Anda',
                obscureText: true,
              ),
              _buildEditableProfileItem(
                title: 'Konfirmasi Password Baru',
                controller: _confirmPasswordController,
                hintText: 'Konfirmasi password baru Anda',
                obscureText: true,
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0400FF),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Update Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Keluar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Keluar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF64D2A3),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: 2,
        onTap: _onNavTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildEditableProfileItem({
    required String title,
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    bool enabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: obscureText,
            enabled: enabled,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: const Color(0xFFD9D9D9),
            ),
          ),
        ],
      ),
    );
  }
}
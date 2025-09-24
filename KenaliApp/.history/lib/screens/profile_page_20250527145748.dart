import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? 'Admin Kenali';
      _emailController.text = prefs.getString('email') ?? 'AdminKenali@gmail.com';
      _genderController.text = prefs.getString('gender') ?? 'Laki-laki';
      _birthDateController.text = prefs.getString('birth_date') ?? '2000-01-09';
      _phoneController.text = prefs.getString('phone') ?? '081234567888';
      _addressController.text = prefs.getString('address') ?? 'Jl. Polije';
    });
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text.trim());
    await prefs.setString('email', _emailController.text.trim());
    await prefs.setString('gender', _genderController.text.trim());
    await prefs.setString('birth_date', _birthDateController.text.trim());
    await prefs.setString('phone', _phoneController.text.trim());
    await prefs.setString('address', _addressController.text.trim());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Informasi pengguna berhasil diperbarui')),
    );
  }

  Future<void> _savePassword() async {
    if (_newPasswordController.text == _confirmPasswordController.text) {
      // Here you would typically verify the old password and update the new one
      // For this example, we'll just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil diperbarui')),
      );
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password baru dan konfirmasi tidak cocok')),
      );
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _onNavTapped(int index) {
    if (index == 0) {
      Navigator.pushNamed(context, '/riwayat_prediksi');
    }
    // Index 1 is Profil, which is the current page, so no action needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: const Color(0xFF67DCA8),
      ),
      body: Padding(
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
                onPressed: _saveProfileData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0400FF),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Update Informasi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
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
                onPressed: _savePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0400FF),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Update Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
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
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Keluar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
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
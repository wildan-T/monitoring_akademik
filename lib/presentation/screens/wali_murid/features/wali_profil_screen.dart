import 'package:flutter/material.dart';
import '../../../../core/constants/color_constants.dart';

class WaliProfilScreen extends StatelessWidget {
  final Map<String, dynamic> siswa;

  const WaliProfilScreen({super.key, required this.siswa});

  @override
  Widget build(BuildContext context) {
    // Helper untuk null safety
    String val(String key) => siswa[key]?.toString() ?? '-';
    final kelasData = siswa['kelas'];
    final waliData = siswa['wali_murid'];
    final profileData = waliData?['profiles'];

    final String kelas = kelasData?['nama_kelas'] ?? '-';
    final String waliNama = waliData?['nama_lengkap'] ?? '-';
    final String waliJK = waliData?['jenis_kelamin'] ?? '-';
    final String waliPekerjaan = waliData?['pekerjaan'] ?? '-';
    final String waliAlamat = waliData?['alamat'] ?? '-';
    final String waliHubungan = waliData?['hubungan'] ?? '-';
    final String waliTelp = profileData?['no_telepon'] ?? '-';
    final String waliEmail = profileData?['email'] ?? '-';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Anak"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              val('nama_lengkap'),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              "Kelas $kelas",
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            _itemInfo(Icons.badge, "NISN", val('nisn')),
            _itemInfo(
              Icons.wc,
              "Jenis Kelamin",
              val('jenis_kelamin') == 'L' ? 'Laki-laki' : 'Perempuan',
            ),
            _itemInfo(
              Icons.cake,
              "Tempat, Tgl Lahir",
              "${val('tempat_lahir')}, ${val('tanggal_lahir')}",
            ),
            _itemInfo(Icons.mosque, "Agama", val('agama')),
            _itemInfo(Icons.person, "Nama Ayah", val('nama_ayah')),
            _itemInfo(Icons.person_2, "Nama Ibu", val('nama_ibu')),
            _itemInfo(Icons.home, "Alamat", val('alamat')),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Data Wali",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blue,
                ),
              ),
            ),
            _itemInfo(Icons.family_restroom, "Nama Wali", waliNama),
            _itemInfo(
              Icons.wc,
              "Jenis Kelamin",
              waliJK == 'L' ? 'Laki-laki' : 'Perempuan',
            ),
            _itemInfo(Icons.work, "Pekerjaan", waliPekerjaan),
            _itemInfo(Icons.people, "Hubungan", waliHubungan),
            _itemInfo(Icons.home, "Alamat", waliAlamat),
            _itemInfo(Icons.phone, "No. HP", waliTelp),
            _itemInfo(Icons.email, "Email", waliEmail),
          ],
        ),
      ),
    );
  }

  Widget _itemInfo(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

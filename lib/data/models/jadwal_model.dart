import 'package:flutter/material.dart';

class JadwalModel {
  final String id;
  final String guruId;
  final String namaGuru;
  final String kelasId;
  final String namaKelas;
  final String mapelId;
  final String namaMapel;
  final String hari;
  final String jamMulai;
  final String jamSelesai;

  JadwalModel({
    required this.id,
    required this.guruId,
    required this.namaGuru,
    required this.kelasId,
    required this.namaKelas,
    required this.mapelId,
    required this.namaMapel,
    required this.hari,
    required this.jamMulai,
    required this.jamSelesai,
  });

  factory JadwalModel.fromJson(Map<String, dynamic> json) {
    return JadwalModel(
      id: json['id'] ?? '',
      guruId: json['guru_id'] ?? '',
      // Ambil dari relasi tabel guru
      namaGuru: json['guru']?['nama_lengkap'] ?? 'Guru Tidak Ditemukan',
      kelasId: json['kelas_id'] ?? '',
      // Ambil dari relasi tabel kelas
      namaKelas: json['kelas']?['nama_kelas'] ?? '-',
      mapelId: json['mapel_id'] ?? '',
      // Ambil dari relasi tabel mapel
      namaMapel: json['mapel']?['nama_mapel'] ?? '-',
      hari: json['hari'] ?? '',
      jamMulai: json['jam_mulai'] ?? '',
      jamSelesai: json['jam_selesai'] ?? '',
    );
  }
}

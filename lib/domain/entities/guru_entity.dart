//C:\Users\MSITHIN\monitoring_akademik\lib\domain\entities\guru_entity.dart
import 'package:equatable/equatable.dart';

class GuruEntity extends Equatable {
  final String id;
  final String nuptk;
  final String nama;
  final String? nip;
  final String? email;
  final String? noTelp;
  final String? alamat;
  final String? pendidikanTerakhir;
  final bool isWaliKelas;
  final String? waliKelas;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GuruEntity({
    required this.id,
    required this.nuptk,
    required this.nama,
    this.nip,
    this.email,
    this.noTelp,
    this.alamat,
    this.pendidikanTerakhir,
    this.isWaliKelas = false,
    this.waliKelas,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        nuptk,
        nama,
        nip,
        email,
        noTelp,
        alamat,
        pendidikanTerakhir,
        isWaliKelas,
        waliKelas,
        createdAt,
        updatedAt,
      ];

  GuruEntity copyWith({
    String? id,
    String? nuptk,
    String? nama,
    String? nip,
    String? email,
    String? noTelp,
    String? alamat,
    String? pendidikanTerakhir,
    bool? isWaliKelas,
    String? waliKelas,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GuruEntity(
      id: id ?? this.id,
      nuptk: nuptk ?? this.nuptk,
      nama: nama ?? this.nama,
      nip: nip ?? this.nip,
      email: email ?? this.email,
      noTelp: noTelp ?? this.noTelp,
      alamat: alamat ?? this.alamat,
      pendidikanTerakhir: pendidikanTerakhir ?? this.pendidikanTerakhir,
      isWaliKelas: isWaliKelas ?? this.isWaliKelas,
      waliKelas: waliKelas ?? this.waliKelas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
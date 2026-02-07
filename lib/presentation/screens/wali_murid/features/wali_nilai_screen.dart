import 'package:flutter/material.dart';
import 'package:monitoring_akademik/presentation/providers/sekolah_provider.dart';
import 'package:printing/printing.dart'; // Wajib install package printing
import 'package:provider/provider.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../data/models/siswa_model.dart';
import '../../../../data/services/rapor_pdf_service.dart';
import '../../../../data/services/supabase_service.dart';
import '../../../providers/tahun_pelajaran_provider.dart';

class WaliNilaiScreen extends StatefulWidget {
  final Map<String, dynamic> siswaData;

  const WaliNilaiScreen({super.key, required this.siswaData});

  @override
  State<WaliNilaiScreen> createState() => _WaliNilaiScreenState();
}

class _WaliNilaiScreenState extends State<WaliNilaiScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _nilaiList = [];

  String _namaWaliKelas = '';
  String _nipWaliKelas = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    try {
      final tahunProv = context.read<TahunPelajaranProvider>();
      // Pastikan tahun pelajaran sudah terload
      if (tahunProv.tahunList.isEmpty) await tahunProv.fetchTahunPelajaran();

      final tahunAktif = tahunProv.tahunList.firstWhere(
        (t) => t.isActive,
        orElse: () => tahunProv.tahunList.first, // Fallback
      );
      final sekolahProv = context.read<SekolahProvider>();
      await sekolahProv.fetchSekolahData();

      // 1. Ambil Nilai Siswa
      final dataNilai = await SupabaseService().getNilaiRaporSiswa(
        widget.siswaData['id'],
        tahunAktif.id,
      );

      // 2. ✅ AMBIL DATA WALI KELAS
      // Cek apakah siswa punya kelas_id
      if (widget.siswaData['kelas_id'] != null) {
        final dataGuru = await SupabaseService().getWaliKelasByKelasId(
          widget.siswaData['kelas_id'],
        );

        if (dataGuru != null) {
          setState(() {
            _namaWaliKelas = dataGuru['nama_lengkap'] ?? '';
            _nipWaliKelas = dataGuru['nip'] ?? '';
          });
        }
      }

      if (mounted) {
        setState(() {
          _nilaiList = dataNilai;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error load data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _printRapor() async {
    // Tampilkan Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final tahunProv = context.read<TahunPelajaranProvider>();
      final tahunAktif = tahunProv.tahunList.firstWhere((t) => t.isActive);
      final sekolahProv = context.read<SekolahProvider>();
      final alamat = sekolahProv.sekolahData?.alamat ?? "";

      final siswaModel = SiswaModel(
        id: widget.siswaData['id'],
        nama: widget.siswaData['nama_lengkap'],
        nisn: widget.siswaData['nisn'] ?? '-',
        kelasId: widget.siswaData['kelas_id'] ?? '',
        jenisKelamin: widget.siswaData['jenis_kelamin'] ?? 'L',
      );

      String namaKelas = widget.siswaData['kelas'] != null
          ? widget.siswaData['kelas']['nama_kelas']
          : '-';

      final pdfBytes = await RaporPdfService().generateRapor(
        siswa: siswaModel,
        namaKelas: namaKelas,
        tahunAjaran: tahunAktif.tahun.toString(),
        semester: tahunAktif.semester.toString(),
        namaWaliKelas: _namaWaliKelas,
        nipWaliKelas: _nipWaliKelas,
        alamatSekolah: alamat,
        listNilaiRaw: _nilaiList,
      );

      if (mounted) {
        Navigator.pop(context);
        await Printing.layoutPdf(
          onLayout: (_) async => pdfBytes,
          name: 'Rapor-${siswaModel.nama}.pdf',
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Tutup dialog jika error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal print: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nilai Akademik"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading || _nilaiList.isEmpty ? null : _printRapor,
        label: const Text("Cetak Rapor"),
        icon: const Icon(Icons.print),
        backgroundColor: Colors.green,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _nilaiList.isEmpty
          ? const Center(child: Text("Belum ada data nilai"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _nilaiList.length,
              itemBuilder: (context, index) {
                final item = _nilaiList[index];
                final mapel =
                    item['mata_pelajaran']?['nama_mapel'] ?? 'Mapel ?';
                final nilaiAkhir = item['nilai_akhir'] ?? 0;

                return Card(
                  child: ListTile(
                    title: Text(
                      mapel,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: nilaiAkhir < 75
                            ? Colors.red.shade100
                            : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        nilaiAkhir.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: nilaiAkhir < 75 ? Colors.red : Colors.green,
                        ),
                      ),
                    ),
                    subtitle: Text(
                      "Tugas: ${item['nilai_tugas'] ?? '-'} | UTS: ${item['nilai_uts'] ?? '-'} | UAS: ${item['nilai_uas'] ?? '-'}",
                    ),
                  ),
                );
              },
            ),
    );
  }
}

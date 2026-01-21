import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadNilai();
  }

  Future<void> _loadNilai() async {
    try {
      final tahunProv = context.read<TahunPelajaranProvider>();
      final tahunAktif = tahunProv.tahunList.firstWhere((t) => t.isActive);

      final data = await SupabaseService().getNilaiRaporSiswa(
        widget.siswaData['id'],
        tahunAktif.id,
      );

      if (mounted)
        setState(() {
          _nilaiList = data;
          _isLoading = false;
        });
    } catch (e) {
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

      // Convert Map ke Model Siswa (Manual mapping simpel)
      final siswaModel = SiswaModel(
        id: widget.siswaData['id'],
        nama: widget.siswaData['nama_lengkap'],
        nisn: widget.siswaData['nisn'] ?? '-',
        kelasId: widget.siswaData['kelas_id'] ?? '',
        // ... field lain opsional untuk PDF
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
        namaWaliKelas: "Wali Kelas", // Bisa diambil jika query diperluas
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
      Navigator.pop(context);
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

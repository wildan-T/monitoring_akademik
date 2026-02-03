import 'package:flutter/material.dart';
import 'package:monitoring_akademik/core/utils/nilai_converter.dart';
import 'package:monitoring_akademik/presentation/providers/guru_provider.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/nilai_provider.dart';
import '../../../../data/models/nilai_model.dart';
import '../../../../data/models/siswa_model.dart';

class GuruNilaiInputScreen extends StatefulWidget {
  final String kelasId;
  final String mapelId;
  final String mapelNama;
  final String tahunId;
  final String kategoriMapel;

  const GuruNilaiInputScreen({
    super.key,
    required this.kelasId,
    required this.mapelId,
    required this.mapelNama,
    required this.tahunId,
    required this.kategoriMapel,
  });

  @override
  State<GuruNilaiInputScreen> createState() => _GuruNilaiInputScreenState();
}

class _GuruNilaiInputScreenState extends State<GuruNilaiInputScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<NilaiProvider>().fetchInputList(
        kelasId: widget.kelasId,
        mapelId: widget.mapelId,
        tahunId: widget.tahunId,
      ),
    );
  }

  // Menampilkan Form Input
  void _showInputForm(
    BuildContext context,
    SiswaModel siswa,
    NilaiModel? existingNilai,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(
            ctx,
          ).viewInsets.bottom, // Agar tidak tertutup keyboard
          left: 16,
          right: 16,
          top: 16,
        ),
        child: _FormNilaiWidget(
          siswa: siswa,
          nilaiAwal: existingNilai,
          kelasId: widget.kelasId,
          mapelId: widget.mapelId,
          tahunId: widget.tahunId,
          kategoriMapel: widget.kategoriMapel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Nilai: ${widget.mapelNama}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<NilaiProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading)
            return const Center(child: CircularProgressIndicator());

          if (provider.inputList.isEmpty) {
            return const Center(child: Text('Tidak ada siswa di kelas ini'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.inputList.length,
            itemBuilder: (context, index) {
              final item = provider.inputList[index];
              final sudahDinilai = item.nilai != null;

              // Tampilan Subtitle beda Akademik vs Ekskul
              String subtitleText = 'Belum ada nilai';
              if (sudahDinilai) {
                if (widget.kategoriMapel == 'Ekstrakulikuler') {
                  // Tampilkan Predikat untuk Ekskul
                  final predikat = NilaiConverter.angkaToPredikat(
                    item.nilai!.nilaiAkhir ?? 0,
                  );
                  subtitleText = 'Predikat: $predikat';
                } else {
                  // Tampilkan Angka untuk Akademik
                  subtitleText = 'Nilai Akhir: ${item.nilai!.nilaiAkhir}';
                }
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: sudahDinilai
                        ? Colors.green.shade100
                        : Colors.grey.shade200,
                    child: Icon(
                      sudahDinilai ? Icons.check : Icons.edit,
                      color: sudahDinilai ? Colors.green : Colors.grey,
                    ),
                  ),
                  title: Text(
                    item.siswa.nama,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    sudahDinilai
                        ? 'Nilai Akhir: ${item.nilai?.nilaiAkhir ?? 0} | Ketrampilan/Praktik: ${item.nilai?.nilaiPraktik ?? 0}'
                        : 'Belum ada nilai',
                    style: TextStyle(color: alreadyColor(sudahDinilai)),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    if (item.nilai?.isFinalized == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Nilai sudah difinalisasi, tidak bisa diedit.',
                          ),
                        ),
                      );
                      return;
                    }
                    _showInputForm(context, item.siswa, item.nilai);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color alreadyColor(bool val) =>
      val ? Colors.green.shade700 : Colors.red.shade400;
}

// ==========================================
// 📝 WIDGET FORM INPUT (MODAL)
// ==========================================
class _FormNilaiWidget extends StatefulWidget {
  final SiswaModel siswa;
  final NilaiModel? nilaiAwal;
  final String kelasId;
  final String mapelId;
  final String tahunId;
  final String kategoriMapel;

  const _FormNilaiWidget({
    required this.siswa,
    this.nilaiAwal,
    required this.kelasId,
    required this.mapelId,
    required this.tahunId,
    required this.kategoriMapel,
  });

  @override
  State<_FormNilaiWidget> createState() => _FormNilaiWidgetState();
}

class _FormNilaiWidgetState extends State<_FormNilaiWidget> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _tugasCtrl;
  late TextEditingController _uhCtrl;
  late TextEditingController _utsCtrl;
  late TextEditingController _uasCtrl;
  late TextEditingController _praktikCtrl;
  String _selectedPredikat = 'B';
  String? _selectedSikap;
  bool _isSaving = false;
  double _previewNilai = 0;

  @override
  void initState() {
    super.initState();
    final n = widget.nilaiAwal;
    _tugasCtrl = TextEditingController(text: n?.nilaiTugas?.toString() ?? '0');
    _uhCtrl = TextEditingController(text: n?.nilaiUh?.toString() ?? '0');
    _utsCtrl = TextEditingController(text: n?.nilaiUts?.toString() ?? '0');
    _uasCtrl = TextEditingController(text: n?.nilaiUas?.toString() ?? '0');
    _praktikCtrl = TextEditingController(
      text: n?.nilaiPraktik?.toString() ?? '0',
    );
    _selectedSikap = n?.nilaiSikap ?? 'B';
    if (widget.kategoriMapel == 'Ekstrakulikuler' && n != null) {
      _selectedPredikat = NilaiConverter.angkaToPredikat(n.nilaiAkhir ?? 0);
    }
    _hitungNilaiAkhir();
  }

  // ==================================================
  // 🧮 LOGIC MENGHITUNG NILAI AKHIR
  // ==================================================
  double _hitungNilaiAkhir() {
    double nilaiAkhir = 0;

    if (widget.kategoriMapel == 'Ekstrakulikuler') {
      // KONVERSI EKSKUL (Huruf -> Angka)
      nilaiAkhir = NilaiConverter.predikatToAngka(_selectedPredikat);
    } else {
      // 1. Ambil nilai dari controller (default 0 jika kosong)
      double tugas = double.tryParse(_tugasCtrl.text) ?? 0;
      double uh = double.tryParse(_uhCtrl.text) ?? 0;
      double uts = double.tryParse(_utsCtrl.text) ?? 0;
      double uas = double.tryParse(_uasCtrl.text) ?? 0;
      double praktik = double.tryParse(_praktikCtrl.text) ?? 0;

      // --- OPSI 1: RATA-RATA SEDERHANA (Semua bobot sama) ---
      // return (tugas + uh + uts + uas) / 4;

      // --- OPSI 2: PEMBOBOTAN STANDAR (Contoh Umum) ---
      // Nilai Harian (Rata2 Tugas & UH) = 20%
      // Nilai Praktik = 20%
      // Nilai UTS = 30%
      // Nilai UAS = 30%

      double nilaiHarian = (tugas + uh) / 2;

      // Rumus: (Harian * 20%) + (Praktik * 20%) + (UTS * 30%) + (UAS * 30%)
      nilaiAkhir =
          (nilaiHarian * 0.20) + (praktik * 0.20) + (uts * 0.30) + (uas * 0.30);
    }
    setState(() => _previewNilai = nilaiAkhir); // Update UI Preview
    // Pembulatan 2 angka di belakang koma agar rapi
    return double.parse(nilaiAkhir.toStringAsFixed(2));
  }

  // Update fungsi _save untuk menggunakan _hitungNilaiAkhir
  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final guruProv = context.read<GuruProvider>();

    // Pastikan data guru sudah terload (biasanya sudah di dashboard)
    if (guruProv.currentGuru == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data Guru tidak ditemukan. Silakan relogin.'),
        ),
      );
      setState(() => _isSaving = false);
      return;
    }

    final isEkskul = widget.kategoriMapel == 'Ekstrakulikuler';
    final guruId = guruProv.currentGuru!.id;

    // Buat Objek Nilai Baru
    final newNilai = NilaiModel(
      id: widget.nilaiAwal?.id ?? '',
      siswaId: widget.siswa.id,
      mataPelajaranId: widget.mapelId,
      tahunPelajaranId: widget.tahunId,
      kelasId: widget.kelasId,
      guruId: guruId,

      nilaiTugas: isEkskul ? 0 : double.tryParse(_tugasCtrl.text) ?? 0,
      nilaiUh: isEkskul ? 0 : double.tryParse(_uhCtrl.text) ?? 0,
      nilaiUts: isEkskul ? 0 : double.tryParse(_utsCtrl.text) ?? 0,
      nilaiUas: isEkskul ? 0 : double.tryParse(_uasCtrl.text) ?? 0,
      nilaiPraktik: isEkskul ? 0 : double.tryParse(_praktikCtrl.text) ?? 0,

      // ✅ HITUNG OTOMATIS DI SINI
      nilaiAkhir: _hitungNilaiAkhir(),

      nilaiSikap: isEkskul ? null : _selectedSikap,
      isFinalized: false,
    );

    final success = await context.read<NilaiProvider>().submitNilai(newNilai);

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        Navigator.pop(context); // Tutup Modal
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Nilai tersimpan!')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal menyimpan nilai')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEkskul = widget.kategoriMapel == 'Ekstrakulikuler';

    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // 85% layar
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.siswa.nama,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  // ==========================================
                  // 🟡 FORM EKSKUL
                  // ==========================================
                  if (isEkskul) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Penilaian Ekstrakulikuler menggunakan Predikat.",
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    DropdownButtonFormField<String>(
                      value: _selectedPredikat,
                      decoration: const InputDecoration(
                        labelText: "Predikat Nilai",
                        border: OutlineInputBorder(),
                      ),
                      items: ['A', 'B', 'C', 'D']
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                "$e - ${NilaiConverter.getKeteranganDefault(e)}",
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() => _selectedPredikat = val!);
                        _hitungNilaiAkhir();
                      },
                    ),
                  ],

                  // ==========================================
                  // 🔵 FORM AKADEMIK
                  // ==========================================
                  if (!isEkskul) ...[
                    const Text(
                      'Nilai Pengetahuan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildNumField('Tugas', _tugasCtrl)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildNumField('UH (Harian)', _uhCtrl)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _buildNumField('UTS', _utsCtrl)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildNumField('UAS', _uasCtrl)),
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Keterampilan & Sikap',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildNumField('Praktik / Keterampilan', _praktikCtrl),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Nilai Sikap',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedSikap,
                      items: ['A', 'B', 'C', 'D']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _selectedSikap = val),
                    ),
                  ],
                ],
              ),
            ),
            // PREVIEW NILAI AKHIR
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Hasil Akhir:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isEkskul
                        ? _selectedPredikat
                        : _previewNilai.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isEkskul
                          ? Colors.blue
                          : (_previewNilai >= 75 ? Colors.green : Colors.red),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'SIMPAN NILAI',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNumField(String label, TextEditingController ctrl) {
    return TextFormField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (val) => _hitungNilaiAkhir(), // Auto Recalculate
      validator: (val) {
        if (val == null || val.isEmpty) return 'Wajib';
        final n = double.tryParse(val);
        if (n == null || n < 0 || n > 100) return 'Valid 0-100';
        return null;
      },
    );
  }
}

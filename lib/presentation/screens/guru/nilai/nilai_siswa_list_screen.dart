// //C:\Users\MSITHIN\monitoring_akademik\lib\presentation\screens\guru\nilai\nilai_siswa_list_screen.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../providers/siswa_provider.dart';
// import '../../../providers/nilai_provider.dart';
// import '../../../providers/auth_provider.dart';
// import '../../../../data/models/siswa_model.dart';
// import '../../../../data/models/nilai_model.dart';
// import 'nilai_input_screen.dart';

// class NilaiSiswaListScreen extends StatefulWidget {
//   final String kelas;
//   final String mataPelajaran;

//   const NilaiSiswaListScreen({
//     super.key,
//     required this.kelas,
//     required this.mataPelajaran,
//   });

//   @override
//   State<NilaiSiswaListScreen> createState() => _NilaiSiswaListScreenState();
// }

// class _NilaiSiswaListScreenState extends State<NilaiSiswaListScreen> {
//   String _searchQuery = '';

//   // ✅ ADD: Load nilai saat init
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<NilaiProvider>().fetchNilaiByKelasAndMapel(
//         kelasId: widget.kelas,
//         mataPelajaranId: widget.mataPelajaran,
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final siswaProvider = Provider.of<SiswaProvider>(context);
//     final nilaiProvider = Provider.of<NilaiProvider>(context);

//     // Filter siswa by kelas
//     // final siswaList =
//     //     siswaProvider.siswaList
//     //         .where((siswa) => siswa.kelas == widget.kelas)
//     //         .toList();

//     // Filter by search
//     // final filteredSiswa =
//     //     siswaList.where((siswa) {
//     //       final query = _searchQuery.toLowerCase();
//     //       return siswa.nama.toLowerCase().contains(query) ||
//     //           siswa.nisn.toLowerCase().contains(query) ||
//     //           siswa.nis.toLowerCase().contains(query);
//     //     }).toList();

//     return Scaffold(
//       appBar: AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Input Nilai'),
//             Text(
//               'Kelas ${widget.kelas} - ${widget.mataPelajaran}',
//               style: const TextStyle(fontSize: 12),
//             ),
//           ],
//         ),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//       ),
//       body: Column(
//         children: [
//           // Search Bar
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: TextField(
//               onChanged: (value) {
//                 setState(() {
//                   _searchQuery = value;
//                 });
//               },
//               decoration: InputDecoration(
//                 hintText: 'Cari siswa (nama, NIS, NISN)...',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[100],
//               ),
//             ),
//           ),

//           // Statistik
//           _buildStatistikCard(nilaiProvider),

//           // List Siswa
//           // Expanded(
//           //   child:
//           //       filteredSiswa.isEmpty
//           //           ? _buildEmptyState()
//           //           : ListView.builder(
//           //             padding: const EdgeInsets.all(16),
//           //             itemCount: filteredSiswa.length,
//           //             itemBuilder: (context, index) {
//           //               final siswa = filteredSiswa[index];
//           //               final nilai = nilaiProvider.nilaiList
//           //                   .cast<NilaiModel?>()
//           //                   .firstWhere(
//           //                     (n) => n?.siswaId == siswa.id,
//           //                     orElse: () => null,
//           //                   );

//           //               return _buildSiswaCard(context, siswa, nilai);
//           //             },
//           //           ),
//           // ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatistikCard(NilaiProvider nilaiProvider) {
//     final statistik = nilaiProvider.getStatistik(
//       kelas: widget.kelas,
//       mataPelajaran: widget.mataPelajaran,
//     );

//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.blue.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildStatItem(
//             'Total Siswa',
//             statistik['total_siswa'].toString(),
//             Colors.blue,
//           ),
//           _buildStatItem(
//             'Sudah Dinilai',
//             statistik['sudah_dinilai'].toString(),
//             Colors.green,
//           ),
//           _buildStatItem(
//             'Rata-rata',
//             statistik['rata_rata'].toStringAsFixed(1),
//             Colors.orange,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatItem(String label, String value, Color color) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
//       ],
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
//           const SizedBox(height: 16),
//           Text(
//             'Tidak ada siswa ditemukan',
//             style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSiswaCard(
//     BuildContext context,
//     SiswaModel siswa,
//     NilaiModel? nilai,
//   ) {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => NilaiInputScreen(
//                 siswa: [siswa],
//                 kelas: widget.kelas,
//                 mataPelajaran: widget.mataPelajaran,
//                 guruId: authProvider.currentUser?.id ?? '',
//               ),
//             ),
//           );
//         },
//         borderRadius: BorderRadius.circular(12),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               // Avatar
//               CircleAvatar(
//                 backgroundColor: siswa.jenisKelamin == 'L'
//                     ? Colors.blue.withOpacity(0.1)
//                     : Colors.pink.withOpacity(0.1),
//                 radius: 28,
//                 child: Text(
//                   siswa.nama.substring(0, 1).toUpperCase(),
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: siswa.jenisKelamin == 'L'
//                         ? Colors.blue
//                         : Colors.pink,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),

//               // Info Siswa
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       siswa.nama,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'NIS: ${siswa.nis} • NISN: ${siswa.nisn}',
//                       style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                     ),
//                   ],
//                 ),
//               ),

//               // Nilai Badge
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   if (nilai != null && nilai.nilaiAkhir != null) ...[
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: _getColorByNilai(
//                           nilai.nilaiAkhir!,
//                         ).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: Text(
//                         nilai.nilaiAkhir!.toStringAsFixed(1),
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: _getColorByNilai(nilai.nilaiAkhir!),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       nilai.nilaiHuruf ?? '-',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.grey[600],
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ] else ...[
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: const Text(
//                         'Belum Dinilai',
//                         style: TextStyle(fontSize: 12, color: Colors.grey),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//               const SizedBox(width: 8),
//               const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Color _getColorByNilai(double nilai) {
//     if (nilai >= 90) return Colors.green;
//     if (nilai >= 80) return Colors.blue;
//     if (nilai >= 70) return Colors.orange;
//     if (nilai >= 60) return Colors.deepOrange;
//     return Colors.red;
//   }
// }

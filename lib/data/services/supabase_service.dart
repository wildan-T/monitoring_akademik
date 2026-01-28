//C:\Users\MSITHIN\monitoring_akademik\lib\data\services\supabase_service.dart
import 'package:monitoring_akademik/data/models/guru_model.dart';
import 'package:monitoring_akademik/data/models/nilai_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
//import '../models/guru_model.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ✅ TAMBAHKAN GETTER INI:
  SupabaseClient get supabase => _supabase;

  // ========================================
  // 🔐 USER MANAGEMENT (ADMIN)
  // ========================================

  /// Ambil semua user dari tabel Profiles
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      // Kita ambil profiles dan join ke tabel spesifik untuk detailnya
      // Gunakan left join manual logic atau fetch terpisah
      final response = await _supabase
          .from('profiles')
          .select('*')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  /// Update Akun User via Edge Function
  Future<void> updateUserAccount({
    required String userId,
    String? email,
    String? password,
    Map<String, dynamic>? metadata, // Isi: nama, no_telepon, pekerjaan, alamat
  }) async {
    final response = await _supabase.functions.invoke(
      'manage-user',
      body: {
        'action': 'update',
        'user_id': userId,
        'email': email,
        'password': password,
        'data': metadata,
      },
    );

    if (response.status != 200) {
      throw Exception(response.data['error'] ?? 'Gagal update user');
    }
  }

  /// Hapus User Total via Edge Function
  Future<void> deleteUserPermanent(String userId) async {
    final response = await _supabase.functions.invoke(
      'manage-user',
      body: {'action': 'delete', 'user_id': userId},
    );

    if (response.status != 200) {
      throw Exception(response.data['error'] ?? 'Gagal hapus user');
    }
  }

  /// Helper: Ambil Detail Wali Murid berdasarkan Profile ID
  Future<Map<String, dynamic>?> getWaliDetail(String profileId) async {
    return await _supabase
        .from('wali_murid')
        .select()
        .eq('profile_id', profileId)
        .maybeSingle();
  }

  // ========================================
  // 🔐 AUTHENTICATION METHODS
  // ========================================

  /// Sign in dengan EMAIL saja
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Login Auth
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Login gagal');
      }

      final userId = authResponse.user!.id;

      // 2. Ambil data dasar dari Profiles
      final profileData = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      String role = profileData['role'];
      String namaLengkap =
          profileData['nama_lengkap'] ?? ''; // Default dari profiles

      // 3. 🔄 LOGIKA BARU: Cek Role & Ambil Nama dari Tabel Spesifik
      if (role == 'guru') {
        final guruData = await _supabase
            .from('guru')
            .select('nama_lengkap') // Ambil kolom nama_lengkap dari tabel guru
            .eq(
              'profile_id',
              userId,
            ) // Pastikan relasinya benar (profile_id atau id)
            .maybeSingle(); // Pakai maybeSingle agar tidak error jika data belum ada

        if (guruData != null && guruData['nama_lengkap'] != null) {
          namaLengkap = guruData['nama_lengkap'];
        }
      } else if (role == 'wali_murid') {
        // Asumsi tabel wali_murid strukturnya mirip
        final waliData = await _supabase
            .from('wali_murid')
            .select('nama_lengkap')
            .eq('profile_id', userId)
            .maybeSingle();

        if (waliData != null) {
          namaLengkap = waliData['nama_lengkap'];
        }
      }

      // 4. Update nama di objek JSON sebelum dikonversi ke Model
      // Kita manipulasi map-nya agar UserModel menerima nama yang paling update
      final updatedProfileData = Map<String, dynamic>.from(profileData);
      updatedProfileData['nama_lengkap'] = namaLengkap;

      return UserModel.fromJson(updatedProfileData);
    } catch (e) {
      print('❌ Error signInWithEmail: $e');
      rethrow;
    }
  }

  /// Sign in dengan username ATAU email
  // Future<UserModel?> signInWithUsernameOrEmail({
  //   required String usernameOrEmail,
  //   required String password,
  // }) async {
  //   try {
  //     String email = usernameOrEmail;

  //     // ✅ Jika bukan email, cari email dari username
  //     if (!usernameOrEmail.contains('@')) {
  //       final response = await _supabase
  //           .from('profiles')
  //           .select('email')
  //           .eq('username', usernameOrEmail)
  //           .maybeSingle();

  //       if (response == null) {
  //         throw Exception('Username tidak ditemukan');
  //       }

  //       email = response['email'] as String;
  //     }

  //     // ✅ Login dengan email
  //     final authResponse = await _supabase.auth.signInWithPassword(
  //       email: email,
  //       password: password,
  //     );

  //     if (authResponse.user == null) {
  //       throw Exception('Login gagal');
  //     }

  //     // ✅ Get user profile
  //     final profileResponse = await _supabase
  //         .from('profiles')
  //         .select()
  //         .eq('id', authResponse.user!.id)
  //         .single();

  //     return UserModel.fromJson(profileResponse);
  //   } catch (e) {
  //     print('❌ Error signInWithUsernameOrEmail: $e');
  //     rethrow;
  //   }
  // }

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(response);
    } catch (e) {
      print('❌ Error getCurrentUser: $e');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // ========================================
  // 👤 USER MANAGEMENT METHODS
  // ========================================

  /// Get all users (untuk Super Admin)
  // Future<List<UserModel>> getAllUsers() async {
  //   try {
  //     final response = await _supabase
  //         .from('profiles')
  //         .select()
  //         .order('created_at', ascending: false);

  //     return (response as List)
  //         .map((json) => UserModel.fromJson(json))
  //         .toList();
  //   } catch (e) {
  //     print('❌ Error getAllUsers: $e');
  //     rethrow;
  //   }
  // }

  /// Create user (Super Admin only)
  Future<UserModel?> createUser({
    required String username,
    required String name,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    try {
      // ✅ Step 1: Create Supabase Auth user
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'nama_lengkap': name,
          'role': role,
          'no_telepon': phone,
        },
      );

      if (authResponse.user == null) {
        throw Exception('Gagal membuat user di Auth');
      }

      final userId = authResponse.user!.id;

      // ✅ Step 2: Insert ke table profiles
      // Database Trigger 'on_profile_created_check_guru' akan mendeteksi insert ini
      // dan otomatis membuat data di tabel 'guru' jika role == 'guru'.
      final profileData = {
        'id': userId,
        'email': email,
        'role': role,
        'no_telepon': phone,
        'is_active': true, // Langsung aktifkan agar bisa login
      };

      await _supabase.from('profiles').insert(profileData);

      // ✅ Step 3: Jika role = guru, create basic guru record
      // if (role == 'guru') {
      //   final guruData = {
      //     'id': userId, // ✅ Same as user ID
      //     'nuptk': username, // ✅ Use username as temporary NUPTK
      //     'nama': name,
      //     'email': email,
      //     'no_telp': phone,
      //     // Field lain NULL, diisi saat lengkapi profil
      //   };

      //   await _supabase.from('guru').insert(guruData);
      //   print('✅ Basic guru record created');
      // }

      // ✅ Step 4: Return UserModel
      final userResponse = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserModel.fromJson(userResponse);
    } catch (e) {
      print('❌ Error createUser: $e');
      rethrow;
    }
  }

  /// Update user (Super Admin atau self-service)
  Future<bool> updateUser({
    required String userId,
    String? name,
    String? email,
    String? phone,
    String? role,
    bool? isActive,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (name != null) updateData['nama_lengkap'] = name;
      if (email != null) updateData['email'] = email;
      if (phone != null) updateData['no_telepon'] = phone;
      if (role != null) updateData['role'] = role;
      if (isActive != null) updateData['is_active'] = isActive;

      updateData['updated_at'] = DateTime.now().toIso8601String();

      await _supabase.from('profiles').update(updateData).eq('id', userId);

      // ✅ Jika role = guru, sync ke table guru
      if (role == 'guru') {
        final guruUpdateData = <String, dynamic>{};
        if (name != null) guruUpdateData['nama'] = name;
        if (email != null) guruUpdateData['email'] = email;
        if (phone != null) guruUpdateData['no_telp'] = phone;
        guruUpdateData['updated_at'] = DateTime.now().toIso8601String();

        await _supabase.from('guru').update(guruUpdateData).eq('id', userId);
      }

      return true;
    } catch (e) {
      print('❌ Error updateUser: $e');
      return false;
    }
  }

  /// Delete user (Super Admin only)
  Future<bool> deleteUser(String userId) async {
    try {
      // ✅ Step 1: Delete dari table guru (jika ada)
      await _supabase.from('guru').delete().eq('id', userId);

      // ✅ Step 2: Delete dari profiles
      await _supabase.from('profiles').delete().eq('id', userId);

      // ✅ Step 3: Delete dari Supabase Auth
      // NOTE: Ini harus pakai Service Role Key (tidak bisa dari client)
      // Untuk production, buat Edge Function untuk delete auth user

      return true;
    } catch (e) {
      print('❌ Error deleteUser: $e');
      return false;
    }
  }

  // ========================================
  // 👨‍🏫 GURU MANAGEMENT (CRUD)
  // ========================================

  /// Create Guru (Tambah Data)
  // Future<void> createGuru(GuruModel guru) async {
  //   try {
  //     // Kita gunakan toJson() yang sudah kita rapikan sebelumnya
  //     await _supabase.from('guru').insert(guru.toJson());
  //   } catch (e) {
  //     print('❌ Error createGuru: $e');
  //     rethrow;
  //   }
  // }
  Future<void> createGuru(GuruModel guru) async {
    try {
      // Panggil Edge Function
      final response = await _supabase.functions.invoke(
        'auth-function', // Nama function harus sama dengan saat deploy
        body: {
          'type': 'guru',
          'data': {
            // Kirim semua data yang diperlukan tabel
            // Pastikan nama key SAMA PERSIS dengan nama kolom di database
            'nuptk': guru.nuptk,
            'nip': guru.nip,
            'nama_lengkap': guru.nama,
            'email': guru.email,
            'jenis_kelamin': guru.jenisKelamin, // 'L' atau 'P'
            // ✅ DATA TAMBAHAN (Tempat, Tanggal Lahir, Agama, Pendidikan)
            'tempat_lahir': guru.tempatLahir,
            'tanggal_lahir': guru.tanggalLahir
                ?.toIso8601String(), // Format string YYYY-MM-DD
            'agama': guru.agama,
            'pendidikan_terakhir': guru.pendidikanTerakhir,
            'alamat': guru.alamat,
            'no_telepon': guru.noTelp,
            'status_kepegawaian': guru.status,
          },
        },
      );

      if (response.status != 200) {
        throw Exception('Gagal: ${response.data}');
      }
    } catch (e) {
      print('❌ Error createGuru via Edge Function: $e');
      rethrow;
    }
  }

  /// Update Guru (Edit Data)
  Future<void> updateGuru(GuruModel guru) async {
    try {
      await _supabase.from('guru').update(guru.toJson()).eq('id', guru.id);
    } catch (e) {
      print('❌ Error updateGuru: $e');
      rethrow;
    }
  }

  /// Delete Guru (Hapus Data)
  Future<void> deleteGuru(String id) async {
    try {
      await _supabase.from('guru').delete().eq('id', id);
    } catch (e) {
      print('❌ Error deleteGuru: $e');
      rethrow;
    }
  }

  // ========================================
  // ➕ CREATE GURU ACCOUNT & DATA
  // ========================================

  /// Membuat akun guru (Trigger SQL akan otomatis handle insert ke profiles & guru)
  Future<bool> createGuruAccount({
    required GuruModel guru,
    required String password,
  }) async {
    try {
      print('🚀 Memulai pembuatan akun guru: ${guru.nama}');

      // 1. Buat User Auth dengan METADATA lengkap
      // Metadata ini akan dibaca oleh Trigger 'handle_new_user' untuk insert ke tabel guru
      final authResponse = await _supabase.auth.signUp(
        email: guru.email ?? '${guru.nip ?? guru.nuptk}@sekolah.id',
        password: password,
        data: {
          'nama_lengkap': guru.nama,
          'role': 'guru',
          'no_telepon': guru.noTelp,
          'nip': guru.nip, // Dikirim ke metadata untuk trigger
          'nuptk': guru.nuptk, // Dikirim ke metadata untuk trigger
        },
      );

      if (authResponse.user == null) throw Exception("Gagal membuat user auth");
      final userId = authResponse.user!.id;

      print('✅ Akun dibuat. Trigger SQL sedang bekerja...');

      // 2. Delay sebentar agar trigger database selesai
      await Future.delayed(const Duration(seconds: 1));

      // 3. Update data detail guru (data tambahan yang tidak di-handle trigger)
      final guruUpdateData = {
        'jenis_kelamin': guru.jenisKelamin,
        'tempat_lahir': guru.tempatLahir,
        'tanggal_lahir': guru.tanggalLahir?.toIso8601String(),
        'agama': guru.agama,
        'alamat': guru.alamat,
        'pendidikan_terakhir': guru.pendidikanTerakhir,
        'status_kepegawaian': guru.status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Hapus value null
      guruUpdateData.removeWhere((key, value) => value == null);

      await _supabase.from('guru').update(guruUpdateData).eq('id', userId);

      print('✅ Detail data guru berhasil diupdate.');
      return true;
    } catch (e) {
      print('❌ Error createGuruAccount: $e');
      return false;
    }
  }

  // Future<bool> createGuruAccount({
  //   required GuruModel guru,
  //   required String password,
  // }) async {
  //   try {
  //     print('🚀 Memulai pembuatan akun guru: ${guru.nama}');

  //     // 1. Buat User Auth & Profile
  //     // Trigger SQL 'auto_create_guru_from_profile' akan berjalan otomatis
  //     // dan membuat baris di tabel 'guru' berdasarkan ID user ini.
  //     final user = await createUser(
  //       username: guru.nip ?? guru.nuptk, // Gunakan NIP/NUPTK sebagai username
  //       name: guru.nama,
  //       email: guru.email ?? '', // Fallback email jika kosong
  //       password: password,
  //       role: 'guru',
  //       phone: guru.noTelp,
  //     );

  //     if (user == null) throw Exception("Gagal membuat user auth");

  //     print(
  //       '✅ Akun & Profile berhasil dibuat. Trigger SQL seharusnya sudah membuat data Guru.',
  //     );

  //     // 2. Update data detail guru yang baru saja dibuat otomatis oleh Trigger
  //     // Kita perlu delay sedikit untuk memastikan Trigger DB selesai (opsional tapi disarankan)
  //     await Future.delayed(const Duration(milliseconds: 500));

  //     final guruUpdateData = {
  //       'nuptk': guru.nuptk,
  //       'nip': guru.nip,
  //       'jenis_kelamin':
  //           guru.jenisKelamin, // Pastikan field DB 'jenis_kelamin' ada
  //       'tempat_lahir': guru.tempatLahir,
  //       'tanggal_lahir': guru.tanggalLahir?.toIso8601String(),
  //       'agama': guru.agama,
  //       'alamat': guru.alamat,
  //       'pendidikan_terakhir': guru.pendidikanTerakhir,
  //       'status_kepegawaian': guru
  //           .status, // Field 'status' di model -> 'status_kepegawaian' di DB? Sesuaikan.
  //       'updated_at': DateTime.now().toIso8601String(),
  //       // Note: Mata pelajaran & Wali kelas biasanya butuh tabel relasi terpisah,
  //       // tapi untuk data dasar guru, ini cukup.
  //     };

  //     // Bersihkan nilai null agar tidak menimpa data (jika ada)
  //     guruUpdateData.removeWhere((key, value) => value == null);

  //     await _supabase
  //         .from('guru')
  //         .update(guruUpdateData)
  //         .eq('id', user.id); // ID Guru = ID User (karena relasi 1:1)

  //     print('✅ Detail data guru berhasil diupdate.');
  //     return true;
  //   } catch (e) {
  //     print('❌ Error createGuruAccount: $e');
  //     // Opsional: Jika update detail gagal, mungkin perlu hapus user auth biar tidak "yatim"
  //     return false;
  //   }
  // }
  // ========================================
  // 👨‍🏫 GURU MANAGEMENT METHODS
  // ========================================

  /// Get all guru
  // Future<List<Map<String, dynamic>>> getAllGuru() async {
  //   try {
  //     print('📚 Fetching all guru...');
  //     final response = await _supabase
  //         .from('guru')
  //         .select('*, profiles:profile_id(email, no_telepon, foto_profil)')
  //         .order('created_at', ascending: false);

  //     print('✅ Fetched ${(response as List).length} guru');
  //     return List<Map<String, dynamic>>.from(response);
  //   } catch (e) {
  //     print('❌ Error getAllGuru: $e');
  //     rethrow;
  //   }
  // }

  Future<List<Map<String, dynamic>>> getAllGuru() async {
    try {
      // ✅ FIX: Gunakan sintaks JOIN yang sama persis dengan getGuruById
      // profiles:profile_id(...) artinya ambil tabel profiles lewat foreign key profile_id
      final responseGuru = await _supabase.from('guru').select('''
      *,
      profiles:profiles!guru_profile_id_fkey (
        email,
        no_telepon
      )
    ''');

      // Ambil data Kelas (untuk cek wali kelas)
      final responseKelas = await _supabase
          .from('kelas')
          .select('nama_kelas, wali_kelas_id');

      final List<Map<String, dynamic>> listKelas =
          List<Map<String, dynamic>>.from(responseKelas);
      final List<Map<String, dynamic>> mergedData =
          List<Map<String, dynamic>>.from(responseGuru);

      // Gabungkan Data
      for (var guru in mergedData) {
        final profileId = guru['profile_id'];

        if (profileId != null) {
          final Map<String, dynamic>? kelasWali = listKelas
              .where((k) => k['wali_kelas_id'] == profileId)
              .firstOrNull;

          if (kelasWali != null) {
            // Inject data kelas
            guru['kelas'] = {'nama_kelas': kelasWali['nama_kelas']};
            guru['is_wali_kelas'] = true;
          }
        }
      }

      return mergedData;
    } catch (e) {
      print('❌ Error getAllGuru: $e');
      rethrow;
    }
  }

  /// Ambil Daftar Kelas yang diajar oleh Guru (Distinct)
  /// Logic: Cek tabel 'jadwal_pelajaran' -> ambil 'kelas_id' -> distinct
  Future<List<Map<String, dynamic>>> getKelasMengajarGuru(
    String guruId,
    String tahunId,
  ) async {
    try {
      // 1. Ambil semua jadwal guru di tahun aktif
      final response = await _supabase
          .from('jadwal_pelajaran')
          .select('kelas:kelas_id(id, nama_kelas)') // Join ke tabel kelas
          .eq('guru_id', guruId)
          .eq('tahun_pelajaran_id', tahunId);

      // 2. Filter Distinct (Hilangkan duplikat kelas)
      // Karena guru bisa mengajar di 7A hari Senin DAN Kamis, kita cuma butuh list kelasnya sekali.
      final uniqueKelas = <String, Map<String, dynamic>>{};

      for (var item in response) {
        final kelasData = item['kelas'] as Map<String, dynamic>?;
        if (kelasData != null) {
          final id = kelasData['id'];
          if (!uniqueKelas.containsKey(id)) {
            uniqueKelas[id.toString()] = kelasData;
          }
        }
      }

      return uniqueKelas.values.toList();
    } catch (e) {
      print('❌ Error getKelasMengajarGuru: $e');
      rethrow;
    }
  }

  /// Get guru by profile_id
  // Future<Map<String, dynamic>?> getGuruByProfileId(String profileId) async {
  //   try {
  //     print('📚 Getting guru by profile ID: $profileId');
  //     final response = await _supabase
  //         .from('guru')
  //         .select('*, profiles:profile_id(email, no_telepon, foto_profil)')
  //         .eq('profile_id', profileId)
  //         .maybeSingle();

  //     // Fallback check on 'id' if profile_id match fails (legacy data support)
  //     if (response == null) {
  //       return await _supabase
  //           .from('guru')
  //           .select('*, profiles:profile_id(email, no_telepon, foto_profil)')
  //           .eq('id', profileId)
  //           .maybeSingle();
  //     }

  //     return response;
  //   } catch (e) {
  //     print('❌ Error getGuruByProfileId: $e');
  //     return null;
  //   }
  // }
  Future<GuruModel?> getGuruByProfileId(String profileId) async {
    try {
      // 1. Ambil Data Detail Guru
      final guruResponse = await _supabase
          .from('guru')
          .select('*, profiles:profile_id(email, no_telepon)')
          .eq('profile_id', profileId)
          .maybeSingle();

      if (guruResponse == null) return null;

      // 2. ✅ CEK TABEL KELAS
      // Cari kelas yang wali_kelas_id-nya adalah profileId user ini
      final kelasResponse = await _supabase
          .from('kelas')
          .select('id, nama_kelas, tingkat')
          .eq('wali_kelas_id', profileId)
          .maybeSingle(); // Mengembalikan null jika tidak ketemu (bukan wali kelas)

      // 3. Gabungkan Data ke Model
      // Kita kirim kelasResponse sebagai parameter tambahan
      return GuruModel.fromJson(guruResponse, kelasData: kelasResponse);
    } catch (e) {
      print('❌ Error getGuruByProfileId: $e');
      rethrow;
    }
  }

  // ✅ NEW METHOD: Get guru by ID
  Future<Map<String, dynamic>?> getGuruById(String guruId) async {
    try {
      print('📚 Getting guru by ID: $guruId');
      final response = await _supabase
          .from('guru')
          .select(
            '*, profiles:profile_id(email, no_telepon, foto_profil)',
          ) // ✅ Join
          .eq('id', guruId)
          .maybeSingle();

      if (response != null) {
        print('✅ Guru found: ${response['nama']}');
      } else {
        print('⚠️ No guru found with ID: $guruId');
      }
      return response;
    } catch (e) {
      print('❌ Error getting guru by ID: $e');
      return null;
    }
  }

  /// Update Data Profil Guru
  // Future<void> updateGuruProfile(
  //   String guruId,
  //   Map<String, dynamic> data,
  // ) async {
  //   try {
  //     await _supabase.from('guru').update(data).eq('id', guruId);
  //   } catch (e) {
  //     print('❌ Error updateGuruProfile: $e');
  //     rethrow;
  //   }
  // }

  /// Update guru profile (SIMPLIFIED - only basic fields)
  Future<bool> updateGuruProfile({
    required String guruId,
    required String nuptk,
    required String nama,
    String? nip,
    String? alamat,
    String? pendidikanTerakhir,
    String? jenisKelamin,
    String? tempatLahir,
    DateTime? tanggalLahir,
    String? agama,
    String? statusKepegawaian,
  }) async {
    try {
      print('💾 Updating guru profile: $guruId');

      final guruUpdateData = <String, dynamic>{
        'nuptk': nuptk,
        'nama_lengkap': nama,
        'nip': nip,
        'alamat': alamat,
        'pendidikan_terakhir': pendidikanTerakhir,
        'jenis_kelamin': jenisKelamin,
        'tempat_lahir': tempatLahir,
        'tanggal_lahir': tanggalLahir?.toIso8601String(),
        'agama': agama,
        'status_kepegawaian': statusKepegawaian,

        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('guru').update(guruUpdateData).eq('id', guruId);

      print('✅ Guru profile updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updateGuruProfile: $e');
      return false;
    }
  }

  // ✅ NEW METHOD: Set wali kelas
  Future<bool> setWaliKelas({
    required String guruId,
    required String kelasId,
  }) async {
    try {
      print('👨‍🏫 Setting wali kelas: $guruId -> $kelasId');

      await _supabase
          .from('guru')
          .update({
            'is_wali_kelas': true,
            'wali_kelas': kelasId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', guruId);

      print('✅ Wali kelas set successfully');
      return true;
    } catch (e) {
      print('❌ Error setting wali kelas: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getJadwalMengajar(
    String guruId,
    String tahunAjaranId,
  ) async {
    try {
      final response = await _supabase
          .from('jadwal_pelajaran')
          .select('''
          id,
          kelas:kelas_id (id, nama_kelas),
          mapel:mapel_id (id, nama_mapel)
        ''')
          .eq('guru_id', guruId)
          .eq('tahun_pelajaran_id', tahunAjaranId); // Hanya tahun aktif

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error getJadwalMengajar: $e');
      return [];
    }
  }

  // ✅ NEW METHOD: Remove wali kelas
  Future<bool> removeWaliKelas(String guruId) async {
    try {
      print('❌ Removing wali kelas: $guruId');

      await _supabase
          .from('guru')
          .update({
            'is_wali_kelas': false,
            'wali_kelas': null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', guruId);

      print('✅ Wali kelas removed successfully');
      return true;
    } catch (e) {
      print('❌ Error removing wali kelas: $e');
      return false;
    }
  }

  // ========================================
  // 🎓 SISWA MANAGEMENT
  // ========================================

  /// Ambil Semua Siswa (Lengkap dengan Kelas & Info Wali)
  Future<List<Map<String, dynamic>>> getAllSiswa() async {
    try {
      // 1. Ambil Data Siswa + Nama Kelas
      final responseSiswa = await _supabase
          .from('siswa')
          .select('*, kelas(nama_kelas)')
          .order('nama_lengkap', ascending: true);

      // 2. Ambil Data Wali Murid (Join Profiles untuk email/telp)
      // Kita ambil semua wali untuk dicocokkan di client side (lebih aman daripada deep join yg rawan error)
      final responseWali = await _supabase
          .from('wali_murid')
          .select(
            'nama_lengkap, profile_id, profiles:profile_id(email, no_telepon)',
          );

      final List<Map<String, dynamic>> listSiswa =
          List<Map<String, dynamic>>.from(responseSiswa);
      final List<Map<String, dynamic>> listWali =
          List<Map<String, dynamic>>.from(responseWali);

      // 3. Gabungkan Data (Manual Merge)
      for (var siswa in listSiswa) {
        final waliProfileId = siswa['wali_murid_id'];

        if (waliProfileId != null) {
          // Cari data wali yang profile_id-nya cocok
          final waliFound = listWali
              .where((w) => w['profile_id'] == waliProfileId)
              .firstOrNull;

          if (waliFound != null) {
            // Extract info profil
            final profiles = waliFound['profiles'] as Map?;

            // Inject ke objek siswa agar Model bisa membacanya
            siswa['wali_data'] = {
              'nama_lengkap': waliFound['nama_lengkap'],
              'email': profiles?['email'],
              'no_telepon': profiles?['no_telepon'],
            };
          }
        }
      }

      return listSiswa;
    } catch (e) {
      print('❌ Error getAllSiswa: $e');
      rethrow;
    }
  }

  /// Tambah Siswa & Akun Wali (Via Edge Function)
  Future<void> createSiswaAndWali(Map<String, dynamic> dataPayload) async {
    try {
      // Panggil Edge Function 'auth-function'
      final response = await _supabase.functions.invoke(
        'auth-function',
        body: {
          'type': 'siswa',
          'data': dataPayload, // Pastikan key JSON sesuai dengan index.ts
        },
      );

      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Gagal membuat data siswa');
      }
    } catch (e) {
      print('❌ Error createSiswaAndWali: $e');
      rethrow;
    }
  }

  /// Update Data Siswa (Hanya tabel siswa)
  Future<void> updateSiswa(String id, Map<String, dynamic> data) async {
    try {
      await _supabase.from('siswa').update(data).eq('id', id);
    } catch (e) {
      print('❌ Error updateSiswa: $e');
      rethrow;
    }
  }

  /// Hapus Siswa
  Future<void> deleteSiswa(String id) async {
    try {
      // Note: Idealnya, jika wali murid hanya punya 1 anak ini, akun walinya juga dihapus.
      // Tapi untuk sekarang kita hapus siswanya saja dulu.
      await _supabase.from('siswa').delete().eq('id', id);
    } catch (e) {
      print('❌ Error deleteSiswa: $e');
      rethrow;
    }
  }

  // ========================================
  // 👨‍👩‍👧 SISWA & WALI MURID METHODS
  // ========================================

  /// Create siswa dengan auto-create wali murid
  Future<String?> createSiswaWithWali({
    required String nisn,
    required String nis,
    required String namaLengkap,
    required String jenisKelamin,
    required DateTime tanggalLahir,
    required String kelasId,
    // Parent data
    required String namaOrtu,
    required String emailOrtu,
    required String noTelpOrtu,
  }) async {
    try {
      // ✅ Step 1: Check apakah wali murid sudah ada (by email)
      String? waliMuridId;

      final existingWali = await _supabase
          .from('profiles')
          .select('id')
          .eq('email', emailOrtu)
          .eq('role', 'wali_murid')
          .maybeSingle();

      if (existingWali != null) {
        // Wali murid sudah ada (siblings)
        waliMuridId = existingWali['id'] as String;
        print('✅ Using existing wali_murid: $waliMuridId');
      } else {
        // ✅ Step 2: Create wali murid user (password = NISN)
        final waliAuthResponse = await _supabase.auth.signUp(
          email: emailOrtu,
          password: nisn, // ✅ Password default = NISN siswa
        );

        if (waliAuthResponse.user == null) {
          throw Exception('Gagal membuat akun wali murid');
        }

        waliMuridId = waliAuthResponse.user!.id;

        // ✅ Step 3: Insert wali murid ke profiles
        final waliProfileData = {
          'id': waliMuridId,
          'username': emailOrtu.split('@')[0], // Email prefix as username
          'nama_lengkap': namaOrtu,
          'email': emailOrtu,
          'role': 'wali_murid',
          'no_telepon': noTelpOrtu,
          'is_active': true,
        };

        await _supabase.from('profiles').insert(waliProfileData);
        print('✅ New wali_murid created: $waliMuridId');
      }

      // ✅ Step 4: Insert siswa dengan wali_murid_id
      final siswaData = {
        'nisn': nisn,
        'nis': nis,
        'nama_lengkap': namaLengkap,
        'jenis_kelamin': jenisKelamin,
        'tanggal_lahir': tanggalLahir.toIso8601String(),
        'kelas_id': kelasId,
        'wali_murid_id': waliMuridId, // ✅ Link to wali murid
        'is_active': true,
      };

      final siswaResponse = await _supabase
          .from('peserta_didik')
          .insert(siswaData)
          .select()
          .single();

      final siswaId = siswaResponse['id'] as String;
      print('✅ Siswa created: $siswaId');

      return siswaId;
    } catch (e) {
      print('❌ Error createSiswaWithWali: $e');
      rethrow;
    }
  }

  /// ✅ Ambil Siswa berdasarkan Kelas ID (Lengkap dengan data Wali)
  /// Ambil Siswa berdasarkan Kelas ID (Dengan Auto-Retry)
  Future<List<Map<String, dynamic>>> getSiswaByKelasId(String kelasId) async {
    // 1. Kita bungkus logic request ke dalam fungsi internal
    Future<List<Map<String, dynamic>>> performRequest() async {
      final response = await _supabase
          .from('siswa')
          .select('''
            *, 
            wali_murid(*)
          ''')
          .eq('kelas_id', kelasId)
          .order('nama_lengkap', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    }

    // 2. Eksekusi dengan mekanisme Retry
    try {
      // Percobaan Pertama
      return await performRequest();
    } catch (e) {
      print('⚠️ Gagal ambil siswa (Attempt 1), mencoba lagi... Error: $e');
      try {
        // Percobaan Kedua (Tunggu 500ms lalu coba lagi)
        await Future.delayed(const Duration(milliseconds: 500));
        return await performRequest();
      } catch (e2) {
        // Jika masih gagal, baru lempar error ke UI
        print('❌ Error getSiswaByKelasId (Final): $e2');
        rethrow;
      }
    }
  }

  /// Get siswa by wali_murid_id (untuk wali murid lihat anaknya)
  Future<List<Map<String, dynamic>>> getSiswaByWaliMuridId(
    String waliMuridId,
  ) async {
    try {
      final response = await _supabase
          .from('peserta_didik')
          .select('''
            *,
            kelas:kelas_id(nama_kelas, tingkat)
          ''')
          .eq('wali_murid_id', waliMuridId)
          .order('nama_lengkap');

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('❌ Error getSiswaByWaliMuridId: $e');
      rethrow;
    }
  }

  // ========================================
  // 📚 HELPER METHODS
  // ========================================

  /// Get all kelas (untuk dropdown)
  Future<List<Map<String, dynamic>>> getAllKelas() async {
    try {
      final response = await _supabase
          .from('kelas')
          .select()
          .order('tingkat')
          .order('nama_kelas');

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('❌ Error getAllKelas: $e');
      return [];
    }
  }

  /// Get all mata pelajaran (untuk dropdown)
  Future<List<Map<String, dynamic>>> getAllMataPelajaran() async {
    try {
      final response = await _supabase
          .from('mata_pelajaran')
          .select()
          .order('nama_mapel');

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('❌ Error getAllMataPelajaran: $e');
      return [];
    }
  }

  /// Get available kelas for wali kelas (exclude yang sudah punya wali)
  Future<List<Map<String, dynamic>>> getAvailableKelasForWali({
    String? currentGuruId,
  }) async {
    try {
      // Get all kelas
      final allKelas = await getAllKelas();

      // Get kelas yang sudah punya wali
      final usedKelas = await _supabase
          .from('guru')
          .select('wali_kelas')
          .not('wali_kelas', 'is', null);

      final usedKelasIds = (usedKelas as List)
          .map((item) => item['wali_kelas'] as String)
          .where((id) => id.isNotEmpty)
          .toList();

      // Filter: hanya kelas yang belum punya wali OR kelas dari guru ini sendiri
      final guru = currentGuruId != null
          ? await _supabase
                .from('guru')
                .select('wali_kelas')
                .eq('id', currentGuruId)
                .maybeSingle()
          : null;

      final currentKelasId = guru?['wali_kelas'] as String?;

      return allKelas.where((kelas) {
        final kelasId = kelas['id'] as String;
        return !usedKelasIds.contains(kelasId) || kelasId == currentKelasId;
      }).toList();
    } catch (e) {
      print('❌ Error getAvailableKelasForWali: $e');
      return [];
    }
  }

  // ========================================
  // 🏫 KELAS MANAGEMENT METHODS
  // ========================================

  /// Get All Kelas
  Future<List<Map<String, dynamic>>> fetchAllKelasData() async {
    try {
      final response = await _supabase
          .from('kelas')
          .select() // Kita tidak join profiles karena nama ada di tabel guru
          .order('tingkat', ascending: true)
          .order('nama_kelas', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetchAllKelasData: $e');
      rethrow;
    }
  }

  /// Create Kelas
  Future<void> createKelas({
    required String namaKelas,
    required int tingkat,
    String? waliKelasId, // profile_id
  }) async {
    try {
      await _supabase.from('kelas').insert({
        'nama_kelas': namaKelas,
        'tingkat': tingkat,
        'wali_kelas_id': waliKelasId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Error createKelas: $e');
      rethrow;
    }
  }

  /// Update Kelas
  Future<void> updateKelas({
    required String id,
    required String namaKelas,
    required int tingkat,
    String? waliKelasId,
  }) async {
    try {
      await _supabase
          .from('kelas')
          .update({
            'nama_kelas': namaKelas,
            'tingkat': tingkat,
            'wali_kelas_id': waliKelasId,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      print('❌ Error updateKelas: $e');
      rethrow;
    }
  }

  /// Delete Kelas
  Future<void> deleteKelas(String id) async {
    try {
      await _supabase.from('kelas').delete().eq('id', id);
    } catch (e) {
      print('❌ Error deleteKelas: $e');
      rethrow;
    }
  }

  // ========================================
  // 📚 MATA PELAJARAN MANAGEMENT
  // ========================================

  /// Get All Mata Pelajaran
  Future<List<Map<String, dynamic>>> fetchAllMataPelajaran() async {
    try {
      final response = await _supabase
          .from('mata_pelajaran')
          .select()
          .order('nama_mapel', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetchAllMataPelajaran: $e');
      rethrow;
    }
  }

  /// Create Mata Pelajaran
  Future<void> createMataPelajaran({
    required String kodeMapel,
    required String namaMapel,
    String? kategori,
  }) async {
    try {
      await _supabase.from('mata_pelajaran').insert({
        'kode_mapel': kodeMapel,
        'nama_mapel': namaMapel,
        'kategori': kategori,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Error createMataPelajaran: $e');
      rethrow;
    }
  }

  /// Update Mata Pelajaran
  Future<void> updateMataPelajaran({
    required String id,
    required String kodeMapel,
    required String namaMapel,
    String? kategori,
  }) async {
    try {
      await _supabase
          .from('mata_pelajaran')
          .update({
            'kode_mapel': kodeMapel,
            'nama_mapel': namaMapel,
            'kategori': kategori,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      print('❌ Error updateMataPelajaran: $e');
      rethrow;
    }
  }

  /// Delete Mata Pelajaran
  Future<void> deleteMataPelajaran(String id) async {
    try {
      await _supabase.from('mata_pelajaran').delete().eq('id', id);
    } catch (e) {
      print('❌ Error deleteMataPelajaran: $e');
      rethrow;
    }
  }

  // ========================================
  // 📅 TAHUN PELAJARAN MANAGEMENT
  // ========================================

  /// Get All
  Future<List<Map<String, dynamic>>> fetchAllTahunPelajaran() async {
    try {
      final response = await _supabase
          .from('tahun_pelajaran')
          .select()
          .order('tahun', ascending: false) // Tahun terbaru di atas
          .order('semester', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetchAllTahunPelajaran: $e');
      rethrow;
    }
  }

  /// Create
  Future<void> createTahunPelajaran({
    required String tahun,
    required int semester,
    required bool isActive,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
  }) async {
    try {
      // ⚠️ LOGIC PENTING: Jika yang baru ini AKTIF, non-aktifkan semua yang lain dulu
      if (isActive) {
        await _supabase
            .from('tahun_pelajaran')
            .update({'is_active': false})
            .neq('id', 'placeholder'); // Update semua baris
      }

      await _supabase.from('tahun_pelajaran').insert({
        'tahun': tahun,
        'semester': semester,
        'is_active': isActive,
        'tanggal_mulai': tanggalMulai.toIso8601String(),
        'tanggal_selesai': tanggalSelesai.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('❌ Error createTahunPelajaran: $e');
      rethrow;
    }
  }

  /// Update
  Future<void> updateTahunPelajaran({
    required String id,
    required String tahun,
    required int semester,
    required bool isActive,
    required DateTime tanggalMulai,
    required DateTime tanggalSelesai,
  }) async {
    try {
      // ⚠️ LOGIC PENTING: Jika di-set AKTIF, non-aktifkan yang lain
      if (isActive) {
        await _supabase
            .from('tahun_pelajaran')
            .update({'is_active': false})
            .neq('id', id); // Kecuali diri sendiri
      }

      await _supabase
          .from('tahun_pelajaran')
          .update({
            'tahun': tahun,
            'semester': semester,
            'is_active': isActive,
            'tanggal_mulai': tanggalMulai.toIso8601String(),
            'tanggal_selesai': tanggalSelesai.toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);
    } catch (e) {
      print('❌ Error updateTahunPelajaran: $e');
      rethrow;
    }
  }

  /// Delete
  Future<void> deleteTahunPelajaran(String id) async {
    try {
      await _supabase.from('tahun_pelajaran').delete().eq('id', id);
    } catch (e) {
      print('❌ Error deleteTahunPelajaran: $e');
      rethrow;
    }
  }

  // ========================================
  // 📅 JADWAL PELAJARAN MANAGEMENT
  // ========================================

  /// Get Jadwal by Tahun Ajaran & Kelas (Opsional filter kelas)
  Future<List<Map<String, dynamic>>> fetchJadwalPelajaran({
    required String tahunPelajaranId,
    String? kelasId, // Filter opsional
  }) async {
    try {
      var query = _supabase
          .from('jadwal_pelajaran')
          .select('''
            *,
            guru:guru_id(nama_lengkap),
            kelas:kelas_id(nama_kelas),
            mapel:mapel_id(nama_mapel)
          ''')
          .eq('tahun_pelajaran_id', tahunPelajaranId);

      if (kelasId != null) {
        query = query.eq('kelas_id', kelasId);
      }

      // Order by Hari (Manual sorting nanti di Provider/UI karena Hari string)
      // Order by Jam Mulai
      final response = await query.order('jam_mulai', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetchJadwalPelajaran: $e');
      rethrow;
    }
  }

  /// Create Jadwal
  Future<void> createJadwal({
    required String guruId,
    required String kelasId,
    required String mapelId,
    required String tahunPelajaranId,
    required String hari,
    required String jamMulai,
    required String jamSelesai,
  }) async {
    await _supabase.from('jadwal_pelajaran').insert({
      'guru_id': guruId,
      'kelas_id': kelasId,
      'mapel_id': mapelId,
      'tahun_pelajaran_id': tahunPelajaranId,
      'hari': hari,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
    });
  }

  /// Delete Jadwal
  Future<void> deleteJadwal(String id) async {
    await _supabase.from('jadwal_pelajaran').delete().eq('id', id);
  }

  /// Get Jadwal Khusus Guru Tertentu
  Future<List<Map<String, dynamic>>> fetchJadwalByGuru({
    required String guruId,
    required String tahunPelajaranId,
  }) async {
    try {
      final response = await _supabase
          .from('jadwal_pelajaran')
          .select('''
            *,
            kelas:kelas_id(nama_kelas),
            mapel:mapel_id(nama_mapel)
          ''')
          .eq('guru_id', guruId)
          .eq('tahun_pelajaran_id', tahunPelajaranId)
          .order('jam_mulai', ascending: true); // Urutkan berdasarkan jam

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetchJadwalByGuru: $e');
      rethrow;
    }
  }

  // ========================================
  // 📝 FITUR INPUT NILAI
  // ========================================

  /// Ambil Nilai berdasarkan Filter (Kelas, Mapel, Tahun)
  Future<List<NilaiModel>> getNilaiByFilter({
    required String kelasId,
    required String mapelId,
    required String tahunId,
  }) async {
    try {
      final response = await _supabase
          .from('nilai')
          .select()
          .eq('kelas_id', kelasId)
          .eq('mata_pelajaran_id', mapelId)
          .eq('tahun_pelajaran_id', tahunId);

      return (response as List).map((e) => NilaiModel.fromJson(e)).toList();
    } catch (e) {
      print('❌ Error getNilaiByFilter: $e');
      rethrow;
    }
  }

  /// Simpan Nilai (Upsert: Insert jika belum ada, Update jika ada)
  Future<void> saveNilai(NilaiModel nilai) async {
    try {
      // Cek apakah data sudah ada berdasarkan (siswa, mapel, tahun)
      // Ini penting karena kita tidak bisa mengandalkan ID jika ini data baru
      final existing = await _supabase
          .from('nilai')
          .select('id')
          .eq('siswa_id', nilai.siswaId)
          .eq('mata_pelajaran_id', nilai.mataPelajaranId)
          .eq('tahun_pelajaran_id', nilai.tahunPelajaranId)
          .maybeSingle();

      if (existing != null) {
        // UPDATE
        await _supabase
            .from('nilai')
            .update(
              nilai.toJson(),
            ) // Pastikan toJson punya field yang mau diupdate
            .eq('id', existing['id']);
      } else {
        // INSERT
        // Hapus 'id' dari map agar digenerate otomatis oleh UUID v4 di DB
        final data = nilai.toJson();
        data.remove('id');
        await _supabase.from('nilai').insert(data);
      }
    } catch (e) {
      print('❌ Error saveNilai: $e');
      rethrow;
    }
  }

  /// Ambil Daftar Mapel & Kelas yang diajar Guru (Untuk Menu Input Nilai)
  /// Ambil Daftar Mapel & Kelas (Dengan Auto-Retry)
  Future<List<Map<String, dynamic>>> getJadwalMapelGuru(
    String guruId,
    String tahunId,
  ) async {
    // Fungsi internal untuk melakukan request
    Future<List<Map<String, dynamic>>> performRequest() async {
      final response = await _supabase
          .from('jadwal_pelajaran')
          .select('''
            id,
            mata_pelajaran(id, nama_mapel),
            kelas(id, nama_kelas)
          ''')
          .eq('guru_id', guruId)
          .eq('tahun_pelajaran_id', tahunId);

      final uniqueItems = <String, Map<String, dynamic>>{};

      for (var item in response) {
        final mapel = item['mata_pelajaran'];
        final kelas = item['kelas'];

        if (mapel != null && kelas != null) {
          final key = "${kelas['id']}_${mapel['id']}";
          if (!uniqueItems.containsKey(key)) {
            uniqueItems[key] = {
              'kelas_id': kelas['id'],
              'nama_kelas': kelas['nama_kelas'],
              'mapel_id': mapel['id'],
              'nama_mapel': mapel['nama_mapel'],
            };
          }
        }
      }
      return uniqueItems.values.toList();
    }

    // --- LOGIC RETRY ---
    try {
      // Percobaan Pertama
      return await performRequest();
    } catch (e) {
      print('⚠️ Percobaan pertama gagal ($e), mencoba lagi...');
      try {
        // Percobaan Kedua (Retry)
        // Beri jeda sedikit (opsional)
        await Future.delayed(const Duration(milliseconds: 500));
        return await performRequest();
      } catch (e2) {
        // Jika masih gagal, baru lempar error ke UI
        print('❌ Error getJadwalMapelGuru (Final): $e2');
        rethrow;
      }
    }
  }

  /// Ambil Nilai Lengkap Siswa untuk Rapor (Join Mapel & Guru)
  Future<List<Map<String, dynamic>>> getNilaiRaporSiswa(
    String siswaId,
    String tahunId,
  ) async {
    try {
      final response = await _supabase
          .from('nilai')
          .select('''
            *,
            mata_pelajaran(nama_mapel)
          ''') // Join ke mapel
          .eq('siswa_id', siswaId)
          .eq('tahun_pelajaran_id', tahunId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error getNilaiRaporSiswa: $e');
      rethrow;
    }
  }

  /// Ambil Kelas dimana User ini menjadi Wali Kelas
  /// LOGIC BARU: Langsung cek wali_kelas_id = Profile ID (Auth ID)
  Future<Map<String, dynamic>?> getKelasByWaliProfileId(
    String profileId,
  ) async {
    try {
      final response = await _supabase
          .from('kelas')
          .select('*')
          .eq('wali_kelas_id', profileId) // Langsung pakai ID Login
          .maybeSingle(); // Ambil satu, return null jika tidak ada

      return response;
    } catch (e) {
      print('❌ Error getKelasByWaliProfileId: $e');
      return null;
    }
  }

  /// 📊 REKAP NILAI: Ambil Nilai semua siswa di kelas & mapel tertentu
  Future<List<Map<String, dynamic>>> getRekapNilaiKelas({
    required String kelasId,
    required String mapelId,
    required String tahunId,
  }) async {
    try {
      // 1. Ambil Semua Siswa di Kelas tersebut dulu
      final resSiswa = await _supabase
          .from('siswa')
          .select('id, nama_lengkap, nisn')
          .eq('kelas_id', kelasId)
          .order('nama_lengkap', ascending: true);

      // 2. Ambil Nilai yang sudah diinput untuk kelas & mapel ini
      final resNilai = await _supabase
          .from('nilai')
          .select()
          .eq('kelas_id', kelasId)
          .eq('mata_pelajaran_id', mapelId)
          .eq('tahun_pelajaran_id', tahunId);

      // 3. Gabungkan Data (Manual Left Join)
      // Kita ingin SEMUA siswa tampil, meskipun belum punya nilai
      List<Map<String, dynamic>> rekapList = [];

      for (var siswa in resSiswa) {
        // Cari nilai milik siswa ini
        Map<String, dynamic>? nilaiData;

        for (final n in resNilai) {
          if (n['siswa_id'] == siswa['id']) {
            nilaiData = n;
            break;
          }
        }

        rekapList.add({
          'siswa': siswa, // Data Siswa (Nama, NISN)
          'nilai': nilaiData, // Data Nilai (Bisa null jika belum dinilai)
        });
      }

      return rekapList;
    } catch (e) {
      print('❌ Error getRekapNilaiKelas: $e');
      rethrow;
    }
  }

  /// Ambil Daftar Mapel di suatu Kelas (Untuk Wali Kelas melihat Rekap)
  Future<List<Map<String, dynamic>>> getMapelDiKelas(
    String kelasId,
    String tahunId,
  ) async {
    try {
      final response = await _supabase
          .from('jadwal_pelajaran')
          .select('mata_pelajaran(id, nama_mapel)')
          .eq('kelas_id', kelasId)
          .eq('tahun_pelajaran_id', tahunId);

      // Filter Unik (Distinct) karena 1 mapel bisa ada di 2 hari jadwal
      final uniqueMapel = <String, Map<String, dynamic>>{};

      for (var item in response) {
        final mapel = item['mata_pelajaran'];
        if (mapel != null) {
          final id = mapel['id'];
          if (!uniqueMapel.containsKey(id)) {
            uniqueMapel[id] = mapel;
          }
        }
      }

      return uniqueMapel.values.toList();
    } catch (e) {
      print('❌ Error getMapelDiKelas: $e');
      return [];
    }
  }

  /// Ambil data absensi siswa pada tanggal & MAPEL tertentu
  Future<List<Map<String, dynamic>>> getAbsensiByMapelTanggal(
    String kelasId,
    String mapelId,
    String tanggal,
  ) async {
    try {
      final response = await _supabase
          .from('absensi')
          .select()
          .eq('kelas_id', kelasId)
          .eq('mata_pelajaran_id', mapelId) // ✅ Filter by Mapel
          .eq('tanggal', tanggal);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error getAbsensiByMapelTanggal: $e');
      return [];
    }
  }

  /// Simpan Absensi (Bulk Upsert) dengan Mapel ID
  Future<void> saveAbsensiBatch(List<Map<String, dynamic>> dataAbsensi) async {
    try {
      await _supabase
          .from('absensi')
          .upsert(
            dataAbsensi,
            onConflict:
                'siswa_id, tanggal, mata_pelajaran_id', // ✅ Constraint Baru
          );
    } catch (e) {
      print('❌ Error saveAbsensiBatch: $e');
      rethrow;
    }
  }

  /// 👮 ADMIN: Ambil Rekap Nilai per Kelas & Mapel
  Future<List<Map<String, dynamic>>> getAdminRekapNilai({
    required String kelasId,
    required String mapelId,
    required String tahunId,
  }) async {
    try {
      // 1. Ambil Siswa di Kelas tersebut
      final resSiswa = await _supabase
          .from('siswa')
          .select('id, nama_lengkap, nisn')
          .eq('kelas_id', kelasId)
          .order('nama_lengkap', ascending: true);

      // 2. Ambil Data Nilai
      final resNilai = await _supabase
          .from('nilai')
          .select()
          .eq('kelas_id', kelasId)
          .eq('mata_pelajaran_id', mapelId)
          .eq('tahun_pelajaran_id', tahunId);

      // 3. Gabungkan Data (Mapping)
      List<Map<String, dynamic>> result = [];
      for (var siswa in resSiswa) {
        // ✅ PERBAIKAN: Gunakan .where() lalu cek isNotEmpty
        final cekData = resNilai.where((n) => n['siswa_id'] == siswa['id']);
        final nilaiData = cekData.isNotEmpty ? cekData.first : null;

        result.add({
          'siswa': siswa,
          'nilai': nilaiData, // Bisa null sekarang
        });
      }

      return result;
    } catch (e) {
      print('❌ Error getAdminRekapNilai: $e');
      rethrow;
    }
  }

  // --- FITUR WALI MURID ---
  Future<String?> getWaliMuridId(String profileId) async {
    final wali = await _supabase
        .from('wali_murid')
        .select('id')
        .eq('profile_id', profileId)
        .maybeSingle();

    return wali?['id'];
  }

  /// 1. Cari Data Siswa berdasarkan ID Wali (Profile ID login)
  Future<Map<String, dynamic>?> getSiswaByWaliId(String waliProfileId) async {
    try {
      // final waliMuridId = await getWaliMuridId(waliProfileId);
      // if (waliMuridId == null) return null;
      final response = await _supabase
          .from('siswa')
          .select('''
          *,
          kelas (
            id,
            nama_kelas
          ),
          wali_murid!inner (
            id,
            nama_lengkap,
            jenis_kelamin,
            pekerjaan,
            alamat,
            hubungan,
            profile_id,
            profiles (
              id,
              no_telepon,
              email
            )
            )
        ''')
          .eq('wali_murid.profile_id', waliProfileId)
          .maybeSingle();

      return response;
    } catch (e) {
      print('❌ Error getSiswaByWaliId: $e');
      return null;
    }
  }

  /// 2. Ambil Jadwal Pelajaran Siswa (Berdasarkan Kelas)
  Future<List<Map<String, dynamic>>> getJadwalSiswa(
    String kelasId,
    String tahunId,
  ) async {
    try {
      final response = await _supabase
          .from('jadwal_pelajaran')
          .select('*, mata_pelajaran(nama_mapel), guru(nama_lengkap)')
          .eq('kelas_id', kelasId)
          .eq('tahun_pelajaran_id', tahunId)
          .order('hari', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error getJadwalSiswa: $e');
      return [];
    }
  }

  /// 3. Ambil Absensi Siswa
  Future<List<Map<String, dynamic>>> getAbsensiSiswa(
    String siswaId,
    String tahunId,
  ) async {
    try {
      final response = await _supabase
          .from('absensi')
          .select('*, mata_pelajaran(nama_mapel)')
          .eq('siswa_id', siswaId)
          .eq('tahun_pelajaran_id', tahunId)
          .order('tanggal', ascending: false); // Terbaru diatas
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error getAbsensiSiswa: $e');
      return [];
    }
  }
}

//C:\Users\MSITHIN\monitoring_akademik\lib\data\services\supabase_service.dart
import 'package:monitoring_akademik/data/models/guru_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
//import '../models/guru_model.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ✅ TAMBAHKAN GETTER INI:
  SupabaseClient get supabase => _supabase;

  // ========================================
  // 🔐 AUTHENTICATION METHODS
  // ========================================

  /// Sign in dengan EMAIL saja
  Future<UserModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Langsung login ke Supabase Auth (tanpa cek username di database)
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Login gagal');
      }

      // ✅ Get user profile
      final profileResponse = await _supabase
          .from('profiles')
          .select()
          .eq('id', authResponse.user!.id)
          .single();

      return UserModel.fromJson(profileResponse);
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
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => UserModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error getAllUsers: $e');
      rethrow;
    }
  }

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
  Future<List<Map<String, dynamic>>> getAllGuru() async {
    try {
      print('📚 Fetching all guru...');
      final response = await _supabase
          .from('guru')
          .select('*, profiles:profile_id(email, no_telepon, foto_profil)')
          .order('created_at', ascending: false);

      print('✅ Fetched ${(response as List).length} guru');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error getAllGuru: $e');
      rethrow;
    }
  }

  /// Get guru by profile_id
  Future<Map<String, dynamic>?> getGuruByProfileId(String profileId) async {
    try {
      print('📚 Getting guru by profile ID: $profileId');
      final response = await _supabase
          .from('guru')
          .select('*, profiles:profile_id(email, no_telepon, foto_profil)')
          .eq('profile_id', profileId)
          .maybeSingle();

      // Fallback check on 'id' if profile_id match fails (legacy data support)
      if (response == null) {
        return await _supabase
            .from('guru')
            .select('*, profiles:profile_id(email, no_telepon, foto_profil)')
            .eq('id', profileId)
            .maybeSingle();
      }

      return response;
    } catch (e) {
      print('❌ Error getGuruByProfileId: $e');
      return null;
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

  /// Update guru profile (SIMPLIFIED - only basic fields)
  Future<bool> updateGuruProfile({
    required String guruId,
    required String nuptk,
    required String nama,
    String? nip,
    String? email,
    String? noTelp,
    String? alamat,
    String? pendidikanTerakhir,
  }) async {
    try {
      print('💾 Updating guru profile: $guruId');

      final guruUpdateData = <String, dynamic>{
        'nuptk': nuptk,
        'nama': nama,
        'nip': nip,
        'email': email,
        'no_telp': noTelp,
        'alamat': alamat,
        'pendidikan_terakhir': pendidikanTerakhir,
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
}

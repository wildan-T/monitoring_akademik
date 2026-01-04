//C:\Users\MSITHIN\monitoring_akademik\lib\data\services\supabase_service.dart
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

  /// Sign in dengan username ATAU email
  Future<UserModel?> signInWithUsernameOrEmail({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      String email = usernameOrEmail;

      // ✅ Jika bukan email, cari email dari username
      if (!usernameOrEmail.contains('@')) {
        final response = await _supabase
            .from('profiles')
            .select('email')
            .eq('username', usernameOrEmail)
            .maybeSingle();

        if (response == null) {
          throw Exception('Username tidak ditemukan');
        }

        email = response['email'] as String;
      }

      // ✅ Login dengan email
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
      print('❌ Error signInWithUsernameOrEmail: $e');
      rethrow;
    }
  }

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
      );

      if (authResponse.user == null) {
        throw Exception('Gagal membuat user di Auth');
      }

      final userId = authResponse.user!.id;

      // ✅ Step 2: Insert ke table profiles
      final profileData = {
        'id': userId,
        'username': username,
        'nama_lengkap': name,
        'email': email,
        'role': role,
        'no_telepon': phone,
        'is_active': false, // ✅ Default false, aktif setelah lengkapi profil
      };

      await _supabase.from('profiles').insert(profileData);

      // ✅ Step 3: Jika role = guru, create basic guru record
      if (role == 'guru') {
        final guruData = {
          'id': userId, // ✅ Same as user ID
          'nuptk': username, // ✅ Use username as temporary NUPTK
          'nama': name,
          'email': email,
          'no_telp': phone,
          // Field lain NULL, diisi saat lengkapi profil
        };

        await _supabase.from('guru').insert(guruData);
        print('✅ Basic guru record created');
      }

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

      await _supabase
          .from('profiles')
          .update(updateData)
          .eq('id', userId);

      // ✅ Jika role = guru, sync ke table guru
      if (role == 'guru') {
        final guruUpdateData = <String, dynamic>{};
        if (name != null) guruUpdateData['nama'] = name;
        if (email != null) guruUpdateData['email'] = email;
        if (phone != null) guruUpdateData['no_telp'] = phone;
        guruUpdateData['updated_at'] = DateTime.now().toIso8601String();

        await _supabase
            .from('guru')
            .update(guruUpdateData)
            .eq('id', userId);
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
      await _supabase
          .from('guru')
          .delete()
          .eq('id', userId);

      // ✅ Step 2: Delete dari profiles
      await _supabase
          .from('profiles')
          .delete()
          .eq('id', userId);

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
  // 👨‍🏫 GURU MANAGEMENT METHODS
  // ========================================

  /// Get all guru
  Future<List<Map<String, dynamic>>> getAllGuru() async {
    try {
      print('📚 Fetching all guru...');
      final response = await _supabase
          .from('guru')
          .select()
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
          .select()
          .eq('id', profileId)
          .maybeSingle();

      if (response != null) {
        print('✅ Guru found: ${response['nama']}');
      } else {
        print('⚠️ No guru found for profile ID: $profileId');
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
          .select()
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

      await _supabase
          .from('guru')
          .update(guruUpdateData)
          .eq('id', guruId);

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
  Future<List<Map<String, dynamic>>> getSiswaByWaliMuridId(String waliMuridId) async {
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
  Future<List<Map<String, dynamic>>> getAvailableKelasForWali({String? currentGuruId}) async {
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
          ? await _supabase.from('guru').select('wali_kelas').eq('id', currentGuruId).maybeSingle()
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
}
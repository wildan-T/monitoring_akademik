// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'dart:io';

// class ErrorHandler {
//   static String interpret(Object error) {
//     // 1. Error AUTH (Login/Register)
//     if (error is AuthException) {
//       // Cek berdasarkan pesan error atau kode error dari Supabase
//       if (error.message.toLowerCase().contains('invalid login credentials') ||
//           error.code == 'invalid_credentials') {
//         return 'Email atau kata sandi salah. Silakan cek kembali dan coba lagi.';
//       }

//       if (error.message.toLowerCase().contains('email not confirmed')) {
//         return 'Email belum diverifikasi. Silakan kotak Admin.';
//       }

//       if (error.message.toLowerCase().contains('user not found')) {
//         return 'Akun tidak ditemukan. Silakan kotak Admin.';
//       }

//       if (error.message.toLowerCase().contains('user already registered')) {
//         return 'Email sudah terdaftar. Silakan login.';
//       }

//       // Default Auth Error jika tidak ada yang cocok
//       return 'Terjadi kesalahan otentikasi: ${error.message}';
//     }

//     // 2. Error DATABASE (PostgrestException)
//     if (error is PostgrestException) {
//       // Kode Error PostgreSQL Umum:

//       // 23505: Unique Violation (Data ganda)
//       if (error.code == '23505') {
//         return 'Data sudah ada (Duplikat). Cek NISN atau data unik lainnya.';
//       }

//       // 23503: Foreign Key Violation (Data referensi tidak ditemukan)
//       if (error.code == '23503') {
//         return 'Data referensi tidak ditemukan. Pastikan data induk (Kelas/Mapel/Yang lain) ada.';
//       }

//       // 42P01: Undefined Table (Tabel tidak ada - jarang terjadi di production)
//       if (error.code == '42P01') {
//         return 'Terjadi kesalahan sistem (Tabel tidak ditemukan).';
//       }

//       // Default DB Error
//       return 'Gagal memproses data database: ${error.message}';
//     }

//     // 3. Error KONEKSI (Internet mati)
//     if (error is SocketException) {
//       return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
//     }

//     // 4. Error Formating (Misal: String dipaksa jadi Double)
//     if (error is FormatException) {
//       return 'Format data salah. Pastikan input format yang benar.';
//     }

//     // 5. Error Umum Lainnya
//     return 'Terjadi kesalahan: ${error.toString()}';
//   }
// }
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class ErrorHandler {
  static String interpret(Object error) {
    // ---------------------------------------------------------
    // 1. ERROR DARI EDGE FUNCTION (Supabase Functions)
    // ---------------------------------------------------------
    if (error is FunctionException) {
      // Error dari Edge Function biasanya tersimpan di 'details'
      // Format: { "error": "duplicate key value..." }
      final details = error.details;
      String rawMessage = '';

      if (details is Map && details.containsKey('error')) {
        rawMessage = details['error'].toString();
      } else {
        rawMessage = error.details.toString();
      }

      // Deteksi Pesan Error Spesifik dari SQL
      if (rawMessage.contains('duplicate key value')) {
        if (rawMessage.contains('nisn')) {
          return 'NISN sudah terdaftar. Silakan gunakan NISN lain.';
        }
        if (rawMessage.contains('nis')) {
          return 'NIS sudah terdaftar. Silakan gunakan NIS lain.';
        }
        if (rawMessage.contains('email')) {
          return 'Email sudah digunakan.';
        }
        return 'Data duplikat terdeteksi (sudah ada sebelumnya).';
      }

      // Deteksi Error Validasi lain
      if (error.status == 400) {
        return 'Data yang dikirim tidak valid. ($rawMessage)';
      }

      return 'Terjadi kesalahan sistem: $rawMessage';
    }

    // ---------------------------------------------------------
    // 2. ERROR AUTH (Login/Register langsung)
    // ---------------------------------------------------------
    if (error is AuthException) {
      if (error.message.toLowerCase().contains('invalid login credentials')) {
        return 'Email atau kata sandi salah.';
      }
      if (error.message.toLowerCase().contains('user already registered')) {
        return 'Email sudah terdaftar. Gunakan email lain.';
      }
      return 'Masalah otentikasi: ${error.message}';
    }

    // ---------------------------------------------------------
    // 3. ERROR DATABASE LANGSUNG (PostgrestException)
    // ---------------------------------------------------------
    if (error is PostgrestException) {
      // 23505: Unique Violation (Data ganda)
      if (error.code == '23505') {
        if (error.message.contains('nisn')) return 'NISN sudah terdaftar.';
        if (error.message.contains('nis')) return 'NIS sudah terdaftar.';
        return 'Data sudah ada (Duplikat).';
      }

      // 23503: Foreign Key Violation (Data referensi tidak ditemukan)
      if (error.code == '23503') {
        return 'Data referensi tidak ditemukan. (Misal: Kelas tidak valid).';
      }

      return 'Gagal memproses data database: ${error.message}';
    }

    // ---------------------------------------------------------
    // 4. ERROR KONEKSI
    // ---------------------------------------------------------
    if (error is SocketException) {
      return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
    }

    // ---------------------------------------------------------
    // 5. ERROR LAINNYA
    // ---------------------------------------------------------
    return 'Terjadi kesalahan: ${error.toString()}';
  }
}

//C:\Users\MSITHIN\monitoring_akademik\lib\main.dart
import 'package:flutter/material.dart';
import 'package:monitoring_akademik/presentation/providers/tahun_pelajaran_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:monitoring_akademik/core/config/supabase_config.dart';
import 'package:monitoring_akademik/core/theme/app_theme.dart';
import 'package:monitoring_akademik/core/constants/route_constants.dart';

// ✅ IMPORT SISWA MODEL
import 'package:monitoring_akademik/data/models/siswa_model.dart';
import 'package:monitoring_akademik/domain/entities/guru_entity.dart';
import 'package:monitoring_akademik/data/services/supabase_service.dart'; // ✅ NEW IMPORT

// Screens
import 'package:monitoring_akademik/presentation/screens/splash/splash_screen.dart';
import 'package:monitoring_akademik/presentation/screens/auth/login_screen.dart';
import 'package:monitoring_akademik/presentation/screens/admin/admin_dashboard_screen.dart';
import 'package:monitoring_akademik/presentation/screens/admin/kelola_user_screen.dart';
import 'package:monitoring_akademik/presentation/screens/admin/form_user_screen.dart';
import 'package:monitoring_akademik/presentation/screens/admin/guru/guru_list_screen.dart';
import 'package:monitoring_akademik/presentation/screens/admin/guru/guru_detail_screen.dart';
import 'package:monitoring_akademik/presentation/screens/guru/guru_dashboard_screen.dart';
import 'package:monitoring_akademik/presentation/screens/guru/lengkapi_profil_guru_screen.dart';
import 'package:monitoring_akademik/presentation/screens/guru/siswa/siswa_list_screen.dart';
import 'package:monitoring_akademik/presentation/screens/guru/siswa/siswa_detail_screen.dart';
import 'package:monitoring_akademik/presentation/screens/guru/absensi/absensi_input_screen.dart';
import 'package:monitoring_akademik/presentation/screens/guru/absensi/absensi_rekap_screen.dart';
import 'package:monitoring_akademik/presentation/screens/guru/nilai/nilai_input_screen.dart';
import 'package:monitoring_akademik/presentation/screens/guru/nilai/nilai_rekap_screen.dart';
import 'package:monitoring_akademik/presentation/screens/guru/nilai/finalisasi_nilai_screen.dart';
import 'package:monitoring_akademik/presentation/screens/wali_murid/wali_murid_dashboard_screen.dart';

// Providers
import 'package:monitoring_akademik/presentation/providers/auth_provider.dart';
import 'package:monitoring_akademik/presentation/providers/user_provider.dart';
import 'package:monitoring_akademik/presentation/providers/guru_provider.dart';
import 'package:monitoring_akademik/presentation/providers/siswa_provider.dart';
import 'package:monitoring_akademik/presentation/providers/sekolah_provider.dart';
import 'package:monitoring_akademik/presentation/providers/nilai_provider.dart';
import 'package:monitoring_akademik/presentation/providers/absensi_provider.dart';
import 'package:monitoring_akademik/presentation/providers/kelas_provider.dart';
import 'package:monitoring_akademik/presentation/providers/mata_pelajaran_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  print('✅ Supabase initialized successfully');
  print('🔗 URL: ${SupabaseConfig.supabaseUrl}');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => GuruProvider()),
        ChangeNotifierProvider(
          create: (_) => SiswaProvider(SupabaseService()),
        ), // ✅ FIXED
        ChangeNotifierProvider(create: (_) => KelasProvider()),
        ChangeNotifierProvider(create: (_) => MataPelajaranProvider()),
        ChangeNotifierProvider(create: (_) => TahunPelajaranProvider()),
        ChangeNotifierProvider(
          create: (_) => NilaiProvider(SupabaseService()),
        ), // ✅ FIXED
        ChangeNotifierProvider(
          create: (_) => AbsensiProvider(SupabaseService()),
        ), // ✅ FIXED
        ChangeNotifierProvider(create: (_) => SekolahProvider()),
      ],
      child: MaterialApp(
        title: 'Monitoring Akademik SMPN 20',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: RouteConstants.splash,
        routes: {
          RouteConstants.splash: (context) => const SplashScreen(),
          RouteConstants.login: (context) => const LoginScreen(),
          RouteConstants.adminDashboard: (context) =>
              const AdminDashboardScreen(),
          RouteConstants.guruDashboard: (context) =>
              const GuruDashboardScreen(),
          RouteConstants.waliMuridDashboard: (context) =>
              const WaliMuridDashboardScreen(),
          '/admin/kelola-user': (context) => const KelolaUserScreen(),
          '/admin/form-user': (context) => const FormUserScreen(),
          '/admin/guru-list': (context) => const GuruListScreen(),
          '/lengkapi-profil-guru': (context) =>
              const LengkapiProfilGuruScreen(),
          '/guru-siswa-list': (context) => const SiswaListScreen(),
          '/guru-absensi-input': (context) => const AbsensiInputScreen(),
          '/guru-absensi-rekap': (context) => const AbsensiRekapScreen(),
          '/guru-finalisasi-nilai': (context) => const FinalisasiNilaiScreen(),
        },
        onGenerateRoute: (settings) {
          // GuruDetailScreen - ✅ FIX TYPE CASTING
          if (settings.name == '/admin/guru-detail') {
            final guru = settings.arguments as GuruEntity;
            return MaterialPageRoute(
              builder: (context) => GuruDetailScreen(guru: guru),
            );
          }

          // SiswaDetailScreen - ✅ FIXED: Changed from List<SiswaModel> to SiswaModel
          if (settings.name == '/guru-siswa-detail') {
            final siswa =
                settings.arguments as SiswaModel; // ✅ Single object, not list!
            return MaterialPageRoute(
              builder: (context) => SiswaDetailScreen(siswa: siswa),
            );
          }

          // NilaiInputScreen - ✅ FIX MISSING PARAMETERS
          if (settings.name == '/guru-nilai-input') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => NilaiInputScreen(
                guruId: args['guruId'] as String,
                kelas: args['kelas'] as String,
                mataPelajaran: args['mataPelajaran'] as String,
                siswa: args['siswa'] as List<SiswaModel>,
              ),
            );
          }

          // NilaiRekapScreen
          if (settings.name == '/guru-nilai-rekap') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => NilaiRekapScreen(
                kelas: args['kelas'] as String,
                mataPelajaran: args['mataPelajaran'] as String,
              ),
            );
          }

          return null;
        },
      ),
    );
  }
}

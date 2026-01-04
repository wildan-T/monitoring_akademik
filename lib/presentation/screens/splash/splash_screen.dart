//C:\Users\MSITHIN\monitoring_akademik\lib\presentation\screens\splash\splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/color_constants.dart';
import '../../../core/constants/route_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/guru_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      final authProvider = context.read<AuthProvider>();
      final guruProvider = context.read<GuruProvider>();
      
      print('🔍 Checking auth status...');
      
      // ✅ FIX: Remove if, just call directly (returns void)
      await authProvider.checkAuthStatus();
      
      if (!mounted) return;
      
      final user = authProvider.currentUser;
      print('👤 Current user: ${user?.name}');
      print('🎭 Role: ${user?.role}');
      
      if (user != null) {
        // ✅ Load guru profile if role is guru
        if (user.role == AppConstants.roleGuru) {
          print('📚 Loading guru profile...');
          await guruProvider.fetchGuruByProfileId(user.id);
          
          if (!mounted) return;
          
          // Check if profile complete
          if (!user.isActive) {
            print('⚠️ Guru profile incomplete');
            Navigator.pushReplacementNamed(context, RouteConstants.lengkapiProfilGuru);
            return;
          }
        }
        
        // Navigate based on role
        _navigateByRole(user.role);
      } else {
        print('❌ No authenticated user');
        Navigator.pushReplacementNamed(context, RouteConstants.login);
      }
    }
  }

  void _navigateByRole(String role) {
    print('📍 Navigating by role: $role');
    
    switch (role) {
      case AppConstants.roleAdmin:
        Navigator.pushReplacementNamed(context, RouteConstants.adminDashboard);
        break;
      case AppConstants.roleGuru:
        Navigator.pushReplacementNamed(context, RouteConstants.guruDashboard);
        break;
      case AppConstants.roleWali:
        Navigator.pushReplacementNamed(context, RouteConstants.waliMuridDashboard);
        break;
      default:
        Navigator.pushReplacementNamed(context, RouteConstants.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school,
                size: 100,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 8),
            
            const Text(
              AppConstants.schoolName,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Monitoring Akademik is a Flutter cross-platform application for academic monitoring at SMPN 20 Tangerang. It tracks student attendance, grades, and provides dashboards for administrators, teachers, and parents.

## Build & Run Commands

```bash
# Get dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Build for specific platforms
flutter build apk          # Android APK
flutter build appbundle    # Android App Bundle
flutter build web          # Web

# Run tests
flutter test               # All tests
flutter test test/widget_test.dart  # Single test file

# Analyze code
flutter analyze

# Generate launcher icons (after modifying pubspec.yaml)
flutter pub run flutter_launcher_icons
```

## Architecture

The app follows Clean Architecture with MVVM pattern using Provider for state management:

```
lib/
├── core/           # Config, constants (roles, colors, routes), theme
├── data/
│   ├── models/     # Data models with fromJson/toJson
│   └── services/   # Supabase CRUD operations, import/export
├── domain/
│   └── entities/   # Plain entity classes
└── presentation/
    ├── providers/  # Provider classes for state management
    ├── screens/    # UI screens organized by role (admin/, guru/, wali_murid/)
    └── widgets/    # Reusable UI components
```

## Key Patterns

### User Roles
Three roles defined in `AppConstants` (must match Supabase `profiles.role`):
- `super_admin` - Full system access, user management
- `guru` - Teacher: input attendance/grades for assigned classes
- `wali_murid` - Parent: view child's academic data

### Supabase Integration
- All database operations go through `SupabaseService` (`lib/data/services/supabase_service.dart`)
- Config in `lib/core/config/supabase_config.dart`
- Tables: `profiles`, `guru`, `peserta_didik` (students), `kelas`, `mata_pelajaran`, `nilai`, `absensi`, `sekolah`

### Student-Parent Account Linking
When creating a student (`createSiswaWithWali`):
1. System checks if parent account exists by email
2. If not, creates `wali_murid` account (default password = student's NISN)
3. Links student to parent via `wali_murid_id`

### Teacher Profile Flow
New teacher accounts have `is_active: false`. Teachers must complete their profile (`LengkapiProfilGuruScreen`) before accessing the main dashboard.

## Database Schema Notes

- `profiles` table stores auth user data (id links to Supabase Auth)
- `guru` table has same `id` as `profiles` for teachers
- `peserta_didik.wali_murid_id` references `profiles.id` of parent
- `nilai` stores grades with `siswa_id`, `mapel_id`, `guru_id`, `semester`

// lib/core/config/supabase_config.dart
class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://kkywctkrutscjelgfahc.supabase.co',
  );
  
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtreXdjdGtydXRzY2plbGdmYWhjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA3NzE4NzYsImV4cCI6MjA3NjM0Nzg3Nn0.vJkZTP4QCCMctFR_IbkyFHzJqMb8MRXGpFb7k9ytTS8',
  );
}
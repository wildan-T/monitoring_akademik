//C:\Users\MSITHIN\monitoring_akademik\lib\domain\entities\user_entity.dart
class UserEntity {
  final String id;
  final String username;
  final String name;
  final String email; // ✅ WAJIB (bukan optional)
  final String role;
  final String? phone;
  final String? photoUrl; // ✅ TAMBAH
  final bool isActive;    // ✅ TAMBAH

  UserEntity({
    required this.id,
    required this.username,
    required this.name,
    required this.email, // ✅ WAJIB
    required this.role,
    this.phone,
    this.photoUrl, // ✅ TAMBAH
    this.isActive = true, // ✅ TAMBAH
  });

  // ✅ Equality comparison (untuk Provider state management)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity &&
        other.id == id &&
        other.username == username &&
        other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ username.hashCode ^ email.hashCode;
}
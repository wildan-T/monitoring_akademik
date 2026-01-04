//C:\Users\MSITHIN\monitoring_akademik\lib\data\models\user_model.dart
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.username,
    required super.name,
    required super.email, // ✅ WAJIB
    required super.role,
    super.phone,
    super.photoUrl, // ✅ TAMBAH
    super.isActive,  // ✅ TAMBAH
  });

  // ✅ Factory: Supabase JSON → Model
  //factory UserModel.fromJson(Map<String, dynamic> json) {
    //return UserModel(
      //id: json['id'] as String,
      //username: json['username'] as String? ?? '',
      //name: json['nama_lengkap'] as String? ?? 'User', // ✅ Supabase field
      //email: json['email'] as String? ?? '',
    //  role: json['role'] as String? ?? 'wali',
     // phone: json['no_telepon'] as String?, // ✅ Supabase field
      //photoUrl: json['foto_profil'] as String?, // ✅ Supabase field
      //isActive: json['is_active'] as bool? ?? true, // ✅ Supabase field
    //);
  //}

  // DARI CHAT GPT 

  factory UserModel.fromJson(Map<String, dynamic> json) {
  return UserModel(
    id: json['id']?.toString() ?? '',
    username: json['username']?.toString() ?? '',
    name: json['nama_lengkap']?.toString() ?? '',
    email: json['email']?.toString() ?? '', // FIX
    role: json['role']?.toString() ?? '',
    phone: json['no_telepon']?.toString(),
    photoUrl: json['photo_url']?.toString(),
    isActive: json['is_active'] == true,
  );
}


  // ✅ Factory: Entity → Model
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      username: entity.username,
      name: entity.name,
      email: entity.email,
      role: entity.role,
      phone: entity.phone,
      photoUrl: entity.photoUrl,
      isActive: entity.isActive,
    );
  }

  // ✅ Method: Model → Supabase JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nama_lengkap': name, // ✅ Supabase field
      'email': email,
      'role': role,
      'no_telepon': phone, // ✅ Supabase field
      'foto_profil': photoUrl, // ✅ Supabase field
      'is_active': isActive, // ✅ Supabase field
    };
  }

  // ✅ CopyWith (returns Model)
  UserModel copyWith({
    String? id,
    String? username,
    String? name,
    String? email,
    String? role,
    String? phone,
    String? photoUrl,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      isActive: isActive ?? this.isActive,
    );
  }
}
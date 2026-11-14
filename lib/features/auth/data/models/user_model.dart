import '../../domain/entities/user_entity.dart';

/// Data Transfer Model for User serialization.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.plan,
    required super.status,
    required super.resumeCredits,
    required super.atsCredits,
    super.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'USER',
      plan: json['plan']?.toString() ?? 'FREE',
      status: json['status']?.toString() ?? 'ACTIVE',
      resumeCredits: json['resumeCredits'] is int ? json['resumeCredits'] : 10,
      atsCredits: json['atsCredits'] is int ? json['atsCredits'] : 5,
      profileImage: json['profileImage']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'plan': plan,
      'status': status,
      'resumeCredits': resumeCredits,
      'atsCredits': atsCredits,
      'profileImage': profileImage,
    };
  }
}

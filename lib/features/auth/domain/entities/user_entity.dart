/// Domain Entity for authenticated user.
class UserEntity {
  final String id;
  final String name;
  final String email;
  final String role;
  final String plan;
  final String status;
  final int resumeCredits;
  final int atsCredits;
  final String? profileImage;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.plan,
    required this.status,
    required this.resumeCredits,
    required this.atsCredits,
    this.profileImage,
  });

  bool get isBlocked => status == 'BLOCKED';
  bool get isPro => plan == 'PRO';

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? plan,
    String? status,
    int? resumeCredits,
    int? atsCredits,
    String? profileImage,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      resumeCredits: resumeCredits ?? this.resumeCredits,
      atsCredits: atsCredits ?? this.atsCredits,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}

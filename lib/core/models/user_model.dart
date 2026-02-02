class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'student', 'owner', 'provider', 'admin'
  final String? profileImage;
  final String? address;
  final String? university;
  final String? nid; // National ID (13 digits)
  final bool isVerified; // Verified by admin
  final DateTime? verifiedAt;
  final String? verifiedBy; // Admin ID who verified
  final double rating;
  final int reviewCount;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage,
    this.address,
    this.university,
    this.nid,
    this.isVerified = false,
    this.verifiedAt,
    this.verifiedBy,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      profileImage: json['profileImage'] as String?,
      address: json['address'] as String?,
      university: json['university'] as String?,
      nid: json['nid'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
      verifiedAt: json['verifiedAt'] != null ? DateTime.parse(json['verifiedAt'] as String) : null,
      verifiedBy: json['verifiedBy'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'profileImage': profileImage,
      'address': address,
      'university': university,
      'nid': nid,
      'isVerified': isVerified,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'verifiedBy': verifiedBy,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? profileImage,
    String? address,
    String? university,
    String? nid,
    bool? isVerified,
    DateTime? verifiedAt,
    String? verifiedBy,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      address: address ?? this.address,
      university: university ?? this.university,
      nid: nid ?? this.nid,
      isVerified: isVerified ?? this.isVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

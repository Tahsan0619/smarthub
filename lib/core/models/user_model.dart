class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'student', 'owner', 'provider'
  final String? profileImage;
  final String? address;
  final String? university;
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
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum ServiceCategory { food, medicine, furniture, tuition }

class ServiceModel {
  final String id;
  final String providerId;
  final String providerName;
  final String providerPhone;
  final String name;
  final String description;
  final double price;
  final ServiceCategory category;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final DateTime createdAt;
  final String? deliveryTime;
  
  // Tuition-specific fields
  final String? subject;
  final String? qualifications;
  final String? experienceLevel; // beginner, intermediate, advanced
  final int? sessionDurationMinutes;
  final List<String>? availability; // e.g., ['Monday', 'Wednesday', 'Friday']

  ServiceModel({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.providerPhone,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.images = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isAvailable = true,
    required this.createdAt,
    this.deliveryTime,
    this.subject,
    this.qualifications,
    this.experienceLevel,
    this.sessionDurationMinutes,
    this.availability,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      providerId: json['providerId'] as String,
      providerName: json['providerName'] as String,
      providerPhone: json['providerPhone'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      category: ServiceCategory.values.firstWhere(
        (e) => e.toString() == 'ServiceCategory.${json['category']}',
      ),
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? 
              ((json['image'] as String?) != null ? [json['image'] as String] : []),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      isAvailable: json['isAvailable'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      deliveryTime: json['deliveryTime'] as String?,
      subject: json['subject'] as String?,
      qualifications: json['qualifications'] as String?,
      experienceLevel: json['experienceLevel'] as String?,
      sessionDurationMinutes: json['sessionDurationMinutes'] as int?,
      availability: (json['availability'] as List<dynamic>?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'providerId': providerId,
      'providerName': providerName,
      'providerPhone': providerPhone,
      'name': name,
      'description': description,
      'price': price,
      'category': category.toString().split('.').last,
      'images': images,
      'rating': rating,
      'reviewCount': reviewCount,
      'isAvailable': isAvailable,
      'createdAt': createdAt.toIso8601String(),
      'deliveryTime': deliveryTime,
      'subject': subject,
      'qualifications': qualifications,
      'experienceLevel': experienceLevel,
      'sessionDurationMinutes': sessionDurationMinutes,
      'availability': availability,
    };
  }

  ServiceModel copyWith({
    String? id,
    String? providerId,
    String? providerName,
    String? providerPhone,
    String? name,
    String? description,
    double? price,
    ServiceCategory? category,
    List<String>? images,
    double? rating,
    int? reviewCount,
    bool? isAvailable,
    DateTime? createdAt,
    String? deliveryTime,
    String? subject,
    String? qualifications,
    String? experienceLevel,
    int? sessionDurationMinutes,
    List<String>? availability,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      providerPhone: providerPhone ?? this.providerPhone,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      subject: subject ?? this.subject,
      qualifications: qualifications ?? this.qualifications,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      sessionDurationMinutes: sessionDurationMinutes ?? this.sessionDurationMinutes,
      availability: availability ?? this.availability,
    );
  }
}

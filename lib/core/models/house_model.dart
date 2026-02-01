class HouseModel {
  final String id;
  final String ownerId;
  final String ownerName;
  final String ownerPhone;
  final String title;
  final String description;
  final double rent;
  final String location;
  final String area;
  final double latitude;
  final double longitude;
  final int bedrooms;
  final int bathrooms;
  final List<String> images;
  final List<String> facilities;
  final String status; // 'available', 'booked', 'limited'
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final bool hasWifi;
  final double distanceFromCampus;
  final String roomType; // 'Single Room' or 'Shared Room'

  HouseModel({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.ownerPhone,
    required this.title,
    required this.description,
    required this.rent,
    required this.location,
    required this.area,
    required this.latitude,
    required this.longitude,
    required this.bedrooms,
    required this.bathrooms,
    required this.images,
    required this.facilities,
    this.status = 'available',
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
    this.hasWifi = false,
    this.distanceFromCampus = 0.0,
    this.roomType = 'Single Room',
  });

  // Getter for distance (alias for distanceFromCampus)
  double get distance => distanceFromCampus;

  factory HouseModel.fromJson(Map<String, dynamic> json) {
    return HouseModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      ownerName: json['ownerName'] as String,
      ownerPhone: json['ownerPhone'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      rent: (json['rent'] as num).toDouble(),
      location: json['location'] as String,
      area: json['area'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      bedrooms: json['bedrooms'] as int,
      bathrooms: json['bathrooms'] as int,
      images: List<String>.from(json['images'] as List),
      facilities: List<String>.from(json['facilities'] as List),
      status: json['status'] as String? ?? 'available',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      hasWifi: json['hasWifi'] as bool? ?? false,
      distanceFromCampus: (json['distanceFromCampus'] as num?)?.toDouble() ?? 0.0,
      roomType: json['roomType'] as String? ?? 'Single Room',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerPhone': ownerPhone,
      'title': title,
      'description': description,
      'rent': rent,
      'location': location,
      'area': area,
      'latitude': latitude,
      'longitude': longitude,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'images': images,
      'facilities': facilities,
      'status': status,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt.toIso8601String(),
      'hasWifi': hasWifi,
      'distanceFromCampus': distanceFromCampus,
      'roomType': roomType,
    };
  }

  HouseModel copyWith({
    String? id,
    String? ownerId,
    String? ownerName,
    String? ownerPhone,
    String? title,
    String? description,
    double? rent,
    String? location,
    String? area,
    double? latitude,
    double? longitude,
    int? bedrooms,
    int? bathrooms,
    List<String>? images,
    List<String>? facilities,
    String? status,
    double? rating,
    int? reviewCount,
    DateTime? createdAt,
    bool? hasWifi,
    double? distanceFromCampus,
    String? roomType,
  }) {
    return HouseModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerPhone: ownerPhone ?? this.ownerPhone,
      title: title ?? this.title,
      description: description ?? this.description,
      rent: rent ?? this.rent,
      location: location ?? this.location,
      area: area ?? this.area,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      images: images ?? this.images,
      facilities: facilities ?? this.facilities,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      hasWifi: hasWifi ?? this.hasWifi,
      distanceFromCampus: distanceFromCampus ?? this.distanceFromCampus,
      roomType: roomType ?? this.roomType,
    );
  }
}

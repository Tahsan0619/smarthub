class ReviewModel {
  final String id;
  final String? serviceId;  // Null if reviewing house
  final String? houseId;    // Null if reviewing service
  final String studentId;
  final String studentName;
  final double rating; // 1-5 stars
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    this.serviceId,
    this.houseId,
    required this.studentId,
    required this.studentName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  ReviewModel copyWith({
    String? id,
    String? serviceId,
    String? houseId,
    String? studentId,
    String? studentName,
    double? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      houseId: houseId ?? this.houseId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      serviceId: json['serviceId'] as String?,
      houseId: json['houseId'] as String?,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'houseId': houseId,
      'studentId': studentId,
      'studentName': studentName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

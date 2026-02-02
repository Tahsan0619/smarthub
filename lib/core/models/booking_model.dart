class BookingModel {
  final String id;
  final String houseId;
  final String studentId;
  final String studentName;
  final String studentPhone;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;
  final String? notes;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final double? totalAmount;

  BookingModel({
    required this.id,
    required this.houseId,
    required this.studentId,
    required this.studentName,
    required this.studentPhone,
    this.status = 'pending',
    required this.createdAt,
    this.notes,
    this.checkInDate,
    this.checkOutDate,
    this.totalAmount,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      houseId: json['houseId'] as String,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      studentPhone: json['studentPhone'] as String,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] as String),
      notes: json['notes'] as String?,
      checkInDate: json['checkInDate'] != null ? DateTime.parse(json['checkInDate'] as String) : null,
      checkOutDate: json['checkOutDate'] != null ? DateTime.parse(json['checkOutDate'] as String) : null,
      totalAmount: json['totalAmount'] != null ? (json['totalAmount'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'houseId': houseId,
      'studentId': studentId,
      'studentName': studentName,
      'studentPhone': studentPhone,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
      'checkInDate': checkInDate?.toIso8601String(),
      'checkOutDate': checkOutDate?.toIso8601String(),
      'totalAmount': totalAmount,
    };
  }

  BookingModel copyWith({
    String? id,
    String? houseId,
    String? studentId,
    String? studentName,
    String? studentPhone,
    String? status,
    DateTime? createdAt,
    String? notes,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    double? totalAmount,
  }) {
    return BookingModel(
      id: id ?? this.id,
      houseId: houseId ?? this.houseId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentPhone: studentPhone ?? this.studentPhone,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}

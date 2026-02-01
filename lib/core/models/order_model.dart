class OrderModel {
  final String id;
  final String serviceId;
  final String studentId;
  final String studentName;
  final String studentPhone;
  final String studentAddress;
  final String providerId;
  final String serviceName;
  final double price;
  final int quantity;
  final String status; // 'pending', 'confirmed', 'delivered', 'cancelled'
  final DateTime createdAt;
  final String? notes;

  OrderModel({
    required this.id,
    required this.serviceId,
    required this.studentId,
    required this.studentName,
    required this.studentPhone,
    required this.studentAddress,
    required this.providerId,
    required this.serviceName,
    required this.price,
    this.quantity = 1,
    this.status = 'pending',
    required this.createdAt,
    this.notes,
  });

  double get totalPrice => price * quantity;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      serviceId: json['serviceId'] as String,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      studentPhone: json['studentPhone'] as String,
      studentAddress: json['studentAddress'] as String,
      providerId: json['providerId'] as String,
      serviceName: json['serviceName'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int? ?? 1,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'studentId': studentId,
      'studentName': studentName,
      'studentPhone': studentPhone,
      'studentAddress': studentAddress,
      'providerId': providerId,
      'serviceName': serviceName,
      'price': price,
      'quantity': quantity,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
    };
  }

  OrderModel copyWith({
    String? id,
    String? serviceId,
    String? studentId,
    String? studentName,
    String? studentPhone,
    String? studentAddress,
    String? providerId,
    String? serviceName,
    double? price,
    int? quantity,
    String? status,
    DateTime? createdAt,
    String? notes,
  }) {
    return OrderModel(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentPhone: studentPhone ?? this.studentPhone,
      studentAddress: studentAddress ?? this.studentAddress,
      providerId: providerId ?? this.providerId,
      serviceName: serviceName ?? this.serviceName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }
}

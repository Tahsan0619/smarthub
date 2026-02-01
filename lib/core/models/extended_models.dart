class ReviewModel {
  final String id;
  final String itemId;
  final String itemType; // 'house', 'service'
  final String reviewerId;
  final String reviewerName;
  final String reviewerImage;
  final double rating;
  final String title;
  final String comment;
  final List<String>? images;
  final int helpfulCount;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.itemId,
    required this.itemType,
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewerImage,
    required this.rating,
    required this.title,
    required this.comment,
    this.images,
    this.helpfulCount = 0,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      itemId: json['itemId'] as String,
      itemType: json['itemType'] as String,
      reviewerId: json['reviewerId'] as String,
      reviewerName: json['reviewerName'] as String,
      reviewerImage: json['reviewerImage'] as String,
      rating: (json['rating'] as num).toDouble(),
      title: json['title'] as String,
      comment: json['comment'] as String,
      images: (json['images'] as List?)?.cast<String>(),
      helpfulCount: json['helpfulCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemId': itemId,
      'itemType': itemType,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'reviewerImage': reviewerImage,
      'rating': rating,
      'title': title,
      'comment': comment,
      'images': images,
      'helpfulCount': helpfulCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ComplaintModel {
  final String id;
  final String userId;
  final String userName;
  final String category; // 'property', 'service', 'user', 'other'
  final String subject;
  final String description;
  final String status; // 'open', 'in_review', 'resolved', 'closed'
  final int priority; // 1-5
  final String? resolution;
  final List<String>? attachments;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  ComplaintModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.category,
    required this.subject,
    required this.description,
    this.status = 'open',
    this.priority = 3,
    this.resolution,
    this.attachments,
    required this.createdAt,
    this.resolvedAt,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      category: json['category'] as String,
      subject: json['subject'] as String,
      description: json['description'] as String,
      status: json['status'] as String? ?? 'open',
      priority: json['priority'] as int? ?? 3,
      resolution: json['resolution'] as String?,
      attachments: (json['attachments'] as List?)?.cast<String>(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'category': category,
      'subject': subject,
      'description': description,
      'status': status,
      'priority': priority,
      'resolution': resolution,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }
}

class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String senderImage;
  final String recipientId;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderImage,
    required this.recipientId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderImage: json['senderImage'] as String,
      recipientId: json['recipientId'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'senderImage': senderImage,
      'recipientId': recipientId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'imageUrl': imageUrl,
    };
  }
}

class ConversationModel {
  final String id;
  final String userId1;
  final String user1Name;
  final String user1Image;
  final String userId2;
  final String user2Name;
  final String user2Image;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  ConversationModel({
    required this.id,
    required this.userId1,
    required this.user1Name,
    required this.user1Image,
    required this.userId2,
    required this.user2Name,
    required this.user2Image,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });
}

class PaymentModel {
  final String id;
  final String userId;
  final String itemId;
  final String itemType; // 'booking', 'order'
  final double amount;
  final String paymentMethod; // 'card', 'cod', 'mobile_banking'
  final String status; // 'pending', 'completed', 'failed'
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? transactionId;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.itemType,
    required this.amount,
    required this.paymentMethod,
    this.status = 'pending',
    required this.createdAt,
    this.completedAt,
    this.transactionId,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      itemId: json['itemId'] as String,
      itemType: json['itemType'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      transactionId: json['transactionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'itemId': itemId,
      'itemType': itemType,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'transactionId': transactionId,
    };
  }
}

class AnalyticsModel {
  final String id;
  final String userId;
  final int totalViews;
  final int totalBookings;
  final int totalRevenue;
  final int activeListings;
  final double averageRating;
  final DateTime lastUpdated;

  AnalyticsModel({
    required this.id,
    required this.userId,
    this.totalViews = 0,
    this.totalBookings = 0,
    this.totalRevenue = 0,
    this.activeListings = 0,
    this.averageRating = 0.0,
    required this.lastUpdated,
  });
}

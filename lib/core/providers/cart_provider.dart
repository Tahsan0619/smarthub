import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_model.dart';

class CartItem {
  final ServiceModel service;
  int quantity;

  CartItem({
    required this.service,
    this.quantity = 1,
  });

  double get subtotal => service.price * quantity;

  CartItem copyWith({
    ServiceModel? service,
    int? quantity,
  }) {
    return CartItem(
      service: service ?? this.service,
      quantity: quantity ?? this.quantity,
    );
  }
}

class ServiceOrder {
  final String id;
  final String studentId;
  final String studentName;
  final String studentPhone;
  final List<CartItem> items;
  final double totalAmount;
  final String status; // pending, approved, rejected
  final DateTime createdAt;

  ServiceOrder({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentPhone,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  ServiceOrder copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? studentPhone,
    List<CartItem>? items,
    double? totalAmount,
    String? status,
    DateTime? createdAt,
  }) {
    return ServiceOrder(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentPhone: studentPhone ?? this.studentPhone,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Cart Provider
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addToCart(ServiceModel service) {
    final existingIndex = state.indexWhere((item) => item.service.id == service.id);
    
    if (existingIndex >= 0) {
      // Update quantity if item already in cart
      state = [
        ...state.sublist(0, existingIndex),
        state[existingIndex].copyWith(quantity: state[existingIndex].quantity + 1),
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      // Add new item
      state = [...state, CartItem(service: service)];
    }
  }

  void removeFromCart(String serviceId) {
    state = state.where((item) => item.service.id != serviceId).toList();
  }

  void updateQuantity(String serviceId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(serviceId);
      return;
    }
    
    state = [
      for (final item in state)
        if (item.service.id == serviceId)
          item.copyWith(quantity: quantity)
        else
          item,
    ];
  }

  void clearCart() {
    state = [];
  }

  double getTotal() {
    return state.fold(0.0, (sum, item) => sum + item.subtotal);
  }
}

// Service Orders Provider
final serviceOrdersProvider = StateNotifierProvider<ServiceOrdersNotifier, List<ServiceOrder>>((ref) {
  return ServiceOrdersNotifier();
});

class ServiceOrdersNotifier extends StateNotifier<List<ServiceOrder>> {
  ServiceOrdersNotifier() : super([]);

  void addOrder(ServiceOrder order) {
    state = [...state, order];
  }

  void updateOrder(ServiceOrder order) {
    state = [
      for (final o in state)
        if (o.id == order.id) order else o,
    ];
  }

  void deleteOrder(String orderId) {
    state = state.where((o) => o.id != orderId).toList();
  }

  List<ServiceOrder> getStudentOrders(String studentId) {
    return state.where((o) => o.studentId == studentId).toList();
  }

  List<ServiceOrder> getProviderOrders(String providerId, List<ServiceModel> providerServices) {
    final serviceIds = providerServices.map((s) => s.id).toSet();
    return state.where((order) =>
      order.items.any((item) => serviceIds.contains(item.service.id))
    ).toList();
  }

  List<ServiceOrder> getPendingOrders() {
    return state.where((o) => o.status == 'pending').toList();
  }
}

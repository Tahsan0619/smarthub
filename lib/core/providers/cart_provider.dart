import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_model.dart';
import '../services/supabase_service.dart';
import 'data_providers.dart';

void _log(String message) {
  // ignore: avoid_print
  print('[CartProvider] $message');
}

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

// Cart Provider - local state for UI (before checkout)
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier(ref);
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  final Ref ref;
  
  CartNotifier(this.ref) : super([]);

  void addToCart(ServiceModel service) {
    _log('addToCart -> ${service.name}');
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
    _log('removeFromCart -> $serviceId');
    state = state.where((item) => item.service.id != serviceId).toList();
  }

  void updateQuantity(String serviceId, int quantity) {
    _log('updateQuantity -> $serviceId: $quantity');
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
    _log('clearCart');
    state = [];
  }

  double getTotal() {
    return state.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  int get itemCount => state.length;

  int getTotalQuantity() {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }

  // Checkout - creates orders in Supabase
  Future<void> checkout({
    required String studentId,
    required String studentName,
    required String studentPhone,
    required String deliveryAddress,
    String? notes,
  }) async {
    if (state.isEmpty) {
      throw Exception('Cart is empty');
    }

    _log('checkout -> start');
    
    try {
      // Group cart items by provider
      final Map<String, List<CartItem>> itemsByProvider = {};
      for (final item in state) {
        final providerId = item.service.providerId;
        if (!itemsByProvider.containsKey(providerId)) {
          itemsByProvider[providerId] = [];
        }
        itemsByProvider[providerId]!.add(item);
      }

      // Create an order for each provider
      for (final entry in itemsByProvider.entries) {
        final providerId = entry.key;
        final items = entry.value;
        final totalAmount = items.fold(0.0, (sum, item) => sum + item.subtotal);

        _log('Creating order for provider: $providerId with ${items.length} items');
        
        await SupabaseService.createOrderWithItems(
          studentId: studentId,
          providerId: providerId,
          totalAmount: totalAmount,
          deliveryAddress: deliveryAddress,
          notes: notes,
          items: items.map((item) => {
            'service_id': item.service.id,
            'quantity': item.quantity,
            'price': item.service.price,
            'subtotal': item.subtotal,
          }).toList(),
        );
      }

      _log('checkout -> success');
      
      // Clear cart after successful checkout
      state = [];
      
      // Reload orders to reflect new data
      ref.read(ordersProvider.notifier).loadOrders();
    } catch (e) {
      _log('checkout -> error: $e');
      rethrow;
    }
  }
}

// Cart total provider
final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + item.subtotal);
});

// Cart item count provider
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.length;
});

// Cart total quantity provider
final cartTotalQuantityProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});

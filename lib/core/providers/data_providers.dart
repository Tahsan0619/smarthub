import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/house_model.dart';
import '../models/service_model.dart';
import '../models/booking_model.dart';
import '../models/order_model.dart';
import '../models/review_model.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

void _log(String message) {
  // ignore: avoid_print
  print('[DataProviders] $message');
}

// =====================================================
// HOUSES/PROPERTIES PROVIDER
// =====================================================

final housesProvider = StateNotifierProvider<HousesNotifier, AsyncValue<List<HouseModel>>>((ref) {
  return HousesNotifier(ref);
});

class HousesNotifier extends StateNotifier<AsyncValue<List<HouseModel>>> {
  final Ref ref;
  RealtimeChannel? _subscription;

  HousesNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadHouses();
    _subscribeToChanges();
  }

  Future<void> loadHouses() async {
    try {
      _log('loadHouses -> start');
      state = const AsyncValue.loading();
      final data = await SupabaseService.getAllProperties();
      final houses = data.map((e) => _mapToHouseModel(e)).toList();
      state = AsyncValue.data(houses);
      _log('loadHouses -> loaded ${houses.length} houses');
    } catch (e, st) {
      _log('loadHouses -> error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  void _subscribeToChanges() {
    _subscription = SupabaseService.subscribeToProperties((payload) {
      _log('houses realtime update received');
      loadHouses();
    });
  }

  HouseModel _mapToHouseModel(Map<String, dynamic> data) {
    final owner = data['owner'] as Map<String, dynamic>?;
    return HouseModel(
      id: data['id'] ?? '',
      ownerId: data['owner_id'] ?? '',
      ownerName: owner?['display_name'] ?? 'Unknown',
      ownerPhone: owner?['phone_number'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      rent: (data['rent'] as num?)?.toDouble() ?? 0.0,
      location: data['location'] ?? '',
      area: data['area'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      bedrooms: data['bedrooms'] ?? 1,
      bathrooms: data['bathrooms'] ?? 1,
      images: List<String>.from(data['images'] ?? []),
      facilities: List<String>.from(data['facilities'] ?? []),
      status: data['status'] ?? 'available',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['review_count'] ?? 0,
      createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
      hasWifi: data['has_wifi'] ?? false,
      distanceFromCampus: (data['distance_from_campus'] as num?)?.toDouble() ?? 0.0,
      roomType: data['room_type'] ?? 'Single Room',
    );
  }

  Future<void> addHouse(HouseModel house, String ownerId) async {
    try {
      _log('addHouse -> start');
      await SupabaseService.insertProperty({
        'owner_id': ownerId,
        'title': house.title,
        'description': house.description,
        'rent': house.rent,
        'location': house.location,
        'area': house.area,
        'latitude': house.latitude,
        'longitude': house.longitude,
        'bedrooms': house.bedrooms,
        'bathrooms': house.bathrooms,
        'images': house.images,
        'facilities': house.facilities,
        'status': house.status,
        'has_wifi': house.hasWifi,
        'distance_from_campus': house.distanceFromCampus,
        'room_type': house.roomType,
        'is_available': true,
      });
      _log('addHouse -> success');
      await loadHouses();
    } catch (e) {
      _log('addHouse -> error: $e');
      rethrow;
    }
  }

  Future<void> updateHouse(HouseModel house) async {
    try {
      _log('updateHouse -> start (id: ${house.id})');
      await SupabaseService.updateProperty(house.id, {
        'title': house.title,
        'description': house.description,
        'rent': house.rent,
        'location': house.location,
        'area': house.area,
        'latitude': house.latitude,
        'longitude': house.longitude,
        'bedrooms': house.bedrooms,
        'bathrooms': house.bathrooms,
        'images': house.images,
        'facilities': house.facilities,
        'status': house.status,
        'has_wifi': house.hasWifi,
        'distance_from_campus': house.distanceFromCampus,
        'room_type': house.roomType,
      });
      _log('updateHouse -> success');
      await loadHouses();
    } catch (e) {
      _log('updateHouse -> error: $e');
      rethrow;
    }
  }

  Future<void> deleteHouse(String id) async {
    try {
      _log('deleteHouse -> start (id: $id)');
      await SupabaseService.deleteProperty(id);
      _log('deleteHouse -> success');
      await loadHouses();
    } catch (e) {
      _log('deleteHouse -> error: $e');
      rethrow;
    }
  }

  List<HouseModel> getOwnerHouses(String ownerId) {
    return state.value?.where((h) => h.ownerId == ownerId).toList() ?? [];
  }

  List<HouseModel> searchHouses(String query) {
    final lowerQuery = query.toLowerCase();
    return state.value?.where((h) =>
      h.title.toLowerCase().contains(lowerQuery) ||
      h.location.toLowerCase().contains(lowerQuery) ||
      h.area.toLowerCase().contains(lowerQuery)
    ).toList() ?? [];
  }

  @override
  void dispose() {
    if (_subscription != null) {
      SupabaseService.unsubscribe(_subscription!);
    }
    super.dispose();
  }
}

// =====================================================
// SERVICES PROVIDER
// =====================================================

final servicesProvider = StateNotifierProvider<ServicesNotifier, AsyncValue<List<ServiceModel>>>((ref) {
  return ServicesNotifier(ref);
});

class ServicesNotifier extends StateNotifier<AsyncValue<List<ServiceModel>>> {
  final Ref ref;
  RealtimeChannel? _subscription;

  ServicesNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadServices();
    _subscribeToChanges();
  }

  Future<void> loadServices() async {
    try {
      _log('loadServices -> start');
      state = const AsyncValue.loading();
      final data = await SupabaseService.getAllServices();
      final services = data.map((e) => _mapToServiceModel(e)).toList();
      state = AsyncValue.data(services);
      _log('loadServices -> loaded ${services.length} services');
    } catch (e, st) {
      _log('loadServices -> error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  void _subscribeToChanges() {
    _subscription = SupabaseService.subscribeToServices((payload) {
      _log('services realtime update received');
      loadServices();
    });
  }

  ServiceModel _mapToServiceModel(Map<String, dynamic> data) {
    final provider = data['provider'] as Map<String, dynamic>?;
    return ServiceModel(
      id: data['id'] ?? '',
      providerId: data['provider_id'] ?? '',
      providerName: provider?['display_name'] ?? 'Unknown',
      providerPhone: provider?['phone_number'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      category: _parseCategory(data['category']),
      images: List<String>.from(data['images'] ?? []),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['review_count'] ?? 0,
      isAvailable: data['is_available'] ?? true,
      createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
      deliveryTime: data['delivery_time'],
      subject: data['subject'],
      qualifications: data['qualifications'],
      experienceLevel: data['experience_level'],
      sessionDurationMinutes: data['session_duration_minutes'],
      availability: data['availability'] != null ? List<String>.from(data['availability']) : null,
    );
  }

  ServiceCategory _parseCategory(String? category) {
    switch (category) {
      case 'food':
        return ServiceCategory.food;
      case 'medicine':
        return ServiceCategory.medicine;
      case 'furniture':
        return ServiceCategory.furniture;
      case 'tuition':
        return ServiceCategory.tuition;
      default:
        return ServiceCategory.food;
    }
  }

  Future<void> addService(ServiceModel service, String providerId) async {
    try {
      _log('addService -> start');
      await SupabaseService.insertService({
        'provider_id': providerId,
        'name': service.name,
        'description': service.description,
        'price': service.price,
        'category': service.category.toString().split('.').last,
        'images': service.images,
        'delivery_time': service.deliveryTime,
        'subject': service.subject,
        'qualifications': service.qualifications,
        'experience_level': service.experienceLevel,
        'session_duration_minutes': service.sessionDurationMinutes,
        'availability': service.availability,
        'is_available': true,
      });
      _log('addService -> success');
      await loadServices();
    } catch (e) {
      _log('addService -> error: $e');
      rethrow;
    }
  }

  Future<void> updateService(ServiceModel service) async {
    try {
      _log('updateService -> start (id: ${service.id})');
      await SupabaseService.updateService(service.id, {
        'name': service.name,
        'description': service.description,
        'price': service.price,
        'category': service.category.toString().split('.').last,
        'images': service.images,
        'delivery_time': service.deliveryTime,
        'subject': service.subject,
        'qualifications': service.qualifications,
        'experience_level': service.experienceLevel,
        'session_duration_minutes': service.sessionDurationMinutes,
        'availability': service.availability,
        'is_available': service.isAvailable,
      });
      _log('updateService -> success');
      await loadServices();
    } catch (e) {
      _log('updateService -> error: $e');
      rethrow;
    }
  }

  Future<void> deleteService(String id) async {
    try {
      _log('deleteService -> start (id: $id)');
      await SupabaseService.deleteService(id);
      _log('deleteService -> success');
      await loadServices();
    } catch (e) {
      _log('deleteService -> error: $e');
      rethrow;
    }
  }

  List<ServiceModel> getServicesByCategory(ServiceCategory category) {
    return state.value?.where((s) => s.category == category).toList() ?? [];
  }

  List<ServiceModel> getProviderServices(String providerId) {
    return state.value?.where((s) => s.providerId == providerId).toList() ?? [];
  }

  @override
  void dispose() {
    if (_subscription != null) {
      SupabaseService.unsubscribe(_subscription!);
    }
    super.dispose();
  }
}

// =====================================================
// BOOKINGS PROVIDER
// =====================================================

final bookingsProvider = StateNotifierProvider<BookingsNotifier, AsyncValue<List<BookingModel>>>((ref) {
  return BookingsNotifier(ref);
});

class BookingsNotifier extends StateNotifier<AsyncValue<List<BookingModel>>> {
  final Ref ref;
  RealtimeChannel? _subscription;

  BookingsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadBookings();
    _subscribeToChanges();
    ref.listen<UserModel?>(currentUserProvider, (previous, next) {
      if (previous?.id != next?.id) {
        _log('bookings user changed -> reload');
        loadBookings();
      }
    });
  }

  Future<void> loadBookings() async {
    try {
      _log('loadBookings -> start');
      state = const AsyncValue.loading();
      final user = ref.read(currentUserProvider);
      if (user == null) {
        state = const AsyncValue.data([]);
        _log('loadBookings -> no user, returning empty list');
        return;
      }

      final String role = user.role;
      List<Map<String, dynamic>> data;
      if (role == 'admin') {
        data = await SupabaseService.getAllBookings();
      } else if (role == 'owner') {
        data = await SupabaseService.getOwnerBookings(user.id);
      } else if (role == 'student') {
        data = await SupabaseService.getStudentBookings(user.id);
      } else {
        // Providers don't have bookings; return empty list
        data = [];
      }
      final bookings = data.map((e) => _mapToBookingModel(e)).toList();
      state = AsyncValue.data(bookings);
      _log('loadBookings -> loaded ${bookings.length} bookings');
    } catch (e, st) {
      _log('loadBookings -> error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  void _subscribeToChanges() {
    _subscription = SupabaseService.subscribeToBookings((payload) {
      _log('bookings realtime update received');
      loadBookings();
    });
  }

  BookingModel _mapToBookingModel(Map<String, dynamic> data) {
    final student = data['student'] as Map<String, dynamic>?;
    final property = data['property'] as Map<String, dynamic>?;
    return BookingModel(
      id: data['id'] ?? '',
      houseId: data['property_id'] ?? property?['id'] ?? '',
      studentId: data['student_id'] ?? '',
      studentName: student?['display_name'] ?? 'Unknown',
      studentPhone: student?['phone_number'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
      notes: data['notes'],
      checkInDate: data['check_in_date'] != null ? DateTime.tryParse(data['check_in_date']) : null,
      checkOutDate: data['check_out_date'] != null ? DateTime.tryParse(data['check_out_date']) : null,
      totalAmount: data['total_amount'] != null ? (data['total_amount'] as num).toDouble() : null,
    );
  }

  Future<void> addBooking(BookingModel booking, String ownerId) async {
    try {
      _log('addBooking -> start');
      _log('addBooking -> checkIn: ${booking.checkInDate}, checkOut: ${booking.checkOutDate}, total: ${booking.totalAmount}');
      await SupabaseService.createBooking({
        'property_id': booking.houseId,
        'student_id': booking.studentId,
        'owner_id': ownerId,
        'check_in_date': booking.checkInDate?.toIso8601String().split('T').first ?? DateTime.now().toIso8601String().split('T').first,
        'check_out_date': booking.checkOutDate?.toIso8601String().split('T').first ?? DateTime.now().add(const Duration(days: 180)).toIso8601String().split('T').first,
        'total_amount': booking.totalAmount ?? 0.0,
        'status': 'pending',
        'notes': booking.notes,
      });
      _log('addBooking -> success');
      await loadBookings();
    } catch (e) {
      _log('addBooking -> error: $e');
      rethrow;
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      _log('updateBookingStatus -> start (id: $bookingId, status: $status)');
      await SupabaseService.updateBookingStatus(bookingId, status);
      _log('updateBookingStatus -> success');
      await loadBookings();
    } catch (e) {
      _log('updateBookingStatus -> error: $e');
      rethrow;
    }
  }

  Future<void> deleteBooking(String bookingId) async {
    try {
      _log('deleteBooking -> start (id: $bookingId)');
      await SupabaseService.deleteBooking(bookingId);
      _log('deleteBooking -> success');
      await loadBookings();
    } catch (e) {
      _log('deleteBooking -> error: $e');
      rethrow;
    }
  }

  List<BookingModel> getStudentBookings(String studentId) {
    return state.value?.where((b) => b.studentId == studentId).toList() ?? [];
  }

  List<BookingModel> getHouseBookings(String houseId) {
    return state.value?.where((b) => b.houseId == houseId).toList() ?? [];
  }

  List<BookingModel> getOwnerBookings(String ownerId, List<HouseModel> ownerHouses) {
    final ownerHouseIds = ownerHouses.map((h) => h.id).toSet();
    return state.value?.where((b) => ownerHouseIds.contains(b.houseId)).toList() ?? [];
  }

  List<BookingModel> getOwnerPendingBookings(String ownerId, List<HouseModel> ownerHouses) {
    final ownerHouseIds = ownerHouses.map((h) => h.id).toSet();
    return state.value?.where((b) => 
      b.status == 'pending' && ownerHouseIds.contains(b.houseId)
    ).toList() ?? [];
  }

  int getActiveOccupants(String houseId) {
    return state.value?.where((b) => 
      b.houseId == houseId && b.status == 'approved'
    ).length ?? 0;
  }

  @override
  void dispose() {
    if (_subscription != null) {
      SupabaseService.unsubscribe(_subscription!);
    }
    super.dispose();
  }
}

// =====================================================
// ORDERS PROVIDER
// =====================================================

final ordersProvider = StateNotifierProvider<OrdersNotifier, AsyncValue<List<OrderModel>>>((ref) {
  return OrdersNotifier(ref);
});

class OrdersNotifier extends StateNotifier<AsyncValue<List<OrderModel>>> {
  final Ref ref;
  RealtimeChannel? _subscription;

  OrdersNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadOrders();
    _subscribeToChanges();
    ref.listen<UserModel?>(currentUserProvider, (previous, next) {
      if (previous?.id != next?.id) {
        _log('orders user changed -> reload');
        loadOrders();
      }
    });
  }

  Future<void> loadOrders() async {
    try {
      _log('loadOrders -> start');
      state = const AsyncValue.loading();
      final user = ref.read(currentUserProvider);
      if (user == null) {
        state = const AsyncValue.data([]);
        _log('loadOrders -> no user, returning empty list');
        return;
      }

      final String role = user.role;
      List<Map<String, dynamic>> data;
      if (role == 'admin') {
        data = await SupabaseService.getAllOrders();
      } else if (role == 'provider') {
        data = await SupabaseService.getProviderOrders(user.id);
      } else if (role == 'student') {
        data = await SupabaseService.getStudentOrders(user.id);
      } else {
        // Owners don't have orders; return empty list
        data = [];
      }
      final orders = data.map((e) => _mapToOrderModel(e)).toList();
      state = AsyncValue.data(orders);
      _log('loadOrders -> loaded ${orders.length} orders');
    } catch (e, st) {
      _log('loadOrders -> error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  void _subscribeToChanges() {
    _subscription = SupabaseService.subscribeToOrders((payload) {
      _log('orders realtime update received');
      loadOrders();
    });
  }

  OrderModel _mapToOrderModel(Map<String, dynamic> data) {
    final student = data['student'] as Map<String, dynamic>?;
    final items = data['items'] as List<dynamic>? ?? [];
    
    String serviceName = 'Order';
    String serviceId = '';
    String providerId = data['provider_id'] ?? '';
    double price = 0.0;
    int quantity = 1;
    
    if (items.isNotEmpty) {
      final firstItem = items.first as Map<String, dynamic>;
      final service = firstItem['service'] as Map<String, dynamic>?;
      serviceName = service?['name'] ?? 'Order';
      serviceId = firstItem['service_id'] ?? '';
      price = (firstItem['price'] as num?)?.toDouble() ?? 0.0;
      quantity = firstItem['quantity'] ?? 1;
    }
    
    return OrderModel(
      id: data['id'] ?? '',
      serviceId: serviceId,
      studentId: data['student_id'] ?? '',
      studentName: student?['display_name'] ?? 'Unknown',
      studentPhone: student?['phone_number'] ?? '',
      studentAddress: data['delivery_address'] ?? '',
      providerId: providerId,
      serviceName: serviceName,
      price: price,
      quantity: quantity,
      status: data['status'] ?? 'pending',
      createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
      notes: data['notes'],
    );
  }

  Future<void> addOrder({
    required String studentId,
    required String studentName,
    required String studentPhone,
    required String studentAddress,
    required String providerId,
    required String serviceId,
    required String serviceName,
    required double price,
    required int quantity,
    String? notes,
  }) async {
    try {
      _log('addOrder -> start');
      await SupabaseService.createOrderWithItems(
        studentId: studentId,
        providerId: providerId,
        totalAmount: price * quantity,
        deliveryAddress: studentAddress,
        notes: notes,
        items: [
          {
            'service_id': serviceId,
            'quantity': quantity,
            'price': price,
            'subtotal': price * quantity,
          }
        ],
      );
      _log('addOrder -> success');
      await loadOrders();
    } catch (e) {
      _log('addOrder -> error: $e');
      rethrow;
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      _log('updateOrderStatus -> start (id: $orderId, status: $status)');
      await SupabaseService.updateOrderStatus(orderId, status);
      _log('updateOrderStatus -> success');
      await loadOrders();
    } catch (e) {
      _log('updateOrderStatus -> error: $e');
      rethrow;
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      _log('deleteOrder -> start (id: $orderId)');
      await SupabaseService.deleteOrder(orderId);
      _log('deleteOrder -> success');
      await loadOrders();
    } catch (e) {
      _log('deleteOrder -> error: $e');
      rethrow;
    }
  }

  List<OrderModel> getStudentOrders(String studentId) {
    return state.value?.where((o) => o.studentId == studentId).toList() ?? [];
  }

  List<OrderModel> getProviderOrders(String providerId) {
    return state.value?.where((o) => o.providerId == providerId).toList() ?? [];
  }

  @override
  void dispose() {
    if (_subscription != null) {
      SupabaseService.unsubscribe(_subscription!);
    }
    super.dispose();
  }
}

// =====================================================
// SAVED HOUSES PROVIDER
// =====================================================

final savedHousesProvider = StateNotifierProvider<SavedHousesNotifier, AsyncValue<Set<String>>>((ref) {
  final user = ref.watch(currentUserProvider);
  return SavedHousesNotifier(user?.id);
});

class SavedHousesNotifier extends StateNotifier<AsyncValue<Set<String>>> {
  final String? userId;

  SavedHousesNotifier(this.userId) : super(const AsyncValue.data({})) {
    if (userId != null) {
      loadSavedHouses();
    }
  }

  Future<void> loadSavedHouses() async {
    if (userId == null) return;
    try {
      _log('loadSavedHouses -> start');
      state = const AsyncValue.loading();
      final ids = await SupabaseService.getSavedHouses(userId!);
      state = AsyncValue.data(ids.toSet());
      _log('loadSavedHouses -> loaded ${ids.length} saved houses');
    } catch (e, st) {
      _log('loadSavedHouses -> error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleSave(String houseId) async {
    if (userId == null) return;
    try {
      final currentSaved = state.value ?? {};
      if (currentSaved.contains(houseId)) {
        _log('unsaveHouse -> start');
        await SupabaseService.unsaveHouse(userId!, houseId);
        state = AsyncValue.data({...currentSaved}..remove(houseId));
        _log('unsaveHouse -> success');
      } else {
        _log('saveHouse -> start');
        await SupabaseService.saveHouse(userId!, houseId);
        state = AsyncValue.data({...currentSaved, houseId});
        _log('saveHouse -> success');
      }
    } catch (e) {
      _log('toggleSave -> error: $e');
    }
  }

  bool isSaved(String houseId) {
    return state.value?.contains(houseId) ?? false;
  }
}

// =====================================================
// REVIEWS PROVIDER
// =====================================================

final reviewsProvider = StateNotifierProvider<ReviewsNotifier, AsyncValue<List<ReviewModel>>>((ref) {
  return ReviewsNotifier(ref);
});

class ReviewsNotifier extends StateNotifier<AsyncValue<List<ReviewModel>>> {
  final Ref ref;

  ReviewsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadReviews();
  }

  Future<void> loadReviews() async {
    try {
      _log('loadReviews -> start');
      state = const AsyncValue.loading();
      final data = await SupabaseService.getAllReviews();
      final reviews = data.map((e) => _mapToReviewModel(e)).toList();
      state = AsyncValue.data(reviews);
      _log('loadReviews -> loaded ${reviews.length} reviews');
    } catch (e, st) {
      _log('loadReviews -> error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  ReviewModel _mapToReviewModel(Map<String, dynamic> data) {
    final reviewer = data['reviewer'] as Map<String, dynamic>?;
    return ReviewModel(
      id: data['id'] ?? '',
      studentId: data['reviewer_id'] ?? '',
      studentName: reviewer?['display_name'] ?? 'Unknown',
      serviceId: data['service_id'],
      houseId: data['property_id'],
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      comment: data['comment'] ?? '',
      createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Future<void> addReview({
    required String reviewerId,
    String? propertyId,
    String? serviceId,
    required double rating,
    required String comment,
  }) async {
    try {
      _log('addReview -> start');
      await SupabaseService.createReview({
        'reviewer_id': reviewerId,
        'property_id': propertyId,
        'service_id': serviceId,
        'rating': rating,
        'comment': comment,
      });
      _log('addReview -> success');
      await loadReviews();
    } catch (e) {
      _log('addReview -> error: $e');
      rethrow;
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      _log('deleteReview -> start');
      await SupabaseService.deleteReview(reviewId);
      _log('deleteReview -> success');
      await loadReviews();
    } catch (e) {
      _log('deleteReview -> error: $e');
      rethrow;
    }
  }

  Future<void> updateReview({
    required String reviewId,
    required double rating,
    required String comment,
  }) async {
    try {
      _log('updateReview -> start');
      await SupabaseService.updateReview(reviewId, {
        'rating': rating,
        'comment': comment,
      });
      _log('updateReview -> success');
      await loadReviews();
    } catch (e) {
      _log('updateReview -> error: $e');
      rethrow;
    }
  }

  List<ReviewModel> getServiceReviews(String serviceId) {
    return state.value?.where((r) => r.serviceId == serviceId).toList() ?? [];
  }

  List<ReviewModel> getHouseReviews(String houseId) {
    return state.value?.where((r) => r.houseId == houseId).toList() ?? [];
  }

  double getServiceAverageRating(String serviceId) {
    final reviews = getServiceReviews(serviceId);
    if (reviews.isEmpty) return 0.0;
    final total = reviews.fold<double>(0, (sum, r) => sum + r.rating);
    return total / reviews.length;
  }

  double getHouseAverageRating(String houseId) {
    final reviews = getHouseReviews(houseId);
    if (reviews.isEmpty) return 0.0;
    final total = reviews.fold<double>(0, (sum, r) => sum + r.rating);
    return total / reviews.length;
  }
}

// =====================================================
// HELPER PROVIDERS
// =====================================================

// Houses list (unwrapped from AsyncValue for convenience)
final housesListProvider = Provider<List<HouseModel>>((ref) {
  return ref.watch(housesProvider).value ?? [];
});

// Services list (unwrapped from AsyncValue for convenience)
final servicesListProvider = Provider<List<ServiceModel>>((ref) {
  return ref.watch(servicesProvider).value ?? [];
});

// Bookings list (unwrapped from AsyncValue for convenience)
final bookingsListProvider = Provider<List<BookingModel>>((ref) {
  return ref.watch(bookingsProvider).value ?? [];
});

// Orders list (unwrapped from AsyncValue for convenience)
final ordersListProvider = Provider<List<OrderModel>>((ref) {
  return ref.watch(ordersProvider).value ?? [];
});

// Reviews list (unwrapped from AsyncValue for convenience)
final reviewsListProvider = Provider<List<ReviewModel>>((ref) {
  return ref.watch(reviewsProvider).value ?? [];
});

// Student review count
final studentReviewCountProvider = Provider.family<int, String>((ref, studentId) {
  final reviews = ref.watch(reviewsListProvider);
  return reviews.where((r) => r.studentId == studentId).length;
});

// Service review count
final serviceReviewCountProvider = Provider.family<int, String>((ref, serviceId) {
  final reviews = ref.watch(reviewsListProvider);
  return reviews.where((r) => r.serviceId == serviceId).length;
});

// House review count
final houseReviewCountProvider = Provider.family<int, String>((ref, houseId) {
  final reviews = ref.watch(reviewsListProvider);
  return reviews.where((r) => r.houseId == houseId).length;
});

// Check if onboarding should show
final shouldShowOnboardingProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final lastShownStr = prefs.getString('onboarding_last_shown');
  
  if (lastShownStr == null) {
    return true;
  }
  
  try {
    final lastShown = DateTime.parse(lastShownStr);
    final now = DateTime.now();
    final difference = now.difference(lastShown).inDays;
    return difference >= 30;
  } catch (e) {
    return true;
  }
});

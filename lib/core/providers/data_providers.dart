import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/house_model.dart';
import '../models/service_model.dart';
import '../models/booking_model.dart';
import '../models/order_model.dart';
import '../models/review_model.dart';
import '../services/mock_data_service.dart';

// Houses provider
final housesProvider = StateNotifierProvider<HousesNotifier, List<HouseModel>>((ref) {
  return HousesNotifier();
});

class HousesNotifier extends StateNotifier<List<HouseModel>> {
  HousesNotifier() : super(MockDataService.demoHouses);

  void addHouse(HouseModel house) {
    state = [...state, house];
    MockDataService.demoHouses.add(house);
  }

  void updateHouse(HouseModel house) {
    state = [
      for (final h in state)
        if (h.id == house.id) house else h,
    ];
    final index = MockDataService.demoHouses.indexWhere((h) => h.id == house.id);
    if (index != -1) {
      MockDataService.demoHouses[index] = house;
    }
  }

  void deleteHouse(String id) {
    state = state.where((h) => h.id != id).toList();
    MockDataService.demoHouses.removeWhere((h) => h.id == id);
  }

  List<HouseModel> getOwnerHouses(String ownerId) {
    return state.where((h) => h.ownerId == ownerId).toList();
  }

  List<HouseModel> searchHouses(String query) {
    final lowerQuery = query.toLowerCase();
    return state.where((h) =>
      h.title.toLowerCase().contains(lowerQuery) ||
      h.location.toLowerCase().contains(lowerQuery) ||
      h.area.toLowerCase().contains(lowerQuery)
    ).toList();
  }
}

// Services provider
final servicesProvider = StateNotifierProvider<ServicesNotifier, List<ServiceModel>>((ref) {
  return ServicesNotifier();
});

class ServicesNotifier extends StateNotifier<List<ServiceModel>> {
  ServicesNotifier() : super(MockDataService.demoServices);

  void addService(ServiceModel service) {
    state = [...state, service];
    MockDataService.demoServices.add(service);
  }

  void updateService(ServiceModel service) {
    state = [
      for (final s in state)
        if (s.id == service.id) service else s,
    ];
    final index = MockDataService.demoServices.indexWhere((s) => s.id == service.id);
    if (index != -1) {
      MockDataService.demoServices[index] = service;
    }
  }

  void deleteService(String id) {
    state = state.where((s) => s.id != id).toList();
    MockDataService.demoServices.removeWhere((s) => s.id == id);
  }

  List<ServiceModel> getServicesByCategory(ServiceCategory category) {
    return state.where((s) => s.category == category).toList();
  }

  List<ServiceModel> getProviderServices(String providerId) {
    return state.where((s) => s.providerId == providerId).toList();
  }
}

// Bookings provider
final bookingsProvider = StateNotifierProvider<BookingsNotifier, List<BookingModel>>((ref) {
  return BookingsNotifier();
});

class BookingsNotifier extends StateNotifier<List<BookingModel>> {
  BookingsNotifier() : super(MockDataService.demoBookings);

  void addBooking(BookingModel booking) {
    state = [...state, booking];
    MockDataService.demoBookings.add(booking);
  }

  void updateBooking(BookingModel booking) {
    state = [
      for (final b in state)
        if (b.id == booking.id) booking else b,
    ];
    final index = MockDataService.demoBookings.indexWhere((b) => b.id == booking.id);
    if (index != -1) {
      MockDataService.demoBookings[index] = booking;
    }
  }

  void deleteBooking(String bookingId) {
    state = state.where((b) => b.id != bookingId).toList();
    MockDataService.demoBookings.removeWhere((b) => b.id == bookingId);
  }

  List<BookingModel> getStudentBookings(String studentId) {
    return state.where((b) => b.studentId == studentId).toList();
  }

  List<BookingModel> getHouseBookings(String houseId) {
    return state.where((b) => b.houseId == houseId).toList();
  }

  // Get bookings by owner
  List<BookingModel> getOwnerBookings(String ownerId, List<HouseModel> ownerHouses) {
    final ownerHouseIds = ownerHouses.where((h) => h.ownerId == ownerId).map((h) => h.id).toList();
    return state.where((b) => ownerHouseIds.contains(b.houseId)).toList();
  }

  // Get pending bookings for owner
  List<BookingModel> getOwnerPendingBookings(String ownerId, List<HouseModel> ownerHouses) {
    final ownerHouseIds = ownerHouses.where((h) => h.ownerId == ownerId).map((h) => h.id).toList();
    return state.where((b) => 
      b.status == 'pending' && ownerHouseIds.contains(b.houseId)
    ).toList();
  }

  // Get approved bookings for owner
  List<BookingModel> getOwnerApprovedBookings(String ownerId, List<HouseModel> ownerHouses) {
    final ownerHouseIds = ownerHouses.where((h) => h.ownerId == ownerId).map((h) => h.id).toList();
    return state.where((b) => 
      b.status == 'approved' && ownerHouseIds.contains(b.houseId)
    ).toList();
  }

  // Count active occupants (approved bookings)
  int getActiveOccupants(String houseId) {
    return state.where((b) => 
      b.houseId == houseId && b.status == 'approved'
    ).length;
  }
}

// Orders provider
final ordersProvider = StateNotifierProvider<OrdersNotifier, List<OrderModel>>((ref) {
  return OrdersNotifier();
});

class OrdersNotifier extends StateNotifier<List<OrderModel>> {
  OrdersNotifier() : super(MockDataService.demoOrders);

  void addOrder(OrderModel order) {
    state = [...state, order];
    MockDataService.demoOrders.add(order);
  }

  void updateOrder(OrderModel order) {
    state = [
      for (final o in state)
        if (o.id == order.id) order else o,
    ];
    final index = MockDataService.demoOrders.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      MockDataService.demoOrders[index] = order;
    }
  }

  void deleteOrder(String orderId) {
    state = state.where((o) => o.id != orderId).toList();
    MockDataService.demoOrders.removeWhere((o) => o.id == orderId);
  }

  List<OrderModel> getStudentOrders(String studentId) {
    return state.where((o) => o.studentId == studentId).toList();
  }

  List<OrderModel> getProviderOrders(String providerId) {
    return state.where((o) => o.providerId == providerId).toList();
  }
}

// Saved/favorite houses
final savedHousesProvider = StateNotifierProvider<SavedHousesNotifier, Set<String>>((ref) {
  return SavedHousesNotifier();
});

class SavedHousesNotifier extends StateNotifier<Set<String>> {
  SavedHousesNotifier() : super({});

  void toggleSave(String houseId) {
    if (state.contains(houseId)) {
      state = {...state}..remove(houseId);
    } else {
      state = {...state, houseId};
    }
  }

  bool isSaved(String houseId) {
    return state.contains(houseId);
  }
}
// Reviews provider
final reviewsProvider = StateNotifierProvider<ReviewsNotifier, List<ReviewModel>>((ref) {
  return ReviewsNotifier();
});

class ReviewsNotifier extends StateNotifier<List<ReviewModel>> {
  ReviewsNotifier() : super([]);

  void addReview(ReviewModel review) {
    state = [...state, review];
  }

  void updateReview(ReviewModel review) {
    state = [
      for (final r in state)
        if (r.id == review.id) review else r,
    ];
  }

  void deleteReview(String reviewId) {
    state = state.where((r) => r.id != reviewId).toList();
  }

  // Get reviews for a specific service
  List<ReviewModel> getServiceReviews(String serviceId) {
    return state.where((r) => r.serviceId == serviceId).toList();
  }

  // Get average rating for a service
  double getServiceAverageRating(String serviceId) {
    final reviews = getServiceReviews(serviceId);
    if (reviews.isEmpty) return 0.0;
    final total = reviews.fold<double>(0, (sum, r) => sum + r.rating);
    return total / reviews.length;
  }

  // Get reviews by a student
  List<ReviewModel> getStudentReviews(String studentId) {
    return state.where((r) => r.studentId == studentId).toList();
  }

  // Get student's review for a specific service
  ReviewModel? getStudentReviewForService(String studentId, String serviceId) {
    try {
      return state.firstWhere(
        (r) => r.studentId == studentId && r.serviceId == serviceId,
      );
    } catch (e) {
      return null;
    }
  }

  // Get reviews for a house
  List<ReviewModel> getHouseReviews(String houseId) {
    return state.where((r) => r.houseId == houseId).toList();
  }

  // Get average rating for a house
  double getHouseAverageRating(String houseId) {
    final reviews = getHouseReviews(houseId);
    if (reviews.isEmpty) return 0.0;
    final total = reviews.fold<double>(0, (sum, r) => sum + r.rating);
    return total / reviews.length;
  }

  // Get student's review for a specific house
  ReviewModel? getStudentReviewForHouse(String studentId, String houseId) {
    try {
      return state.firstWhere(
        (r) => r.studentId == studentId && r.houseId == houseId,
      );
    } catch (e) {
      return null;
    }
  }

  // Get provider average rating
  double getProviderAverageRating(String providerId, List<ServiceModel> allServices) {
    final providerServices = allServices.where((s) => s.providerId == providerId).toList();
    if (providerServices.isEmpty) return 0.0;
    
    double totalRating = 0.0;
    int reviewCount = 0;
    
    for (final service in providerServices) {
      final serviceReviews = getServiceReviews(service.id);
      if (serviceReviews.isNotEmpty) {
        final serviceAverage = getServiceAverageRating(service.id);
        totalRating += serviceAverage * serviceReviews.length;
        reviewCount += serviceReviews.length;
      }
    }
    
    return reviewCount == 0 ? 0.0 : totalRating / reviewCount;
  }
}

// Provider to get student's review count dynamically
final studentReviewCountProvider = Provider.family<int, String>((ref, studentId) {
  final reviews = ref.watch(reviewsProvider);
  return reviews.where((r) => r.studentId == studentId).length;
});

// Provider to get service review count dynamically
final serviceReviewCountProvider = Provider.family<int, String>((ref, serviceId) {
  final reviews = ref.watch(reviewsProvider);
  return reviews.where((r) => r.serviceId == serviceId).length;
});

// Provider to get house review count dynamically
final houseReviewCountProvider = Provider.family<int, String>((ref, houseId) {
  final reviews = ref.watch(reviewsProvider);
  return reviews.where((r) => r.houseId == houseId).length;
});

// Provider to check if onboarding should be shown
final shouldShowOnboardingProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final lastShownStr = prefs.getString('onboarding_last_shown');
  
  if (lastShownStr == null) {
    return true; // First time, show onboarding
  }
  
  try {
    final lastShown = DateTime.parse(lastShownStr);
    final now = DateTime.now();
    final difference = now.difference(lastShown).inDays;
    
    return difference >= 30; // Show again if 30+ days have passed
  } catch (e) {
    return true; // If there's any error, show onboarding
  }
});
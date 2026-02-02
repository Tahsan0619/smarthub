import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';

class SupabaseService {
  static void _log(String message) {
    // ignore: avoid_print
    print('[SupabaseService] $message');
  }

  static Future<void> initialize() async {
    try {
      _log('initialize -> start');
      await Supabase.initialize(
        url: Environment.supabaseUrl,
        anonKey: Environment.supabaseAnonKey,
      );
      _log('initialize -> success');
    } catch (e) {
      _log('initialize -> error: $e');
      rethrow;
    }
  }

  static SupabaseClient get client => Supabase.instance.client;

  // =====================================================
  // USER OPERATIONS
  // =====================================================

  static Future<void> createUserProfile({
    required String authId,
    required String email,
    required String displayName,
    required String role,
    String? phoneNumber,
    String? address,
    String? nidNumber,
    String? university,
  }) async {
    try {
      _log('createUserProfile -> start (email: $email, role: $role)');
      await client.from('users').insert({
        'auth_id': authId,
        'email': email,
        'display_name': displayName,
        'role': role,
        'phone_number': phoneNumber,
        'location': address,
        'nid_number': nidNumber,
        'university': university,
        'is_verified': false,
      });
      _log('createUserProfile -> success');
    } catch (e) {
      _log('createUserProfile -> error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getUserProfile(String authId) async {
    try {
      _log('getUserProfile -> start (auth_id: $authId)');
      final response = await client
          .from('users')
          .select()
          .eq('auth_id', authId)
          .maybeSingle();
      _log('getUserProfile -> ${response != null ? 'found' : 'not found'}');
      return response;
    } catch (e) {
      _log('getUserProfile -> error: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserById(String id) async {
    try {
      _log('getUserById -> start (id: $id)');
      final response = await client
          .from('users')
          .select()
          .eq('id', id)
          .maybeSingle();
      return response;
    } catch (e) {
      _log('getUserById -> error: $e');
      return null;
    }
  }

  static Future<void> updateUserProfile(String id, Map<String, dynamic> data) async {
    try {
      _log('updateUserProfile -> start (id: $id)');
      await client.from('users').update(data).eq('id', id);
      _log('updateUserProfile -> success');
    } catch (e) {
      _log('updateUserProfile -> error: $e');
      rethrow;
    }
  }

  static Future<void> updateUserProfileByAuthId(String authId, Map<String, dynamic> data) async {
    try {
      _log('updateUserProfileByAuthId -> start (auth_id: $authId)');
      await client.from('users').update(data).eq('auth_id', authId);
      _log('updateUserProfileByAuthId -> success');
    } catch (e) {
      _log('updateUserProfileByAuthId -> error: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      _log('getAllUsers -> start');
      final response = await client
          .from('users')
          .select()
          .order('created_at', ascending: false);
      _log('getAllUsers -> found ${response.length} users');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _log('getAllUsers -> error: $e');
      return [];
    }
  }

  static Future<void> verifyUser(String userId, String adminId) async {
    try {
      _log('verifyUser -> start (userId: $userId)');
      await client.from('users').update({
        'is_verified': true,
        'verification_date': DateTime.now().toIso8601String(),
        'verified_by': adminId,
      }).eq('id', userId);
      _log('verifyUser -> success');
    } catch (e) {
      _log('verifyUser -> error: $e');
      rethrow;
    }
  }

  static Future<void> unverifyUser(String userId) async {
    try {
      _log('unverifyUser -> start (userId: $userId)');
      await client.from('users').update({
        'is_verified': false,
        'verification_date': null,
        'verified_by': null,
      }).eq('id', userId);
      _log('unverifyUser -> success');
    } catch (e) {
      _log('unverifyUser -> error: $e');
      rethrow;
    }
  }

  static Future<void> deleteUser(String userId) async {
    try {
      _log('deleteUser -> start (userId: $userId)');
      await client.from('users').delete().eq('id', userId);
      _log('deleteUser -> success');
    } catch (e) {
      _log('deleteUser -> error: $e');
      rethrow;
    }
  }

  // =====================================================
  // PROPERTY OPERATIONS
  // =====================================================

  static Future<List<Map<String, dynamic>>> getProperties({int limit = 50}) async {
    try {
      _log('getProperties -> start (limit: $limit)');
      final response = await client
          .from('properties')
          .select('*, owner:users!properties_owner_id_fkey(id, display_name, phone_number, profile_image_url)')
          .eq('is_available', true)
          .order('created_at', ascending: false)
          .limit(limit);
      _log('getProperties -> found ${response.length} properties');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _log('getProperties -> error: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getAllProperties() async {
    try {
      _log('getAllProperties -> start');
      final response = await client
          .from('properties')
          .select('*, owner:users!properties_owner_id_fkey(id, display_name, phone_number, profile_image_url)')
          .order('created_at', ascending: false);
      _log('getAllProperties -> found ${response.length} properties');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _log('getAllProperties -> error: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getPropertyById(String id) async {
    try {
      _log('getPropertyById -> start (id: $id)');
      final response = await client
          .from('properties')
          .select('*, owner:users!properties_owner_id_fkey(id, display_name, phone_number, profile_image_url)')
          .eq('id', id)
          .maybeSingle();
      return response;
    } catch (e) {
      _log('getPropertyById -> error: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getOwnerProperties(String ownerId) async {
    try {
      _log('getOwnerProperties -> start (owner_id: $ownerId)');
      final response = await client
          .from('properties')
          .select()
          .eq('owner_id', ownerId)
          .order('created_at', ascending: false);
      _log('getOwnerProperties -> found ${response.length} properties');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _log('getOwnerProperties -> error: $e');
      return [];
    }
  }

  static Future<String?> insertProperty(Map<String, dynamic> data) async {
    try {
      _log('insertProperty -> start');
      final response = await client.from('properties').insert(data).select('id').single();
      _log('insertProperty -> success (id: ${response['id']})');
      return response['id'];
    } catch (e) {
      _log('insertProperty -> error: $e');
      return null;
    }
  }

  static Future<void> updateProperty(String id, Map<String, dynamic> data) async {
    try {
      _log('updateProperty -> start (id: $id)');
      await client.from('properties').update(data).eq('id', id);
      _log('updateProperty -> success');
    } catch (e) {
      _log('updateProperty -> error: $e');
      rethrow;
    }
  }

  static Future<void> deleteProperty(String id) async {
    try {
      _log('deleteProperty -> start (id: $id)');
      await client.from('properties').delete().eq('id', id);
      _log('deleteProperty -> success');
    } catch (e) {
      _log('deleteProperty -> error: $e');
      rethrow;
    }
  }

  // =====================================================
  // SERVICE OPERATIONS
  // =====================================================

  static Future<List<Map<String, dynamic>>> getServices({int limit = 50}) async {
    try {
      _log('getServices -> start (limit: $limit)');
      final response = await client
          .from('services')
          .select('*, provider:users!services_provider_id_fkey(id, display_name, phone_number, profile_image_url)')
          .eq('is_available', true)
          .order('created_at', ascending: false)
          .limit(limit);
      _log('getServices -> found ${response.length} services');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _log('getServices -> error: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getAllServices() async {
    try {
      _log('getAllServices -> start');
      final response = await client
          .from('services')
          .select('*, provider:users!services_provider_id_fkey(id, display_name, phone_number, profile_image_url)')
          .order('created_at', ascending: false);
      _log('getAllServices -> found ${response.length} services');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _log('getAllServices -> error: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> getServiceById(String id) async {
    try {
      _log('getServiceById -> start (id: $id)');
      final response = await client
          .from('services')
          .select('*, provider:users!services_provider_id_fkey(id, display_name, phone_number, profile_image_url)')
          .eq('id', id)
          .maybeSingle();
      return response;
    } catch (e) {
      _log('getServiceById -> error: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getProviderServices(String providerId) async {
    try {
      _log('getProviderServices -> start (provider_id: $providerId)');
      final response = await client
          .from('services')
          .select()
          .eq('provider_id', providerId)
          .order('created_at', ascending: false);
      _log('getProviderServices -> found ${response.length} services');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _log('getProviderServices -> error: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getServicesByCategory(String category) async {
    try {
      _log('getServicesByCategory -> start (category: $category)');
      final response = await client
          .from('services')
          .select('*, provider:users!services_provider_id_fkey(id, display_name, phone_number, profile_image_url)')
          .eq('category', category)
          .eq('is_available', true)
          .order('created_at', ascending: false);
      _log('getServicesByCategory -> found ${response.length} services');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _log('getServicesByCategory -> error: $e');
      return [];
    }
  }

  static Future<String?> insertService(Map<String, dynamic> data) async {
    try {
      _log('insertService -> start');
      final response = await client.from('services').insert(data).select('id').single();
      _log('insertService -> success (id: ${response['id']})');
      return response['id'];
    } catch (e) {
      _log('insertService -> error: $e');
      return null;
    }
  }

  static Future<void> updateService(String id, Map<String, dynamic> data) async {
    try {
      _log('updateService -> start (id: $id)');
      await client.from('services').update(data).eq('id', id);
      _log('updateService -> success');
    } catch (e) {
      _log('updateService -> error: $e');
      rethrow;
    }
  }

  static Future<void> deleteService(String id) async {
    try {
      _log('deleteService -> start (id: $id)');
      await client.from('services').delete().eq('id', id);
      _log('deleteService -> success');
    } catch (e) {
      _log('deleteService -> error: $e');
      rethrow;
    }
  }

  // =====================================================
  // BOOKING OPERATIONS
  // =====================================================

  static Future<String?> createBooking(Map<String, dynamic> data) async {
    try {
      _log('createBooking -> start');
      final response = await client.from('bookings').insert(data).select('id').single();
      _log('createBooking -> success (id: ${response['id']})');
      return response['id'];
    } catch (e) {
      _log('createBooking -> error: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllBookings() async {
    try {
      _log('getAllBookings -> start');
      final response = await client
          .from('bookings')
          .select('''
            *,
            property:properties(id, title, rent, images, location),
            student:users!bookings_student_id_fkey(id, display_name, phone_number, profile_image_url),
            owner:users!bookings_owner_id_fkey(id, display_name, phone_number)
          ''')
          .order('created_at', ascending: false);
      _log('getAllBookings -> found ${response.length} bookings');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _log('getAllBookings -> error: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getStudentBookings(String studentId) async {
    try {
      _log('getStudentBookings -> start (student_id: $studentId)');
      final response = await client
          .from('bookings')
          .select('''
            *,
            property:properties(id, title, rent, images, location, owner_id),
            owner:users!bookings_owner_id_fkey(id, display_name, phone_number)
          ''')
          .eq('student_id', studentId)
          .order('created_at', ascending: false);
      _log('getStudentBookings -> found ${response.length} bookings');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _log('getStudentBookings -> error: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getOwnerBookings(String ownerId) async {
    try {
      _log('getOwnerBookings -> start (owner_id: $ownerId)');
      final response = await client
          .from('bookings')
          .select('''
            *,
            property:properties(id, title, rent, images, location),
            student:users!bookings_student_id_fkey(id, display_name, phone_number, profile_image_url, email)
          ''')
          .eq('owner_id', ownerId)
          .order('created_at', ascending: false);
      _log('getOwnerBookings -> found ${response.length} bookings');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _log('getOwnerBookings -> error: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getPropertyBookings(String propertyId) async {
    try {
      _log('getPropertyBookings -> start (property_id: $propertyId)');
      final response = await client
          .from('bookings')
          .select('''
            *,
            student:users!bookings_student_id_fkey(id, display_name, phone_number, profile_image_url)
          ''')
          .eq('property_id', propertyId)
          .order('created_at', ascending: false);
      _log('getPropertyBookings -> found ${response.length} bookings');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _log('getPropertyBookings -> error: $e');
      return [];
    }
  }

  static Future<void> updateBookingStatus(String id, String status) async {
    try {
      _log('updateBookingStatus -> start (id: $id, status: $status)');
      await client.from('bookings').update({'status': status}).eq('id', id);
      _log('updateBookingStatus -> success');
    } catch (e) {
      _log('updateBookingStatus -> error: $e');
      rethrow;
    }
  }

  static Future<void> deleteBooking(String id) async {
    try {
      _log('deleteBooking -> start (id: $id)');
      await client.from('bookings').delete().eq('id', id);
      _log('deleteBooking -> success');
    } catch (e) {
      _log('deleteBooking -> error: $e');
      rethrow;
    }
  }

  // =====================================================
  // ORDER OPERATIONS
  // =====================================================

  static Future<String?> createOrderWithItems({
    required String studentId,
    required String providerId,
    required double totalAmount,
    required String deliveryAddress,
    String? notes,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      _log('createOrderWithItems -> start');
      
      final orderResponse = await client.from('orders').insert({
        'student_id': studentId,
        'provider_id': providerId,
        'total_amount': totalAmount,
        'delivery_address': deliveryAddress,
        'notes': notes,
        'status': 'pending',
      }).select('id').single();
      
      final orderId = orderResponse['id'];
      
      for (final item in items) {
        await client.from('order_items').insert({
          'order_id': orderId,
          'service_id': item['service_id'],
          'quantity': item['quantity'],
          'price': item['price'],
          'subtotal': item['subtotal'],
        });
      }
      
      _log('createOrderWithItems -> success (id: $orderId)');
      return orderId;
    } catch (e) {
      _log('createOrderWithItems -> error: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getAllOrders() async {
    try {
      _log('getAllOrders -> start');
      final response = await client
          .from('orders')
          .select('''
            *,
            student:users!orders_student_id_fkey(id, display_name, phone_number, profile_image_url),
            provider:users!orders_provider_id_fkey(id, display_name, phone_number),
            items:order_items(*, service:services(id, name, images, category))
          ''')
          .order('created_at', ascending: false);
      _log('getAllOrders -> found ${response.length} orders');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _log('getAllOrders -> error: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getStudentOrders(String studentId) async {
    try {
      _log('getStudentOrders -> start (student_id: $studentId)');
      final response = await client
          .from('orders')
          .select('''
            *,
            provider:users!orders_provider_id_fkey(id, display_name, phone_number),
            items:order_items(*, service:services(id, name, images, category))
          ''')
          .eq('student_id', studentId)
          .order('created_at', ascending: false);
      _log('getStudentOrders -> found ${response.length} orders');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _log('getStudentOrders -> error: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getProviderOrders(String providerId) async {
    try {
      _log('getProviderOrders -> start (provider_id: $providerId)');
      final response = await client
          .from('orders')
          .select('''
            *,
            student:users!orders_student_id_fkey(id, display_name, phone_number, profile_image_url, email),
            items:order_items(*, service:services(id, name, images, category))
          ''')
          .eq('provider_id', providerId)
          .order('created_at', ascending: false);
      _log('getProviderOrders -> found ${response.length} orders');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _log('getProviderOrders -> error: $e');
      return [];
    }
  }

  static Future<void> updateOrderStatus(String id, String status) async {
    try {
      _log('updateOrderStatus -> start (id: $id, status: $status)');
      await client.from('orders').update({'status': status}).eq('id', id);
      _log('updateOrderStatus -> success');
    } catch (e) {
      _log('updateOrderStatus -> error: $e');
      rethrow;
    }
  }

  static Future<void> deleteOrder(String id) async {
    try {
      _log('deleteOrder -> start (id: $id)');
      // First delete order items
      await client.from('order_items').delete().eq('order_id', id);
      // Then delete the order
      await client.from('orders').delete().eq('id', id);
      _log('deleteOrder -> success');
    } catch (e) {
      _log('deleteOrder -> error: $e');
      rethrow;
    }
  }

  // =====================================================
  // SAVED HOUSES OPERATIONS
  // =====================================================

  static Future<List<String>> getSavedHouses(String userId) async {
    try {
      _log('getSavedHouses -> start (user_id: $userId)');
      final response = await client
          .from('saved_houses')
          .select('property_id')
          .eq('user_id', userId);
      final ids = (response as List).map((e) => e['property_id'] as String).toList();
      _log('getSavedHouses -> found ${ids.length} saved houses');
      return ids;
    } catch (e) {
      _log('getSavedHouses -> error: $e');
      return [];
    }
  }

  static Future<void> saveHouse(String userId, String propertyId) async {
    try {
      _log('saveHouse -> start (user_id: $userId, property_id: $propertyId)');
      await client.from('saved_houses').insert({
        'user_id': userId,
        'property_id': propertyId,
      });
      _log('saveHouse -> success');
    } catch (e) {
      _log('saveHouse -> error: $e');
      rethrow;
    }
  }

  static Future<void> unsaveHouse(String userId, String propertyId) async {
    try {
      _log('unsaveHouse -> start (user_id: $userId, property_id: $propertyId)');
      await client
          .from('saved_houses')
          .delete()
          .eq('user_id', userId)
          .eq('property_id', propertyId);
      _log('unsaveHouse -> success');
    } catch (e) {
      _log('unsaveHouse -> error: $e');
      rethrow;
    }
  }

  // =====================================================
  // REVIEW OPERATIONS
  // =====================================================

  static Future<String?> createReview(Map<String, dynamic> data) async {
    try {
      _log('createReview -> start');
      final response = await client.from('reviews').insert(data).select('id').single();
      _log('createReview -> success (id: ${response['id']})');
      return response['id'];
    } catch (e) {
      _log('createReview -> error: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> getPropertyReviews(String propertyId) async {
    try {
      _log('getPropertyReviews -> start (property_id: $propertyId)');
      final response = await client
          .from('reviews')
          .select('''
            *,
            reviewer:users!reviews_reviewer_id_fkey(id, display_name, profile_image_url)
          ''')
          .eq('property_id', propertyId)
          .order('created_at', ascending: false);
      _log('getPropertyReviews -> found ${response.length} reviews');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _log('getPropertyReviews -> error: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getServiceReviews(String serviceId) async {
    try {
      _log('getServiceReviews -> start (service_id: $serviceId)');
      final response = await client
          .from('reviews')
          .select('''
            *,
            reviewer:users!reviews_reviewer_id_fkey(id, display_name, profile_image_url)
          ''')
          .eq('service_id', serviceId)
          .order('created_at', ascending: false);
      _log('getServiceReviews -> found ${response.length} reviews');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _log('getServiceReviews -> error: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getAllReviews() async {
    try {
      _log('getAllReviews -> start');
      final response = await client
          .from('reviews')
          .select('''
            *,
            reviewer:users!reviews_reviewer_id_fkey(id, display_name, profile_image_url),
            property:properties(id, title),
            service:services(id, name)
          ''')
          .order('created_at', ascending: false);
      _log('getAllReviews -> found ${response.length} reviews');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _log('getAllReviews -> error: $e');
      return [];
    }
  }

  static Future<void> updateReview(String id, Map<String, dynamic> data) async {
    try {
      _log('updateReview -> start (id: $id)');
      await client.from('reviews').update(data).eq('id', id);
      _log('updateReview -> success');
    } catch (e) {
      _log('updateReview -> error: $e');
      rethrow;
    }
  }

  static Future<void> deleteReview(String id) async {
    try {
      _log('deleteReview -> start (id: $id)');
      await client.from('reviews').delete().eq('id', id);
      _log('deleteReview -> success');
    } catch (e) {
      _log('deleteReview -> error: $e');
      rethrow;
    }
  }

  // =====================================================
  // IMAGE UPLOAD OPERATIONS
  // =====================================================

  static Future<String?> uploadPropertyImage({
    required String filePath,
    required String fileName,
  }) async {
    try {
      _log('uploadPropertyImage -> start (file: $fileName)');
      final file = File(filePath);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'property_${timestamp}_$fileName';
      
      await client.storage.from('properties-images').upload(path, file);
      final url = client.storage.from('properties-images').getPublicUrl(path);
      
      _log('uploadPropertyImage -> success');
      return url;
    } catch (e) {
      _log('uploadPropertyImage -> error: $e');
      return null;
    }
  }

  static Future<String?> uploadServiceImage({
    required String filePath,
    required String fileName,
  }) async {
    try {
      _log('uploadServiceImage -> start (file: $fileName)');
      final file = File(filePath);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'service_${timestamp}_$fileName';
      
      await client.storage.from('services-images').upload(path, file);
      final url = client.storage.from('services-images').getPublicUrl(path);
      
      _log('uploadServiceImage -> success');
      return url;
    } catch (e) {
      _log('uploadServiceImage -> error: $e');
      return null;
    }
  }

  static Future<String?> uploadProfileImage({
    required String filePath,
    required String fileName,
  }) async {
    try {
      _log('uploadProfileImage -> start (file: $fileName)');
      final file = File(filePath);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'profile_${timestamp}_$fileName';
      
      await client.storage.from('profile-images').upload(path, file);
      final url = client.storage.from('profile-images').getPublicUrl(path);
      
      _log('uploadProfileImage -> success');
      return url;
    } catch (e) {
      _log('uploadProfileImage -> error: $e');
      return null;
    }
  }

  // =====================================================
  // REALTIME SUBSCRIPTIONS
  // =====================================================

  static RealtimeChannel subscribeToProperties(void Function(dynamic) callback) {
    _log('subscribeToProperties -> start');
    return client
        .channel('public:properties')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'properties',
          callback: (payload) {
            _log('properties realtime -> ${payload.eventType}');
            callback(payload);
          },
        )
        .subscribe();
  }

  static RealtimeChannel subscribeToServices(void Function(dynamic) callback) {
    _log('subscribeToServices -> start');
    return client
        .channel('public:services')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'services',
          callback: (payload) {
            _log('services realtime -> ${payload.eventType}');
            callback(payload);
          },
        )
        .subscribe();
  }

  static RealtimeChannel subscribeToBookings(void Function(dynamic) callback) {
    _log('subscribeToBookings -> start');
    return client
        .channel('public:bookings')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'bookings',
          callback: (payload) {
            _log('bookings realtime -> ${payload.eventType}');
            callback(payload);
          },
        )
        .subscribe();
  }

  static RealtimeChannel subscribeToOrders(void Function(dynamic) callback) {
    _log('subscribeToOrders -> start');
    return client
        .channel('public:orders')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          callback: (payload) {
            _log('orders realtime -> ${payload.eventType}');
            callback(payload);
          },
        )
        .subscribe();
  }

  static RealtimeChannel subscribeToUsers(void Function(dynamic) callback) {
    _log('subscribeToUsers -> start');
    return client
        .channel('public:users')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'users',
          callback: (payload) {
            _log('users realtime -> ${payload.eventType}');
            callback(payload);
          },
        )
        .subscribe();
  }

  static void unsubscribe(RealtimeChannel channel) {
    _log('unsubscribe -> channel');
    client.removeChannel(channel);
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class BookingService {
  
  // Create new booking
  Future<Map<String, dynamic>> createBooking({
    required int kostId,
    required String kostName,
    required int userId,
    required String userName,
    required int ownerId,
    required String ownerName,
    required int durasiBulan,
    required int totalHarga,
    required String tanggalMasuk,
    required String catatan,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.createBooking),
        body: {
          'kost_id': kostId.toString(),
          'kost_name': kostName,
          'user_id': userId.toString(),
          'user_name': userName,
          'owner_id': ownerId.toString(),
          'owner_name': ownerName,
          'durasi_bulan': durasiBulan.toString(),
          'total_harga': totalHarga.toString(),
          'tanggal_masuk': tanggalMasuk,
          'catatan': catatan,
        },
      );

      print('📝 Create booking response: ${response.body}');
      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Create booking error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Get my bookings (for student)
  Future<Map<String, dynamic>> getMyBookings(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.myBookings}?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data is List ? data : []};
      }
      return {'success': false, 'message': 'HTTP Error: ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Get owner bookings (for owner)
  Future<Map<String, dynamic>> getOwnerBookings(int ownerId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.ownerBookings}?owner_id=$ownerId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data is List ? data : []};
      }
      return {'success': false, 'message': 'HTTP Error: ${response.statusCode}'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Update booking status (for owner)
  Future<Map<String, dynamic>> updateStatus(int bookingId, String status) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.updateBooking),
        body: {
          'booking_id': bookingId.toString(),
          'status': status,
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
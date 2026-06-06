import 'package:flutter/material.dart';
import '../services/booking_service.dart';
import '../models/booking_model.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _service = BookingService();
  
  List<BookingModel> myBookings = [];
  List<BookingModel> ownerBookings = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> getMyBookings(int userId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.getMyBookings(userId);
      if (response['success'] == true) {
        myBookings = (response['data'] as List)
            .map((json) => BookingModel.fromJson(json))
            .toList();
      } else {
        errorMessage = response['message'] ?? 'Gagal memuat booking';
      }
    } catch (e) {
      errorMessage = 'Error: $e';
      debugPrint('Get bookings error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getOwnerBookings(int ownerId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.getOwnerBookings(ownerId);
      if (response['success'] == true) {
        ownerBookings = (response['data'] as List)
            .map((json) => BookingModel.fromJson(json))
            .toList();
      } else {
        errorMessage = response['message'] ?? 'Gagal memuat booking';
      }
    } catch (e) {
      errorMessage = 'Error: $e';
      debugPrint('Get owner bookings error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBooking({
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
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.createBooking(
        kostId: kostId,
        kostName: kostName,
        userId: userId,
        userName: userName,
        ownerId: ownerId,
        ownerName: ownerName,
        durasiBulan: durasiBulan,
        totalHarga: totalHarga,
        tanggalMasuk: tanggalMasuk,
        catatan: catatan,
      );

      if (response['success'] == true) {
        await getMyBookings(userId);
        return true;
      } else {
        errorMessage = response['message'] ?? 'Gagal membuat booking';
        return false;
      }
    } catch (e) {
      errorMessage = 'Error: $e';
      debugPrint('Create booking error: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Update booking status
  Future<bool> updateStatus(int bookingId, String status) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _service.updateStatus(bookingId, status);
      return response['success'] == true;
    } catch (e) {
      debugPrint('Update status error: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
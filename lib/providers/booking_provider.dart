import 'package:flutter/material.dart';

import '../services/booking_service.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _service = BookingService();

  List bookings = [];

  bool isLoading = false;

  Future<void> getBookings() async {
    isLoading = true;
    notifyListeners();

    try {
      bookings = await _service.getBooking();
    } catch (e) {
      debugPrint(e.toString());
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> createBooking({required int kostId, required int userId}) async {
    try {
      final response = await _service.createBooking(kostId, userId);

      if (response["success"] == true) {
        await getBookings();

        return true;
      }

      return false;
    } catch (e) {
      debugPrint(e.toString());

      return false;
    }
  }
}

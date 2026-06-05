import 'api_service.dart';

class BookingService {

  Future<dynamic> createBooking(
      int kostId,
      int userId,
      ) async {

    return await ApiService.post(
      "booking/store.php",
      {
        "kost_id":
        kostId.toString(),

        "user_id":
        userId.toString(),
      },
    );
  }

  Future<dynamic> getBooking() async {

    return await ApiService.get(
      "booking/index.php",
    );
  }
}
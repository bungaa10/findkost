class ApiConfig {
  
  static const String baseUrl = 'http://192.168.0.107'; // Ganti ini!
  static const String socketUrl = 'http://192.168.0.107:3000'; // Socket Server
  
  // Endpoints
  static const String login = '$baseUrl/findkost_api/auth/login.php';
  static const String googleLogin = '$baseUrl/findkost_api/auth/google_login.php';
  static const String register = '$baseUrl/findkost_api/auth/register.php';
  static const String getKost = '$baseUrl/findkost_api/kost/index.php';
  static const String createKost = '$baseUrl/findkost_api/kost/store.php';
  static const String updateKost = '$baseUrl/findkost_api/kost/update.php';
  static const String deleteKost = '$baseUrl/findkost_api/kost/delete.php';
  static const String detailKost = '$baseUrl/findkost_api/kost/detail.php';
  static const String createBooking = '$baseUrl/findkost_api/bookings/store.php';
  static const String indexBooking = '$baseUrl/findkost_api/bookings/index.php';
  static const String updateBooking = '$baseUrl/findkost_api/bookings/update_status.php';
  static const String myBookings = '$baseUrl/findkost_api/bookings/my_bookings.php';
  static const String ownerBookings = '$baseUrl/findkost_api/bookings/owner.php';
  static const String saveFcmToken = '$baseUrl/findkost_api/auth/save_fcm_token.php';

}
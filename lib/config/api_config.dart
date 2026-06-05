class ApiConfig {
  
  static const String baseUrl = 'http://192.168.1.46'; // Ganti ini!
  
  // Endpoints
  static const String login = '$baseUrl/findkost_api/auth/login.php';
  static const String googleLogin = '$baseUrl/findkost_api/auth/google_login.php';
  static const String register = '$baseUrl/findkost_api/auth/register.php';
  static const String getKost = '$baseUrl/findkost_api/kost/index.php';
  static const String createKost = '$baseUrl/findkost_api/kost/store.php';
  static const String updateKost = '$baseUrl/findkost_api/kost/update.php';
  static const String deleteKost = '$baseUrl/findkost_api/kost/delete.php';
  static const String detailKost = '$baseUrl/findkost_api/kost/detail.php';
}
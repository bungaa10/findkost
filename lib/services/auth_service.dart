import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

import 'api_service.dart';

class AuthService {
  // ✅ UPDATE login dengan parameter role
  Future<dynamic> login(String email, String password, String role) async {
    return await ApiService.post("auth/login.php", {
      "email": email,
      "password": password,
      "role": role,  // ← tambahkan role
    });
  }

  // ✅ UPDATE register dengan parameter role
  Future<dynamic> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    return await ApiService.post("auth/register.php", {
      "name": name,
      "email": email,
      "password": password,
      "role": role,
    });
  }
}
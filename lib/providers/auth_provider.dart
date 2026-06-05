import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../config/api_config.dart';
import '../services/socket_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Map<String, dynamic>? user;
  bool isLoading = false;
  String? errorMessage;
  bool _initialized = false;

  bool get isLogin => user != null;

  // Constructor
  AuthProvider() {
    _firebaseAuth.authStateChanges().listen((User? firebaseUser) {
      if (firebaseUser == null && user != null) {
        user = null;
        notifyListeners();
      }
    });
    _initGoogleSignIn();
  }

  Future<void> _initGoogleSignIn() async {
    if (_initialized) return;
    _initialized = true;
    await _googleSignIn.initialize();
    await _googleSignIn.attemptLightweightAuthentication();
  }

  // ==================== LOGIN MANUAL ====================
// ✅ UPDATE dengan parameter role
Future<bool> login(String email, String password, String role) async {
  isLoading = true;
  errorMessage = null;
  notifyListeners();

  try {
    final response = await _authService.login(email, password, role); // ← kirim role

    print('📝 Login response: $response');

    if (response["success"] == true) {
      user = response["user"];
      print('👤 User role: ${user?["role"]}');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("isLogin", true);
      await prefs.setString("user", jsonEncode(user));
      
      _initSocket();
      
      notifyListeners();
      return true;
    } else {
      errorMessage = response["message"] ?? "Login gagal";
      notifyListeners();
      return false;
    }
  } catch (e) {
    errorMessage = "Error: $e";
    debugPrint("Login error: $e");
    return false;
  } finally {
    isLoading = false;
    notifyListeners();
  }
}

// ✅ Tambahkan getter role
String get userRole => user?["role"] ?? "mahasiswa";
bool get isPemilik => userRole == "pemilik";

  // ==================== LOGIN DENGAN GOOGLE ====================
  Future<bool> signInWithGoogle() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // 1. Authenticate dengan Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) {
        isLoading = false;
        notifyListeners();
        return false;
      }

      // 2. Dapatkan idToken
      final String? idToken = await googleUser.authentication.idToken;

      if (idToken == null) {
        errorMessage = "ID Token tidak ditemukan";
        isLoading = false;
        notifyListeners();
        return false;
      }

      // 3. Login ke Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );
      final UserCredential authResult = await _firebaseAuth.signInWithCredential(credential);
      final User? firebaseUser = authResult.user;

      if (firebaseUser == null) {
        errorMessage = "Gagal login ke Firebase";
        isLoading = false;
        notifyListeners();
        return false;
      }

      // 4. Kirim token ke backend PHP
      debugPrint("Mencoba kirim token ke PHP: ${ApiConfig.googleLogin}");

      final response = await http.post(
        Uri.parse(ApiConfig.googleLogin),
        body: {"id_token": idToken},
      );

      debugPrint("Status HTTP: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
        // 5. Simpan data user ke SharedPreferences
        user = {
          "id": responseData["user_id"],
          "name": firebaseUser.displayName ?? googleUser.displayName,
          "email": firebaseUser.email ?? googleUser.email,
          "role": responseData["user"]["role"] ?? "mahasiswa",
        };

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool("isLogin", true);
        await prefs.setString("user", jsonEncode(user));

        _initSocket();

        notifyListeners();
        return true;
      } else {
        errorMessage = responseData["message"] ?? "Gagal login dengan Google";
        return false;
      }
    } catch (e) {
      errorMessage = "Error: $e";
      debugPrint("Google Sign-In error: $e");
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ==================== LOGOUT ====================
  Future<void> logout() async {
    isLoading = true;
    notifyListeners();

    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint("Logout error: $e");
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    user = null;
    isLoading = false;
    
    SocketService().disconnect();
    
    notifyListeners();
  }

  // ==================== LOAD SESSION ====================
  // ==================== LOAD SESSION ====================
Future<void> loadSession() async {
  final prefs = await SharedPreferences.getInstance();
  bool login = prefs.getBool("isLogin") ?? false;
  
  print('📱 loadSession called, login from prefs: $login'); // ✅ Debug

  if (login) {
    String? data = prefs.getString("user");
    print('📱 User data from prefs: $data'); // ✅ Debug
    if (data != null) {
      user = jsonDecode(data);
      print('📱 User loaded successfully: ${user?["name"]}'); // ✅ Debug
      _initSocket();
      notifyListeners();
    } else {
      print('📱 User data is null!'); // ✅ Debug
    }
  } else {
    print('📱 User not logged in'); // ✅ Debug
  }
}

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  void _initSocket() {
    if (user != null) {
      SocketService().onConnected = () {
        int parsedUserId = user!["id"] is int 
            ? user!["id"] 
            : int.tryParse(user!["id"].toString()) ?? 0;

        SocketService().registerUser(
          userId: parsedUserId,
          userName: user!["name"] ?? "User",
          role: userRole,
        );
      };
      
      SocketService().connect(serverUrl: ApiConfig.socketUrl);
    }
  }
}
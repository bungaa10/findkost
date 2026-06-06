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

Future<bool> login(String email, String password, String role) async {
  isLoading = true;
  errorMessage = null;
  notifyListeners();

  try {
    final response = await _authService.login(email, password, role); 

    print(' Login response: $response');

    if (response["success"] == true) {
      user = response["user"];
      print(' User role: ${user?["role"]}');
      
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

String get userRole => user?["role"] ?? "mahasiswa";
bool get isPemilik => userRole == "pemilik";

  Future<bool> signInWithGoogle() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) {
        isLoading = false;
        notifyListeners();
        return false;
      }

      final String? idToken = await googleUser.authentication.idToken;

      if (idToken == null) {
        errorMessage = "ID Token tidak ditemukan";
        isLoading = false;
        notifyListeners();
        return false;
      }

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

      debugPrint("Mencoba kirim token ke PHP: ${ApiConfig.googleLogin}");

      final response = await http.post(
        Uri.parse(ApiConfig.googleLogin),
        body: {"id_token": idToken},
      );

      debugPrint("Status HTTP: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

      final responseData = json.decode(response.body);

      if (responseData["success"] == true) {
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

Future<void> loadSession() async {
  final prefs = await SharedPreferences.getInstance();
  bool login = prefs.getBool("isLogin") ?? false;
  
  print('📱 loadSession called, login from prefs: $login'); 

  if (login) {
    String? data = prefs.getString("user");
    print('📱 User data from prefs: $data'); 
    if (data != null) {
      user = jsonDecode(data);
      print('📱 User loaded successfully: ${user?["name"]}'); 
      _initSocket();
      notifyListeners();
    } else {
      print('📱 User data is null!'); 
    }
  } else {
    print('📱 User not logged in'); 
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
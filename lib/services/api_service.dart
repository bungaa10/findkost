import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {

  // Ganti dengan IP laptop yang menjalankan Laragon
  static const String baseUrl =
      "http://192.168.1.46/findkost_api";

  static Future<dynamic> get(
    String endpoint,
  ) async {

    final response = await http.get(
      Uri.parse(
        "$baseUrl/$endpoint",
      ),
    );

    print("========== GET DEBUG ==========");
    print("URL : $baseUrl/$endpoint");
    print("STATUS : ${response.statusCode}");
    print("BODY : ${response.body}");
    print("===============================");

    return jsonDecode(response.body);
  }

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {

    final response = await http.post(
      Uri.parse(
        "$baseUrl/$endpoint",
      ),
      body: body,
    );

    print("========== POST DEBUG ==========");
    print("URL : $baseUrl/$endpoint");
    print("STATUS : ${response.statusCode}");
    print("BODY : ${response.body}");
    print("================================");

    return jsonDecode(response.body);
  }
}
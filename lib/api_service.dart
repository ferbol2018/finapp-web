import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {

  // 🔥 Para Flutter Web (Chrome)
  static const String baseUrl = "https://finanzas-backend-u3gy.onrender.com";

  // ==========================
  // LOGIN
  // ==========================
  static Future<String?> login(String email, String password) async {

    final response = await http.post(
      Uri.parse("$baseUrl/usuarios/login"),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "username": email,
        "password": password,
      },
    );

    print("RESPUESTA LOGIN: ${response.body}");

    if (response.statusCode == 200) {

      final data = json.decode(response.body);
      final token = data["access_token"];

      if (token == null) {
        print("⚠ No vino access_token en la respuesta");
        return null;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);

      print("✅ TOKEN GUARDADO: $token");

      // 🔥 DEVOLVEMOS EL NOMBRE
      // Si tu backend no envía nombre, usamos el email
      return data["nombre"] ?? email;

    } else {
      print("❌ Error login: ${response.statusCode}");
      return null;
    }
  }

  // ==========================
  // OBTENER TOKEN
  // ==========================
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    print("📌 TOKEN LEIDO: $token");
    return token;
  }

  // ==========================
  // OBTENER MOVIMIENTOS
  // ==========================
  static Future<List<dynamic>> obtenerMovimientos() async {

    final token = await getToken();

    if (token == null) {
      throw Exception("No hay token guardado");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/movimientos/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("RESPUESTA MOVIMIENTOS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception("Token inválido o expirado");
    } else {
      throw Exception("Error al cargar movimientos");
    }
  }

  // ==========================
  // LOGOUT
  // ==========================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    print("🚪 TOKEN ELIMINADO");
  }
}

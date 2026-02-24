import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movimiento.dart';

class ApiService {

  // 🔥 Para Flutter Web (Chrome) - Produccion
  static const String baseUrl = "https://finanzas-backend-u3gy.onrender.com";

  // 🔥 Para Flutter Web (Chrome) - Desarrollo
  //static const String baseUrl = "http://127.0.0.1:8000";

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
  static Future<List<Movimiento>> obtenerMovimientos() async {

    final token = await getToken();

    if (token == null) {
      throw Exception("No hay token guardado");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/movimientos"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    print("RESPUESTA MOVIMIENTOS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Movimiento.fromJson(e)).toList();
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

  // ==========================
  // CREAR MOVIMIENTO
  // ==========================
  Future<bool> crearMovimiento({
  required int cuentaId,
  required String tipo,
  required double monto,
  required String categoria,
  required String descripcion,
}) async {

  final token = await getToken(); // tu función existente

  final response = await http.post(
    Uri.parse("$baseUrl/movimientos"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
    body: jsonEncode({
      "cuenta_id": cuentaId,
      "tipo": tipo,
      "monto": monto,
      "categoria": categoria,
      "descripcion": descripcion,
      "transaccion_id": null
    }),
  );

  return response.statusCode == 200;
}
  // ==========================
  // ELIMINAR MOVIMIENTO
  // ==========================
  static Future<void> eliminarMovimiento(int id) async {
  final token = await getToken();

  final response = await http.delete(
    Uri.parse("$baseUrl/movimientos/$id"),
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode != 200) {
    throw Exception("Error al eliminar movimiento");
  }
}

  // ==========================
  // EDITAR MOVIMIENTO
  // ==========================

Future<bool> editarMovimiento({
  required int id,
  required int cuentaId,
  required String tipo,
  required double monto,
  required String categoria,
  required String descripcion,
}) async {
  final token = await getToken();

  final response = await http.put(
    Uri.parse("$baseUrl/movimientos/$id"),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
    body: jsonEncode({
      "cuenta_id": cuentaId,
      "tipo": tipo,
      "monto": monto,
      "categoria": categoria,
      "descripcion": descripcion,
    }),
  );

  return response.statusCode == 200;
}

  // ==========================
  //Registrar por Voz
  // ==========================

    static Future<bool> registrarTexto(String texto) async {
      final token = await getToken();

      final response = await http.post(
        Uri.parse("$baseUrl/movimientos/registrar-texto"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"texto": texto}),
      );

      return response.statusCode == 200;
    }

static Future<Map<String, dynamic>> analizarTexto(String texto) async {
  final response = await http.post(
    Uri.parse("$baseUrl/movimientos/analizar-texto"),
    headers: await _headers(),   // ✅ AWAIT
    body: jsonEncode({"texto": texto}),
  );

  return jsonDecode(response.body);
}

static Future<Map<String, String>> _headers() async {
  final token = await getToken();

  return {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token",
  };
}
    


}

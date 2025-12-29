import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/cart_item_model.dart';

class CartService {
  static final String baseUrl = "${dotenv.env['BACKEND_URL']}/cart";

  static Future<List<CartItem>> fetchCart(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get?userId=$userId'),
        headers: {'token': token},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        Map<String, dynamic> cartData = data['cartData'] ?? {};

        return cartData.values
            .map((itemJson) => CartItem.fromJson(itemJson))
            .toList();
      }
      return [];
    } catch (e) {
      print("Service Error: $e");
      return [];
    }
  }

  static Future<bool> updateQuantity(
    String userId,
    String token,
    String productId,
    String color,
    int quantity,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/update'),
      headers: {'token': token, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'productId': productId,
        'color': color,
        'quantity': quantity,
      }),
    );
    return response.statusCode == 200;
  }

  static Future<bool> clearCart(String userId, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/empty'),
      headers: {'token': token, 'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteItem(
    String userId,
    String token,
    String productId,
    String color,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/delete'),
      headers: {'token': token, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'productId': productId,
        'color': color,
      }),
    );
    return response.statusCode == 200;
  }
}

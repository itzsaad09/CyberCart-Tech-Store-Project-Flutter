import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/myorders.dart';

class OrderService {
  static final String baseUrl = "${dotenv.env['BACKEND_URL']}/order";

  static Future<List<Order>> fetchUserOrders(String userId, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/userorders/$userId'),
      headers: {
        'Authorization': 'Bearer $token', // Assuming userAuth middleware requires this
        'token': token, 
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List ordersJson = data['orders'];
      return ordersJson.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }
}
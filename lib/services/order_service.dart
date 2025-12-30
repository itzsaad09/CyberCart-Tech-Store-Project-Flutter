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

  static Future<Map<String, dynamic>> placeOrder({
    required String userId,
    required String token,
    required List<dynamic> items,
    required double amount,
    required double shippingCharges,
    required Map<String, dynamic> address,
    required String paymentMethod,
    required DateTime deliveryDate,
    required String deliveryTimeSlot,
    Map<String, dynamic>? cardDetails,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/place'),
        headers: {
          'Content-Type': 'application/json',
          'token': token, // Matches userAuth middleware requirement
        },
        body: jsonEncode({
          'userId': userId,
          'cartItemsArray': items,
          'shippingFees': shippingCharges,
          'finalTotalBill': amount + shippingCharges,
          'shippingInfo': address,
          'paymentMethod': paymentMethod,
          'cardDetails': cardDetails,
          'deliveryDate': deliveryDate.toIso8601String(),
          'deliveryTimeSlot': deliveryTimeSlot,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}
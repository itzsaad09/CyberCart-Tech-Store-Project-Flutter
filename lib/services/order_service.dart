import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/myorders.dart';
import '../utils/messages_screen.dart';

class OrderService {
  static final String baseUrl = "${dotenv.env['BACKEND_URL']}/order";

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
        headers: {'Content-Type': 'application/json', 'token': token},
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

  static Future<List<Order>> fetchUserOrders(
    String userId,
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/userorders/$userId'),
      headers: {'token': token},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List ordersJson = data['orders'];
      return ordersJson.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  static Future<Map<String, dynamic>> fetchOrderById(
    String orderId,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$orderId'),
        headers: {'token': token, 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['order'];
      } else {
        throw Exception('Failed to load order details');
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  static Future<List<ChatPreview>> fetchOrderNotifications(
    String userId,
    String token,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/$userId'),
      headers: {'token': token},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['notifications'];
      return data
          .map(
            (json) => ChatPreview(
              senderName: "Order Update",
              lastMessage:
                  "Order #${json['orderId'].toString().substring(18)} has been ${json['status']}!",
              time: json['timestamp'].toString().split('T')[0],
              type: MessageType.system,
              avatarUrl: "",
              unreadCount: json['isRead'] ? 0 : 1,
            ),
          )
          .toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  static Future<void> markAllNotificationsAsRead(
    String userId,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/read-all'),
        headers: {'token': token, 'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark notifications as read');
      }
    } catch (e) {
      print("Error marking as read: $e");
    }
  }
}

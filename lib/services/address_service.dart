import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/address_model.dart';

class AddressService {
  static final String baseUrl = "${dotenv.env['BACKEND_URL']}/api/user";

  static Future<List<ShippingAddress>> fetchAddresses(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/shipping/$userId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List addressesJson = data['shippingDetails'] ?? [];
          return addressesJson
              .map((json) => ShippingAddress.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print("Fetch Service Error: $e");
      return [];
    }
  }

  static Future<bool> addAddress(String userId, ShippingAddress address) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addshipping'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'shippingInfo': address.toJson()}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print("Add Address Error: $e");
      return false;
    }
  }

  static Future<bool> editAddress(
    String token,
    String userId,
    ShippingAddress address,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/editshipping'),
        headers: {'Content-Type': 'application/json', 'token': token},
        body: jsonEncode({
          'userId': userId,
          'addressId': address.id,
          'updatedInfo': address.toJson(),
        }),
      );

      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteAddress(
    String token,
    String userId,
    String addressId,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/deleteshipping'),
        headers: {'Content-Type': 'application/json', 'token': token},
        body: jsonEncode({'userId': userId, 'addressId': addressId}),
      );

      final data = jsonDecode(response.body);
      return data['success'] ?? false;
    } catch (e) {
      return false;
    }
  }
}

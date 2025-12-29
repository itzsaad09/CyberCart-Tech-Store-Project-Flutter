import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/product_model.dart';

class ProductService {
  static final String baseUrl = "${dotenv.env['BACKEND_URL']}/product";

  static Future<List<Product>> getProducts({
    bool? isViral,
    bool? isNewArrival,
    String? category,
    String? keyword,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (isViral != null) {
        queryParams['viralProduct'] = isViral.toString();
      }
      if (isNewArrival != null) {
        queryParams['newArrival'] = isNewArrival.toString();
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
        queryParams['keyword'] = keyword;
      }

      final uri = Uri.parse(
        '$baseUrl/display',
      ).replace(queryParameters: queryParams);

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List data = body['products'] ?? [];

        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
      print("Product Fetch Error: $e");
      return [];
    }
  }
}

import 'package:flutter/material.dart';
import 'package:cybercart/utils/product_view.dart';

class Product {
  final String id;
  final String name;
  final List<String> images; // Backend returns image: { type: Array }
  final String brand;
  final String category;
  final String description;
  final double price;
  final String color;
  final int countInStock;
  final double rating;
  final int numReviews;
  final bool newArrival;
  final bool viralProduct;

  const Product({
    required this.id,
    required this.name,
    required this.images,
    required this.brand,
    required this.category,
    required this.description,
    required this.price,
    required this.color,
    required this.countInStock,
    this.rating = 0.0,
    this.numReviews = 0,
    this.newArrival = false,
    this.viralProduct = false,
  });

  /// Maps the JSON from productController.js to this Flutter Model
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      // Ensure we convert the dynamic list from JSON to a List<String>
      images: List<String>.from(json['image'] ?? []),
      brand: json['brand'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      color: json['color'] ?? '',
      countInStock: json['countInStock'] ?? 0,
      rating: (json['rating'] ?? 0).toDouble(),
      numReviews: json['numReviews'] ?? 0,
      newArrival: json['newArrival'] ?? false,
      viralProduct: json['viralProduct'] ?? false,
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProductViewScreen(product: product),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: product.images.isNotEmpty
                    ? Image.network(
                        product.images[0], // Display the first Cloudinary image
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                      )
                    : Container(
                        color: Colors.grey.shade100,
                        child: const Icon(Icons.image_outlined, size: 50, color: Colors.grey),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs. ${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${product.name} added to cart!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Add to Cart', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
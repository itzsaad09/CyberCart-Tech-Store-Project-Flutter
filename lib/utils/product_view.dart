import 'package:flutter/material.dart';
import 'package:cybercart/models/product_model.dart'; 

class ProductViewScreen extends StatelessWidget {
  final Product product;

  const ProductViewScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sharing ${product.name}')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${product.name} added to wishlist!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80), // Space for the floating button
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Product Image Carousel ---
            Container(
              height: 350,
              width: double.infinity,
              color: Colors.grey.shade100,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.image_outlined, size: 100, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text('Image: ${product.imageUrl}', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 2. Name & Category ---
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Category: ${product.category}',
                    style: const TextStyle(color: Colors.blueGrey, fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // --- 3. Price ---
                  Text(
                    'Rs. ${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                  const Divider(height: 32),

                  // --- 4. Description ---
                  Text(
                    'Product Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This is where the long, detailed description of the product will go. It covers features, specifications, warranty information, and other key selling points. For example: High-definition audio, 24-hour battery life, ergonomic design, and full compatibility with all smart devices.',
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // --- 5. Reviews/Ratings Placeholder ---
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber),
                      const Text(' 4.5 (124 Ratings)', style: TextStyle(fontSize: 16)),
                      const Spacer(),
                      TextButton(onPressed: () {}, child: const Text('View All Reviews')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      
      // --- Floating Add to Cart Button ---
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.shopping_cart_checkout, color: Colors.white),
            label: const Text(
              'Add to Cart',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            onPressed: () {
              // TODO: Implement actual cart logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${product.name} added to cart!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }
}
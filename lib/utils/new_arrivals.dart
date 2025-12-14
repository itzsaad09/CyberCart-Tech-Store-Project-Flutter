import 'package:flutter/material.dart';
import 'package:cybercart/models/product_model.dart'; 

final List<Product> newArrivals = [
  const Product(
    id: 'N001',
    name: 'JBL S278 Wireless Bluetooth Speaker',
    price: 2450.0,
    imageUrl: 'assets/products/speaker1.png', // Placeholder
    category: 'Speakers',
  ),
  const Product(
    id: 'N002',
    name: 'Transformer Robot Z90 Pro with ANC 7 EQ...',
    price: 3999.0,
    imageUrl: 'assets/products/airpods2.png', // Placeholder
    category: 'Earbuds',
  ),
  const Product(
    id: 'N003',
    name: 'Omax T20 Ultra Smartwatch',
    price: 1500.0,
    imageUrl: 'assets/products/watch2.png', // Placeholder
    category: 'Watches',
  ),
];

class NewArrivalsComponent extends StatelessWidget {
  const NewArrivalsComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Text(
            'New Arrivals',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          // FIX: Added the required gridDelegate argument
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: newArrivals.length,
          itemBuilder: (context, index) {
            final product = newArrivals[index];
            return ProductCard(product: product); 
          },
        ),
      ],
    );
  }
}
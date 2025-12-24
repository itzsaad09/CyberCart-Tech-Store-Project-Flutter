import 'package:flutter/material.dart';
import 'package:cybercart/models/product_model.dart';

final List<Product> viralProducts = [
  const Product(
    id: 'V001',
    name: 'D106 Mooon Mobile Phone Cooler',
    price: 3500.0,
    imageUrl: 'assets/products/watch1.png',
    category: 'Coolers',
  ),
  const Product(
    id: 'V002',
    name: 'Qunex Handsfree (Original...)',
    price: 399.0,
    imageUrl: 'assets/products/headset1.png',
    category: 'Headsets',
  ),
  const Product(
    id: 'V003',
    name: 'Transformer Robot Z90 Pro with ANC 7 EQ...',
    price: 3999.0,
    imageUrl: 'assets/products/airpods1.png',
    category: 'Earbuds',
  ),
  const Product(
    id: 'V004',
    name: 'Air 39 Bluetooth Transmission',
    price: 999.0,
    imageUrl: 'assets/products/headphone1.png',
    category: 'Headphones',
  ),
];

class ViralProductsComponent extends StatelessWidget {
  const ViralProductsComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Text(
            'Viral Products',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),

          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: viralProducts.length,
          itemBuilder: (context, index) {
            final product = viralProducts[index];
            return ProductCard(product: product);
          },
        ),
      ],
    );
  }
}

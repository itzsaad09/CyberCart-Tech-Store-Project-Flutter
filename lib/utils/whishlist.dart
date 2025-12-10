import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final double rating;
  final String imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.rating,
    required this.imageUrl,
  });
}

List<Product> initialWishlistItems = [
  const Product(
    id: 'W001',
    name: '4K Gaming Monitor',
    price: 450.00,
    rating: 4.6,
    imageUrl: 'assets/products/monitor.png',
  ),
  const Product(
    id: 'W002',
    name: 'Portable SSD 1TB',
    price: 79.99,
    rating: 4.3,
    imageUrl: 'assets/products/ssd.png',
  ),
  const Product(
    id: 'W003',
    name: 'Smartwatch V5 Pro',
    price: 199.00,
    rating: 4.5,
    imageUrl: 'assets/products/watch.png',
  ),
  const Product(
    id: 'W004',
    name: 'Gamer Headset 3000',
    price: 49.00,
    rating: 4.5,
    imageUrl: 'assets/products/headset.png',
  ),
];

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Product> _wishlistItems = initialWishlistItems;

  void _removeItem(String productId) {
    setState(() {
      _wishlistItems.removeWhere((item) => item.id == productId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item removed from Wishlist.')),
    );
  }

  void _moveToCart(Product product) {
    _removeItem(product.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} moved to Cart!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () {
              setState(() {
                _wishlistItems.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Wishlist cleared!')),
              );
            },
            tooltip: 'Clear Wishlist',
          ),
        ],
      ),
      body: _wishlistItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Your Wishlist is empty!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start adding your favorite products.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _wishlistItems.length,
                itemBuilder: (context, index) {
                  final item = _wishlistItems[index];
                  return _WishlistItemCard(
                    product: item,
                    onMoveToCart: _moveToCart,
                    onRemove: _removeItem,
                  );
                },
              ),
            ),
    );
  }
}

class _WishlistItemCard extends StatelessWidget {
  final Product product;
  final Function(Product) onMoveToCart;
  final Function(String) onRemove;

  const _WishlistItemCard({
    required this.product,
    required this.onMoveToCart,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Viewing ${product.name} details')),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black87,
                      size: 18,
                    ),
                    onPressed: () => onRemove(product.id),
                    tooltip: 'Remove from Wishlist',
                  ),
                ),
              ),

              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.laptop_chromebook,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => onMoveToCart(product),
                  icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                  label: const Text('Move to Cart'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).primaryColor,
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

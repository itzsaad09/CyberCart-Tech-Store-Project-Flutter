import 'package:flutter/material.dart';
import 'package:cybercart/utils/product_view.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/cart_service.dart';
import '../models/cart_item_model.dart';

class Product {
  final String id;
  final String name;
  final List<String> images;
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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
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

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int _quantity = 0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _checkInitialQuantity();
  }

  Future<void> _checkInitialQuantity() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated) return;

    try {
      final cartData = await CartService.fetchCart(auth.userId!, auth.token!);
      final existingItem = cartData.firstWhere(
        (item) =>
            item.productId == widget.product.id &&
            item.color == widget.product.color,
        orElse: () =>
            CartItem(productId: '', name: '', price: 0, quantity: 0, color: ''),
      );

      if (mounted && existingItem.quantity > 0) {
        setState(() {
          _quantity = existingItem.quantity;
        });
      }
    } catch (e) {
      debugPrint("Initial Qty Check Error: $e");
    }
  }

  Future<void> _updateCartQuantity(int newQuantity) async {
    if (newQuantity > widget.product.countInStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot add more than available stock.')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to manage your cart.')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    bool success = false;

    if (_quantity == 0 && newQuantity == 1) {
      success = await CartService.addToCart(
        userId: auth.userId!,
        token: auth.token!,
        productId: widget.product.id,
        quantity: 1,
        color: widget.product.color,
      );
    } else if (newQuantity == 0) {
      success = await CartService.deleteItem(
        auth.userId!,
        auth.token!,
        widget.product.id,
        widget.product.color,
      );
    } else {
      success = await CartService.updateQuantity(
        auth.userId!,
        auth.token!,
        widget.product.id,
        widget.product.color,
        newQuantity,
      );
    }

    if (success) {
      setState(() => _quantity = newQuantity);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update cart.')));
    }

    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = widget.product.countInStock <= 0;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProductViewScreen(product: widget.product),
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
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: widget.product.images.isNotEmpty
                    ? Image.network(
                        widget.product.images[0],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        color: isOutOfStock
                            ? Colors.black.withOpacity(0.3)
                            : null,
                        colorBlendMode: isOutOfStock ? BlendMode.darken : null,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image),
                      )
                    : Container(
                        color: Colors.grey.shade100,
                        child: const Icon(
                          Icons.image_outlined,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rs. ${widget.product.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isOutOfStock
                          ? Colors.grey
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),

                  _buildActionArea(isOutOfStock),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionArea(bool isOutOfStock) {
    if (_isProcessing) {
      return const Center(
        child: SizedBox(
          height: 36,
          width: 36,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (isOutOfStock) {
      return _buildDisabledButton();
    }

    if (_quantity > 0) {
      return _buildQuantitySelector();
    }

    return _buildAddButton();
  }

  Widget _buildDisabledButton() {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade400,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
        ),
        child: const Text(
          'Out of Stock',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: ElevatedButton(
        onPressed: () => _updateCartQuantity(1),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
        ),
        child: const Text(
          'Add',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            onPressed: () => _updateCartQuantity(_quantity - 1),
            icon: Icon(
              Icons.remove,
              size: 18,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Text(
            '$_quantity',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            padding: EdgeInsets.zero,

            onPressed: _quantity >= widget.product.countInStock
                ? null
                : () => _updateCartQuantity(_quantity + 1),
            icon: Icon(
              Icons.add,
              size: 18,
              color: _quantity >= widget.product.countInStock
                  ? Colors.grey
                  : Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

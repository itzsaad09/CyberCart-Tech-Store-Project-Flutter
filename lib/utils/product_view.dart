import 'package:flutter/material.dart';
import 'package:cybercart/models/product_model.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/cart_service.dart';
import '../models/cart_item_model.dart';

class ProductViewScreen extends StatefulWidget {
  final Product product;

  const ProductViewScreen({super.key, required this.product});

  @override
  State<ProductViewScreen> createState() => _ProductViewScreenState();
}

class _ProductViewScreenState extends State<ProductViewScreen> {
  int _quantity = 0;
  bool _isProcessing = false;
  final PageController _pageController = PageController();
  int _currentPage = 0;

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
        setState(() => _quantity = existingItem.quantity);
      }
    } catch (e) {
      debugPrint("Qty Check Error: $e");
    }
  }

  Future<void> _handleCartAction(int newQuantity) async {
    if (newQuantity > widget.product.countInStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot exceed available stock.')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please log in first.')));
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
    }
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = widget.product.countInStock <= 0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 380,
                  width: double.infinity,
                  // Use cardColor for the image background to provide slight contrast in dark mode
                  color: isDark ? theme.cardColor : Colors.white,
                  child: widget.product.images.isNotEmpty
                      ? PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) =>
                              setState(() => _currentPage = index),
                          itemCount: widget.product.images.length,
                          itemBuilder: (context, index) => InteractiveViewer(
                            child: Image.network(
                              widget.product.images[index],
                              fit: BoxFit.contain,
                              color: isOutOfStock
                                  ? Colors.black.withOpacity(0.2)
                                  : null,
                              colorBlendMode: isOutOfStock
                                  ? BlendMode.darken
                                  : null,
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.image_outlined, size: 100),
                        ),
                ),
                if (widget.product.images.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.product.images.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 12 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? theme.primaryColor
                                : theme.dividerColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.product.brand,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        isOutOfStock ? 'OUT OF STOCK' : 'IN STOCK',
                        style: TextStyle(
                          color: isOutOfStock ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.product.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Rs. ${widget.product.price.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.primaryColor,
                    ),
                  ),
                  const Divider(height: 40),
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      Text(
                        ' ${widget.product.rating} ',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '(${widget.product.numReviews} Reviews)',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: _buildActionArea(isOutOfStock),
      ),
    );
  }

  Widget _buildActionArea(bool isOutOfStock) {
    if (_isProcessing) {
      return const SizedBox(
        height: 55,
        child: Center(child: CircularProgressIndicator()),
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
      height: 55,
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          'PRODUCT OUT OF STOCK',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
        label: const Text(
          'ADD TO CART',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        onPressed: () => _handleCartAction(1),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      height: 55,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(
              Icons.remove_circle_outline,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () => _handleCartAction(_quantity - 1),
          ),
          Text(
            '$_quantity Items in Cart',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: Colors.white,
              size: 30,
            ),
            onPressed: _quantity >= widget.product.countInStock
                ? null
                : () => _handleCartAction(_quantity + 1),
          ),
        ],
      ),
    );
  }
}

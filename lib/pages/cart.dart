import 'package:flutter/material.dart';
import 'package:cybercart/utils/checkout_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/cart_item_model.dart';
import '../services/cart_service.dart';

const double freeShippingThreshold = 1999.0;
const double standardShippingFee = 150.0;

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  List<CartItem> _cartItems = [];
  double _subtotal = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated) return;

    try {
      final items = await CartService.fetchCart(auth.userId!, auth.token!);

      if (mounted) {
        setState(() {
          _cartItems = items;

          _subtotal = _cartItems.fold(0.0, (sum, item) => sum + item.total);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double get _shippingFee {
    if (_subtotal >= freeShippingThreshold || _subtotal == 0) {
      return 0.00;
    }
    return standardShippingFee;
  }

  double get _total => _subtotal + _shippingFee;

  void _updateQuantity(String productId, String color, int newQuantity) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    bool success = await CartService.updateQuantity(
      auth.userId!,
      auth.token!,
      productId,
      color,
      newQuantity,
    );

    if (success) {
      _loadCart();
    }
  }

  void _removeItem(String productId, String color) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    bool success = await CartService.deleteItem(
      auth.userId!,
      auth.token!,
      productId,
      color,
    );

    if (success) {
      _loadCart();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item removed from cart.')));
    }
  }

  void _clearCart() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    bool success = await CartService.clearCart(auth.userId!, auth.token!);

    if (success) {
      _loadCart();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cart cleared!')));
    }
  }

  void _checkout() {
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Your cart is empty!')));
      return;
    }

    final List<Map<String, dynamic>> itemsForBackend = _cartItems
        .map(
          (item) => {
            'productId': item.productId,
            'name': item.name,
            'price': item.price,
            'quantity': item.quantity,
            'color': item.color,
            'image': item.imageUrl,
          },
        )
        .toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            CheckoutScreen(totalAmount: _subtotal, cartItems: itemsForBackend),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: _clearCart,
            tooltip: 'Clear Cart',
          ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cartItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
                    itemCount: _cartItems.length,
                    itemBuilder: (context, index) {
                      final item = _cartItems[index];
                      return _CartItemCard(
                        item: item,
                        onQuantityChanged: _updateQuantity,
                        onRemove: _removeItem,
                      );
                    },
                  ),
                ),

                _CartSummary(
                  subtotal: _subtotal,
                  shippingFee: _shippingFee,
                  total: _total,
                  onCheckout: _checkout,
                ),
                const SizedBox(height: 80),
              ],
            ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final Function(String, String, int) onQuantityChanged;
  final Function(String, String) onRemove;

  const _CartItemCard({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: item.imageUrl != null
                  ? Image.network(
                      item.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.image_outlined,
                        color: Colors.grey,
                        size: 40,
                      ),
                    )
                  : const Icon(
                      Icons.image_outlined,
                      color: Colors.grey,
                      size: 40,
                    ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  Text(
                    'Rs. ${item.price.toStringAsFixed(2)} | Color: ${item.color}',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            _buildQuantityButton(
                              context,
                              icon: Icons.remove,
                              onTap: () => onQuantityChanged(
                                item.productId,
                                item.color,
                                item.quantity - 1,
                              ),
                              isDecrement: true,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text(
                                item.quantity.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            _buildQuantityButton(
                              context,
                              icon: Icons.add,
                              onTap: () => onQuantityChanged(
                                item.productId,
                                item.color,
                                item.quantity + 1,
                              ),
                              isDecrement: false,
                            ),
                          ],
                        ),
                      ),

                      Text(
                        'Rs. ${item.total.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: () => onRemove(item.productId, item.color),
              tooltip: 'Remove',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
    required bool isDecrement,
  }) {
    final buttonIcon = isDecrement && item.quantity == 1
        ? Icons.delete_outline
        : icon;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(
          buttonIcon,
          size: 20,
          color: isDecrement && item.quantity == 1
              ? Colors.red
              : Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final double subtotal;
  final double shippingFee;
  final double total;
  final VoidCallback onCheckout;

  const _CartSummary({
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.onCheckout,
  });

  Widget _buildSummaryRow(
    BuildContext context,
    String title,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: isTotal
                ? Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
                : const TextStyle(fontSize: 16, color: Colors.blueGrey),
          ),
          Text(
            value,
            style: isTotal
                ? Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  )
                : const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String shippingText = shippingFee == 0
        ? 'Free'
        : 'Rs. ${shippingFee.toStringAsFixed(2)}';
    String? savingMessage = shippingFee == 0
        ? '🎉 You qualify for FREE shipping!'
        : (freeShippingThreshold - subtotal > 0)
        ? 'Add Rs. ${(freeShippingThreshold - subtotal).toStringAsFixed(2)} to get FREE shipping!'
        : null;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSummaryRow(
            context,
            'Subtotal',
            'Rs. ${subtotal.toStringAsFixed(2)}',
          ),
          _buildSummaryRow(context, 'Shipping', shippingText),
          if (savingMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                savingMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: shippingFee == 0
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const Divider(height: 20, thickness: 1),
          _buildSummaryRow(
            context,
            'Total',
            'Rs. ${total.toStringAsFixed(2)}',
            isTotal: true,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onCheckout,
              icon: const Icon(Icons.payment_outlined, color: Colors.white),
              label: const Text(
                'Proceed to Checkout',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

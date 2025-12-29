class CartItem {
  final String productId;
  final String name;
  final double price;
  int quantity;
  final String color;
  final String? imageUrl;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.color,
    this.imageUrl,
  });

  double get total => price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    String? extractedImage;
    if (json['image'] is List && (json['image'] as List).isNotEmpty) {
      extractedImage = json['image'][0];
    } else if (json['image'] is String) {
      extractedImage = json['image'];
    }

    return CartItem(
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] ?? 1,
      color: json['color'] ?? '',
      imageUrl: extractedImage,
    );
  }
}

import 'package:flutter/foundation.dart';

class Product {
  final String id;
  final String name;
  final String image;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  // Efficient getters with computed properties
  Map<String, CartItem> get items => Map.unmodifiable(_items);
  
  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);
  
  double get totalAmount => _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  
  bool get isEmpty => _items.isEmpty;
  
  bool get isNotEmpty => _items.isNotEmpty;

  // Efficient add item with proper state management
  void addItem(Product product, {int quantity = 1}) {
    if (_items.containsKey(product.id)) {
      _items[product.id] = _items[product.id]!.copyWith(
        quantity: _items[product.id]!.quantity + quantity,
      );
    } else {
      _items[product.id] = CartItem(
        product: product,
        quantity: quantity,
      );
    }
    notifyListeners();
  }

  // Remove single item efficiently
  void removeItem(String productId) {
    if (_items.containsKey(productId)) {
      if (_items[productId]!.quantity > 1) {
        _items[productId] = _items[productId]!.copyWith(
          quantity: _items[productId]!.quantity - 1,
        );
      } else {
        _items.remove(productId);
      }
      notifyListeners();
    }
  }

  // Remove entire product from cart
  void removeProduct(String productId) {
    if (_items.containsKey(productId)) {
      _items.remove(productId);
      notifyListeners();
    }
  }

  // Update quantity directly
  void updateQuantity(String productId, int newQuantity) {
    if (_items.containsKey(productId)) {
      if (newQuantity <= 0) {
        _items.remove(productId);
      } else {
        _items[productId] = _items[productId]!.copyWith(quantity: newQuantity);
      }
      notifyListeners();
    }
  }

  // Clear cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Get specific item quantity
  int getQuantity(String productId) {
    return _items[productId]?.quantity ?? 0;
  }

  // Check if product is in cart
  bool isInCart(String productId) {
    return _items.containsKey(productId);
  }

  // Get cart items as list for display
  List<CartItem> get cartItemsList => _items.values.toList();
}
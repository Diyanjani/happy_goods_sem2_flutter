import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../providers/cart_provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final String imagePath;
  final String name;
  final double price;

  const ProductDetailsScreen({
    super.key,
    required this.imagePath,
    required this.name,
    required this.price,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int quantity = 1;
  String? jsonDescription;

  @override
  void initState() {
    super.initState();
    _loadDescriptionFromJson();
  }

  Future<void> _loadDescriptionFromJson() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/product_descriptions.json');
      final Map<String, dynamic> descriptions = json.decode(jsonString);
      if (mounted) {
        setState(() {
          jsonDescription = descriptions[widget.name];
        });
      }
    } catch (e) {
      // If JSON loading fails, jsonDescription remains null and fallback is used
    }
  }

  void increment() => setState(() => quantity++);
  void decrement() {
    if (quantity > 1) setState(() => quantity--);
  }

  final Map<String, String> descriptions = {
    'Carrot': 'Rich in beta-carotene and great for eyesight and skin health.',
    'Beans': 'Fresh green beans packed with fiber and essential nutrients.',
    'Beetroot': 'A natural detoxifier and great for boosting stamina.',
    'Brinjal': 'Soft and flavorful, ideal for curries and grilling.',
    'Pumpkin': 'Nutritious and rich in vitamins A and C.',
    'Tomato': 'Juicy and full of antioxidants like lycopene.',
    'Potato': 'Versatile and filling, a staple in many dishes.',
    'Onions': 'Essential in every kitchen for flavor and aroma.',
    'Apple': 'Crunchy, sweet, and perfect for a healthy snack.',
    'Banana': 'Rich in potassium and natural energy.',
    'Grapes': 'Sweet and loaded with antioxidants.',
    'Orange': 'Citrusy and packed with vitamin C.',
    'Watermelon': 'Refreshing and hydrating, perfect for summer.',
    'Pineapple': 'Tropical sweetness with digestive enzymes.',
    'Strawberry': 'Sweet berries rich in vitamin C and antioxidants.',
    'Guava': 'Tropical fruit with high vitamin C content.',
    'Chicken': 'High-quality protein for a balanced diet.',
    'Beef': 'Rich in iron and protein, great for strength.',
    'Pork': 'Tender and flavorful, perfect for various dishes.',
    'Fish': 'Omega-3 rich protein for heart health.',
    'Chicken leg': 'Juicy and tender, ideal for grilling.',
    'Boneless Chicken': 'Convenient and versatile protein option.',
    'Pork Sausages': 'Flavorful sausages perfect for breakfast or BBQ.',
    'Fresh Milk': 'Rich in calcium and essential nutrients.',
    'Milk packet': 'Convenient packaging for daily use.',
    'Cheese': 'Creamy and rich, adds flavor to any dish.',
    'Butter': 'Smooth and creamy, perfect for cooking and baking.',
    'Curd': 'Probiotic-rich and great for digestion.',
    'Yogurt': 'Healthy and delicious, packed with probiotics.',
    'Cream': 'Rich and smooth, perfect for desserts.',
    'Ice Cream': 'Sweet treat to cool down and indulge.',
    'Vanilla': 'Classic flavor for desserts and beverages.',
    'Coca Cola': 'Classic refreshing cola drink.',
    'Fanta': 'Fruity and fizzy, a refreshing soda.',
    '7UP': 'Lemon-lime soda with a crisp taste.',
    'EGB': 'Ginger-based beverage with a spicy kick.',
    'Redbull': 'Energy drink to boost alertness and performance.',
    'Sprite': 'Crisp, clean lemon-lime soda.',
    'Suncrush': 'Tropical soft drink with a sweet twist.',
    'Ayush Facewash': 'Ayurvedic shampoo for healthy and strong hair.',
    'Skin Toner': 'Refreshes skin and tightens pores.',
    'Face Cream': 'Moisturizes and softens the skin.',
    'Mens Facewash': 'Cleanses dirt and excess oil gently.',
    'Lipbalm': 'Keeps your lips soft and moisturized.',
    'Glow and Lovely': 'Fragrance-infused lotion for smooth skin.',
    'Vivya facewash': 'Gentle skincare solution for daily use.',
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String description = jsonDescription ?? 
        descriptions[widget.name] ??
        "This is a detailed description of the product.";

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        actions: [
          // Cart icon with live count in app bar
          Selector<CartProvider, int>(
            selector: (context, cart) => cart.itemCount,
            builder: (context, itemCount, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      // Navigate to cart or show cart summary
                    },
                  ),
                  if (itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$itemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(widget.imagePath, height: 250, fit: BoxFit.cover),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(description, style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Rs. ${widget.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text('Quantity:', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 16),
                    IconButton(onPressed: decrement, icon: const Icon(Icons.remove)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(quantity.toString(), style: const TextStyle(fontSize: 18)),
                    ),
                    IconButton(onPressed: increment, icon: const Icon(Icons.add)),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    final isInCart = cart.isInCart(widget.name.toLowerCase().replaceAll(' ', '_'));
                    final currentQuantity = cart.getQuantity(widget.name.toLowerCase().replaceAll(' ', '_'));
                    
                    return Column(
                      children: [
                        if (isInCart)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(
                                  'In Cart: $currentQuantity item${currentQuantity > 1 ? 's' : ''}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              final product = Product(
                                id: widget.name.toLowerCase().replaceAll(' ', '_'),
                                name: widget.name,
                                image: widget.imagePath,
                                price: widget.price,
                              );
                              
                              // Use Provider to add to cart
                              cart.addItem(product, quantity: quantity);
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${widget.name} added to cart'),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 2),
                                  action: SnackBarAction(
                                    label: 'View Cart',
                                    textColor: Colors.white,
                                    onPressed: () {
                                      // Navigate back to main screen and switch to cart tab
                                      Navigator.pop(context);
                                      // You could also use a navigation callback here if needed
                                    },
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  margin: const EdgeInsets.all(16),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: Text(
                              isInCart ? "Add More to Cart" : "Add to Cart",
                            ),
                          ),
                        ),
                        const SizedBox(height: 20), // Extra bottom padding
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
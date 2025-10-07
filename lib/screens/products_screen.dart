import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  final String? selectedCategory;

  const ProductsScreen({super.key, this.selectedCategory});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ScrollController scrollController = ScrollController();
  final Map<String, GlobalKey> categoryKeys = {};

  final Map<String, List<Map<String, dynamic>>> productsByCategory = {
    'Vegetables': [
      {'name': 'Carrot', 'image': 'assets/images/carrot.jpg', 'price': 130.00},
      {'name': 'Beans', 'image': 'assets/images/beans.jpg', 'price': 140.00},
      {
        'name': 'Beetroot',
        'image': 'assets/images/beetroot.jpg',
        'price': 120.00,
      },
      {
        'name': 'Brinjal',
        'image': 'assets/images/brinjal.jpg',
        'price': 110.00,
      },
      {'name': 'Pumpkin', 'image': 'assets/images/pumpkin.jpg', 'price': 90.00},
      {'name': 'Tomato', 'image': 'assets/images/tomato.jpg', 'price': 100.00},
      {'name': 'Potato', 'image': 'assets/images/potato.jpg', 'price': 95.00},
      {'name': 'Onions', 'image': 'assets/images/onions.png', 'price': 150.00},
    ],
    'Fruits': [
      {'name': 'Apple', 'image': 'assets/images/apple.jpg', 'price': 200.00},
      {'name': 'Banana', 'image': 'assets/images/banana.jpg', 'price': 60.00},
      {'name': 'Grapes', 'image': 'assets/images/grapes.jpg', 'price': 280.00},
      {'name': 'Guava', 'image': 'assets/images/guava.jpg', 'price': 100.00},
      {'name': 'Oranges', 'image': 'assets/images/orange.jpg', 'price': 220.00},
      {
        'name': 'Pineapple',
        'image': 'assets/images/pineapple.jpg',
        'price': 180.00,
      },
      {
        'name': 'Strawberry',
        'image': 'assets/images/strawberry.jpg',
        'price': 350.00,
      },
      {
        'name': 'Watermelon',
        'image': 'assets/images/watermelon.jpg',
        'price': 250.00,
      },
    ],
    'Dairy Products': [
      {'name': 'Butter', 'image': 'assets/images/butter.jpg', 'price': 450.00},
      {'name': 'Cheese', 'image': 'assets/images/cheese.jpg', 'price': 500.00},
      {'name': 'Curd', 'image': 'assets/images/curd.jpg', 'price': 220.00},
      {
        'name': 'Freshmilk',
        'image': 'assets/images/freshmilk.jpg',
        'price': 18.00,
      },
      {
        'name': 'Icecream',
        'image': 'assets/images/icecream.jpg',
        'price': 300.00,
      },
      {
        'name': 'Chocolate Milk Packet',
        'image': 'assets/images/milkpacket.jpg',
        'price': 180.00,
      },
      {
        'name': 'Vanilla Milk Packet',
        'image': 'assets/images/vanilla.jpg',
        'price': 220.00,
      },
      {'name': 'Yogurt', 'image': 'assets/images/yogurt.jpg', 'price': 90.00},
    ],
    'Fresh Meat': [
      {'name': 'Beef', 'image': 'assets/images/beef.jpg', 'price': 950.00},
      {
        'name': 'Boneless Chicken',
        'image': 'assets/images/bonelesschick.jpg',
        'price': 800.00,
      },
      {
        'name': 'Chicken',
        'image': 'assets/images/chicken.jpg',
        'price': 750.00,
      },
      {
        'name': 'Chicken Leg',
        'image': 'assets/images/chickenleg.jpg',
        'price': 700.00,
      },
      {'name': 'Fish', 'image': 'assets/images/fish.jpg', 'price': 1200.00},
      {'name': 'Pork', 'image': 'assets/images/pork.jpg', 'price': 850.00},
      {
        'name': 'Pork Sausages',
        'image': 'assets/images/porksau.jpg',
        'price': 480.00,
      },
      {
        'name': 'Sausages',
        'image': 'assets/images/sausages.jpg',
        'price': 450.00,
      },
    ],
    'Beverages': [
      {
        'name': 'Coca-cola',
        'image': 'assets/images/cocacola.jpg',
        'price': 180.00,
      },
      {
        'name': 'Cream Soda',
        'image': 'assets/images/creamsoda.jpg',
        'price': 150.00,
      },
      {'name': 'Fanta', 'image': 'assets/images/fanta.jpg', 'price': 170.00},
      {'name': '7UP', 'image': 'assets/images/7up.jpg', 'price': 170.00},
      {'name': 'EGB', 'image': 'assets/images/egb.jpg', 'price': 160.00},
      {
        'name': 'Redbull',
        'image': 'assets/images/redbull.jpg',
        'price': 350.00,
      },
      {'name': 'Sprite', 'image': 'assets/images/sprite.jpg', 'price': 180.00},
      {
        'name': 'Suncrush',
        'image': 'assets/images/suncrush.jpg',
        'price': 150.00,
      },
    ],
    'Beauty Products': [
      {
        'name': 'Ayush Facewash',
        'image': 'assets/images/ayush.jpg',
        'price': 240.00,
      },
      {
        'name': 'Skin Toner',
        'image': 'assets/images/toner.jpg',
        'price': 600.00,
      },
      {
        'name': 'Face Cream',
        'image': 'assets/images/cream.jpg',
        'price': 350.00,
      },
      {
        'name': 'Mens Facewash',
        'image': 'assets/images/facewash.jpg',
        'price': 400.00,
      },
      {
        'name': 'Lipbalm',
        'image': 'assets/images/lipbalm.jpg',
        'price': 200.00,
      },
      {
        'name': 'Glow and Lovely',
        'image': 'assets/images/love.jpg',
        'price': 500.00,
      },
      {
        'name': 'Vivya Facewash',
        'image': 'assets/images/pure.jpg',
        'price': 450.00,
      },
    ],
  };

  Map<String, int> productQuantities = {};

  @override
  void initState() {
    super.initState();
    for (var key in productsByCategory.keys) {
      categoryKeys[key] = GlobalKey();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.selectedCategory != null) {
        final key = categoryKeys[widget.selectedCategory!];
        if (key != null && key.currentContext != null) {
          Scrollable.ensureVisible(
            key.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void incrementQuantity(String name) {
    setState(() {
      productQuantities[name] = (productQuantities[name] ?? 1) + 1;
    });
  }

  void decrementQuantity(String name) {
    setState(() {
      if ((productQuantities[name] ?? 1) > 1) {
        productQuantities[name] = (productQuantities[name] ?? 1) - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = productsByCategory.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        backgroundColor: Colors.lightGreen,
        centerTitle: true,
        actions: [
          // Cart icon with live count
          Selector<CartProvider, int>(
            selector: (context, cart) => cart.itemCount,
            builder: (context, itemCount, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      // Navigate to cart tab would be handled by bottom navigation
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
      body: ListView(
        controller: scrollController,
        children:
            categories.map((category) {
              final products = productsByCategory[category]!;

              return Container(
                key: categoryKeys[category],
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Styled Category Heading
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.lightGreen.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final quantity =
                              productQuantities[product['name']] ?? 1;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProductDetailsScreen(
                                        imagePath: product['image'],
                                        name: product['name'],
                                        price: product['price'],
                                      ),
                                ),
                              );
                            },
                            child: Container(
                              width: 160,
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Image.asset(
                                      product['image'],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    product['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text('Rs. ${product['price']}'),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove),
                                        onPressed:
                                            () => decrementQuantity(
                                              product['name'],
                                            ),
                                      ),
                                      Text(quantity.toString()),
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed:
                                            () => incrementQuantity(
                                              product['name'],
                                            ),
                                      ),
                                    ],
                                  ),
                                  Consumer<CartProvider>(
                                    builder: (context, cart, child) {
                                      final productId = product['name'].toString().toLowerCase().replaceAll(' ', '_');
                                      final isInCart = cart.isInCart(productId);
                                      final cartQuantity = cart.getQuantity(productId);
                                      
                                      return Column(
                                        children: [
                                          if (isInCart)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              margin: const EdgeInsets.only(bottom: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: Colors.green.withOpacity(0.3)),
                                              ),
                                              child: Text(
                                                'In Cart: $cartQuantity',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.lightGreen,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            ),
                                            onPressed: () {
                                              final productToAdd = Product(
                                                id: productId,
                                                name: product['name'],
                                                image: product['image'],
                                                price: product['price'].toDouble(),
                                              );
                                              
                                              // Use Provider to add to cart
                                              cart.addItem(productToAdd, quantity: quantity);
                                              
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('${product['name']} added to cart'),
                                                  backgroundColor: Colors.green,
                                                  duration: const Duration(seconds: 1),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              isInCart ? 'Add More' : 'Add to Cart',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }
}

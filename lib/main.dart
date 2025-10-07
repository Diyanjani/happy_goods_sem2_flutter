import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/products_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/battery_widget.dart';
import 'widgets/network_status_widget.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Happy Goods',
          theme: ThemeProvider.lightTheme,
          darkTheme: ThemeProvider.darkTheme,
          themeMode: themeProvider.materialThemeMode,
          home: Consumer<AuthProvider>(
            builder: (context, auth, child) {
              // Initialize auth on first build
              if (auth.state == AuthState.initial) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  auth.initializeAuth();
                });
              }

              // Show loading while initializing
              if (auth.isLoading && auth.state == AuthState.loading) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // Navigate based on auth state
              return auth.isAuthenticated ? MainNavigation() : LoginScreen();
            },
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    ProductsScreen(selectedCategory: 'Vegetables'),
    CartScreen(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Battery and Network status widgets at the top
          SafeArea(
            bottom: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const NetworkStatusWidget(),
                  const Spacer(),
                  // Cart icon with live count using Selector for efficiency
                  Selector<CartProvider, int>(
                    selector: (context, cart) => cart.itemCount,
                    builder: (context, itemCount, child) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (itemCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$itemCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                        ],
                      );
                    },
                  ),
                  const BatteryWidget(),
                ],
              ),
            ),
          ),
          // Main screen content
          Expanded(child: _screens[_currentIndex]),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

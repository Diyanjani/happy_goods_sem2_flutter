import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/cart_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  String paymentMethod = 'Cash';
  bool _isLoadingLocation = false;

  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController securityCodeController = TextEditingController();
  final TextEditingController nameOnCardController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) return 'This field is required';
    return null;
  }

  Future<bool> _requestLocationPermission() async {
    final status = await Permission.location.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      final result = await Permission.location.request();
      return result.isGranted;
    }
    
    return false;
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location services are disabled. Please enable them.'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Check location permission
      bool hasPermission = await _requestLocationPermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission is required to detect your location.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15), // Add timeout
      );

      // Use reverse geocoding to get actual address
      String detectedCity = 'Unknown Location';
      
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark placemark = placemarks.first;
          
          // Try to get the most relevant location name
          if (placemark.locality != null && placemark.locality!.isNotEmpty) {
            detectedCity = placemark.locality!; // City name
          } else if (placemark.subAdministrativeArea != null && placemark.subAdministrativeArea!.isNotEmpty) {
            detectedCity = placemark.subAdministrativeArea!; // County/District
          } else if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
            detectedCity = placemark.administrativeArea!; // State/Province
          } else {
            // Fallback to coordinates if no readable address is found
            detectedCity = "Location (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})";
          }
          
          // Add country for context if available
          if (placemark.country != null && placemark.country!.isNotEmpty && placemark.country != detectedCity) {
            detectedCity += ", ${placemark.country}";
          }
        } else {
          // Fallback if no placemark data is available
          detectedCity = "Location (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})";
        }
      } catch (geocodingError) {
        // If reverse geocoding fails, show coordinates
        detectedCity = "Location (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})";
        print('Geocoding error: $geocodingError');
      }
      
      setState(() {
        cityController.text = detectedCity;
        _isLoadingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Location detected: $detectedCity'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      
      String errorMessage = 'Failed to get location';
      if (e.toString().contains('permission')) {
        errorMessage = 'Location permission required';
      } else if (e.toString().contains('disabled')) {
        errorMessage = 'Please enable location services';
      } else if (e.toString().contains('timeout') || e.toString().contains('time')) {
        errorMessage = 'Location request timed out. Please try again.';
      } else {
        errorMessage = 'Failed to get location: ${e.toString()}';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _getCurrentLocation,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Checkout (${cart.itemCount} items)'),
          ),
          body: cart.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Your cart is empty',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
              const Text(
                "Shipping Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              TextFormField(
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: _requiredValidator,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: _requiredValidator,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: _requiredValidator,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Address'),
                validator: _requiredValidator,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: cityController,
                      decoration: const InputDecoration(labelText: 'City'),
                      validator: _requiredValidator,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                      icon: _isLoadingLocation 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.location_on, size: 18),
                      label: Text(
                        _isLoadingLocation ? 'Detecting...' : 'Select Location',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade100,
                        foregroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Postal Code'),
                validator: _requiredValidator,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: _requiredValidator,
              ),

              const SizedBox(height: 20),
              const Text(
                "Payment Method",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              DropdownButton<String>(
                value: paymentMethod,
                items:
                    ['Cash', 'Credit Card', 'Debit Card'].map((method) {
                      return DropdownMenuItem<String>(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                onChanged: (value) => setState(() => paymentMethod = value!),
              ),

              if (paymentMethod != 'Cash') ...[
                TextFormField(
                  controller: cardNumberController,
                  decoration: const InputDecoration(labelText: 'Card Number'),
                  validator: _requiredValidator,
                ),
                TextFormField(
                  controller: expiryDateController,
                  decoration: const InputDecoration(labelText: 'Expiry Date'),
                  validator: _requiredValidator,
                ),
                TextFormField(
                  controller: securityCodeController,
                  decoration: const InputDecoration(labelText: 'Security Code'),
                  validator: _requiredValidator,
                ),
                TextFormField(
                  controller: nameOnCardController,
                  decoration: const InputDecoration(labelText: 'Name on Card'),
                  validator: _requiredValidator,
                ),
              ],

              const SizedBox(height: 20),
              const Text(
                "Order Summary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              ...cart.cartItemsList.map((cartItem) {
                return ListTile(
                  title: Text('${cartItem.product.name} x${cartItem.quantity}'),
                  trailing: Text('Rs. ${cartItem.totalPrice.toStringAsFixed(2)}'),
                );
              }).toList(),

              const Divider(),
              ListTile(
                title: const Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text('Rs. ${cart.totalAmount.toStringAsFixed(2)}'),
              ),
              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Clear cart after successful order
                      cart.clearCart();
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Order Placed Successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      
                      // Navigate back to main screen
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text('Place Order'),
                ),
              ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}

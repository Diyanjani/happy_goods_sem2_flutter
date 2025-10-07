import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  AuthState _state = AuthState.initial;
  String? _errorMessage;

  // Getters
  User? get currentUser => _currentUser;
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated && _currentUser != null;
  bool get isLoading => _state == AuthState.loading;
  bool get hasError => _state == AuthState.error;

  // Efficient login with proper state management
  Future<void> login(String email, String password) async {
    _updateState(AuthState.loading);
    _errorMessage = null;

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Simple validation for demo
      if (email.isNotEmpty && password.length >= 6) {
        _currentUser = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _extractNameFromEmail(email),
          email: email,
          avatarUrl: 'assets/images/dili.JPG',
        );
        _updateState(AuthState.authenticated);
      } else {
        throw Exception('Invalid credentials');
      }
    } catch (e) {
      _errorMessage = e.toString();
      _updateState(AuthState.error);
    }
  }

  // Register new user
  Future<void> register(String name, String email, String password) async {
    _updateState(AuthState.loading);
    _errorMessage = null;

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Simple validation for demo
      if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
        _currentUser = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          email: email,
          avatarUrl: 'assets/images/dili.JPG',
        );
        _updateState(AuthState.authenticated);
      } else {
        throw Exception('Registration failed: Invalid information');
      }
    } catch (e) {
      _errorMessage = e.toString();
      _updateState(AuthState.error);
    }
  }

  // Logout user
  void logout() {
    _currentUser = null;
    _errorMessage = null;
    _updateState(AuthState.unauthenticated);
  }

  // Update user profile
  void updateUserProfile({String? name, String? avatarUrl}) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        name: name,
        avatarUrl: avatarUrl,
      );
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _updateState(_currentUser != null ? AuthState.authenticated : AuthState.unauthenticated);
    }
  }

  // Private helper methods
  void _updateState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  String _extractNameFromEmail(String email) {
    final parts = email.split('@');
    if (parts.isNotEmpty) {
      return parts[0].replaceAll('.', ' ').replaceAll('_', ' ').trim();
    }
    return 'User';
  }

  // Initialize auth state (could check for stored tokens)
  Future<void> initializeAuth() async {
    _updateState(AuthState.loading);
    
    // Simulate checking for stored authentication
    await Future.delayed(const Duration(milliseconds: 500));
    
    // For demo, start as unauthenticated
    _updateState(AuthState.unauthenticated);
  }
}
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class NetworkStatusWidget extends StatefulWidget {
  const NetworkStatusWidget({Key? key}) : super(key: key);

  @override
  State<NetworkStatusWidget> createState() => _NetworkStatusWidgetState();
}

class _NetworkStatusWidgetState extends State<NetworkStatusWidget> {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      print('Could not check connectivity status: $e');
      return;
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  String _getConnectionText() {
    if (_connectionStatus.isEmpty || _connectionStatus.contains(ConnectivityResult.none)) {
      return 'No Connection';
    }
    
    if (_connectionStatus.contains(ConnectivityResult.wifi)) {
      return 'WiFi Connected';
    } else if (_connectionStatus.contains(ConnectivityResult.mobile)) {
      return 'Mobile Data';
    } else if (_connectionStatus.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet Connected';
    }
    
    return 'Connected';
  }

  IconData _getConnectionIcon() {
    if (_connectionStatus.isEmpty || _connectionStatus.contains(ConnectivityResult.none)) {
      return Icons.signal_wifi_off;
    }
    
    if (_connectionStatus.contains(ConnectivityResult.wifi)) {
      return Icons.wifi;
    } else if (_connectionStatus.contains(ConnectivityResult.mobile)) {
      return Icons.signal_cellular_4_bar;
    } else if (_connectionStatus.contains(ConnectivityResult.ethernet)) {
      return Icons.lan;
    }
    
    return Icons.network_check;
  }

  Color _getConnectionColor() {
    if (_connectionStatus.isEmpty || _connectionStatus.contains(ConnectivityResult.none)) {
      return Colors.red;
    }
    
    if (_connectionStatus.contains(ConnectivityResult.wifi)) {
      return Colors.green;
    } else if (_connectionStatus.contains(ConnectivityResult.mobile)) {
      return Colors.blue;
    } else if (_connectionStatus.contains(ConnectivityResult.ethernet)) {
      return Colors.green;
    }
    
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getConnectionColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getConnectionIcon(),
            color: _getConnectionColor(),
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            _getConnectionText(),
            style: TextStyle(
              color: _getConnectionColor(),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
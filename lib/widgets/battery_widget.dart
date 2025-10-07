import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';
import 'dart:async';

class BatteryWidget extends StatefulWidget {
  const BatteryWidget({super.key});

  @override
  State<BatteryWidget> createState() => _BatteryWidgetState();
}

class _BatteryWidgetState extends State<BatteryWidget> {
  final Battery _battery = Battery();
  int _batteryLevel = 0;
  BatteryState _batteryState = BatteryState.unknown;
  StreamSubscription<BatteryState>? _batteryStateSubscription;
  Timer? _batteryLevelTimer;

  @override
  void initState() {
    super.initState();
    _initBattery();
  }

  Future<void> _initBattery() async {
    try {
      // Get initial battery level
      final batteryLevel = await _battery.batteryLevel;
      final batteryState = await _battery.batteryState;
      
      if (mounted) {
        setState(() {
          _batteryLevel = batteryLevel;
          _batteryState = batteryState;
        });
      }

      // Listen to battery state changes
      _batteryStateSubscription = _battery.onBatteryStateChanged.listen((BatteryState state) {
        if (mounted) {
          setState(() {
            _batteryState = state;
          });
        }
      });

      // Update battery level periodically (every 30 seconds)
      _batteryLevelTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
        if (mounted) {
          try {
            final level = await _battery.batteryLevel;
            setState(() {
              _batteryLevel = level;
            });
          } catch (e) {
            print('Error getting battery level: $e');
          }
        }
      });

    } catch (e) {
      print('Error initializing battery: $e');
    }
  }

  @override
  void dispose() {
    _batteryStateSubscription?.cancel();
    _batteryLevelTimer?.cancel();
    super.dispose();
  }

  Color _getBatteryColor() {
    if (_batteryLevel > 50) {
      return Colors.green;
    } else if (_batteryLevel > 20) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  IconData _getBatteryIcon() {
    if (_batteryState == BatteryState.charging) {
      return Icons.battery_charging_full;
    }
    
    if (_batteryLevel > 90) {
      return Icons.battery_full;
    } else if (_batteryLevel > 60) {
      return Icons.battery_5_bar;
    } else if (_batteryLevel > 40) {
      return Icons.battery_4_bar;
    } else if (_batteryLevel > 20) {
      return Icons.battery_3_bar;
    } else if (_batteryLevel > 10) {
      return Icons.battery_2_bar;
    } else {
      return Icons.battery_1_bar;
    }
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
          color: _getBatteryColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getBatteryIcon(),
            color: _getBatteryColor(),
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            '${_batteryLevel}%',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _getBatteryColor(),
            ),
          ),
          if (_batteryState == BatteryState.charging) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.flash_on,
              color: Colors.yellow.shade700,
              size: 14,
            ),
          ],
        ],
      ),
    );
  }
}
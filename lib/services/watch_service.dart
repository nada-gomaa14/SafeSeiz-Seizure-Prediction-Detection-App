import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class WatchService {
  static const _eventChannel = EventChannel('com.example.safeseiz/watch_events');

  StreamSubscription? _subscription;
  final _sensorDataController = StreamController<Map<String, dynamic>>.broadcast();
  final _sosController = StreamController<void>.broadcast();

  // Streams Flutter UI can listen to
  Stream<Map<String, dynamic>> get sensorDataStream => _sensorDataController.stream;
  Stream<void> get sosStream => _sosController.stream;

  void startListening() {
    debugPrint('👂 WatchService: startListening called');
    try {
      _subscription = _eventChannel.receiveBroadcastStream().listen(
            (event) {
          debugPrint('📡 Watch event received: $event');
          final data = Map<String, dynamic>.from(event);
          final type = data['type'];
          if (type == 'sensor_data') {
            _sensorDataController.add(data);
            _saveSensorData(data);
          } else if (type == 'sos') {
            _sosController.add(null);
          }
        },
        onError: (error) {
          debugPrint('Watch event error: $error');
        },
        onDone: () {
          debugPrint('Watch event stream closed');
        },
      );
      debugPrint('WatchService: stream subscription created');
    } catch (e) {
      debugPrint('WatchService startListening error: $e');
    }
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  // Save sensor data locally using SharedPreferences
  Future<void> _saveSensorData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    // Keep last 100 readings
    final existing = prefs.getStringList('watch_sensor_data') ?? [];
    existing.add(jsonEncode(data));
    if (existing.length > 100) existing.removeAt(0);

    await prefs.setStringList('watch_sensor_data', existing);
    debugPrint('Sensor data saved locally: $data');
  }

  // Load all saved sensor readings
  Future<List<Map<String, dynamic>>> loadSensorData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('watch_sensor_data') ?? [];
    return raw.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();
  }

  // Clear saved data
  Future<void> clearSensorData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('watch_sensor_data');
  }

  void dispose() {
    stopListening();
    _sensorDataController.close();
    _sosController.close();
  }
}
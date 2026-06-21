import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:safeseiz/user/sensors/cubit/sensors_cubit.dart';
import 'package:safeseiz/user/sensors/models/sensors_model.dart';

class WatchService {
  static const _eventChannel = EventChannel('com.example.safeseiz/watch_events');

  StreamSubscription? _subscription;
  final _sensorDataController = StreamController<Map<String, dynamic>>.broadcast();
  final _sosController = StreamController<void>.broadcast();

  SensorsCubit? _sensorsCubit;

  Stream<Map<String, dynamic>> get sensorDataStream => _sensorDataController.stream;
  Stream<void> get sosStream => _sosController.stream;

  // Called from main.dart after BLoC providers are ready
  void setSensorsCubit(SensorsCubit cubit) {
    _sensorsCubit = cubit;
  }

  void startListening() {
    debugPrint('WatchService: startListening called');
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
        onError: (error) => debugPrint('Watch event error: $error'),
        onDone:  ()      => debugPrint('Watch event stream closed'),
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

  Future<void> _saveSensorData(Map<String, dynamic> data) async {
    if (_sensorsCubit == null) {
      debugPrint('SensorsCubit not set yet — skipping save');
      return;
    }

    try {
      final reading = SensorReadingModel(
        timestamp: data['timestamp']?.toString() ?? '',
        hr:        double.tryParse(data['hr']      ?? '0') ?? 0.0,
        spo2:      double.tryParse(data['spo2']    ?? '0') ?? 0.0,
        rri:       double.tryParse(data['rri']     ?? '0') ?? 0.0,
        accelX:    double.tryParse(data['accel_x'] ?? '0') ?? 0.0,
        accelY:    double.tryParse(data['accel_y'] ?? '0') ?? 0.0,
        accelZ:    double.tryParse(data['accel_z'] ?? '0') ?? 0.0,
        gyroX:     double.tryParse(data['gyro_x']  ?? '0') ?? 0.0,
        gyroY:     double.tryParse(data['gyro_y']  ?? '0') ?? 0.0,
        gyroZ:     double.tryParse(data['gyro_z']  ?? '0') ?? 0.0,
        label:     'normal',
      );

      await _sensorsCubit!.saveReading(reading);
      debugPrint('Sensor reading saved: ${reading.timestamp} HR:${reading.hr}');
    } catch (e) {
      debugPrint('Error saving sensor reading: $e');
    }
  }

  void dispose() {
    stopListening();
    _sensorDataController.close();
    _sosController.close();
  }
}
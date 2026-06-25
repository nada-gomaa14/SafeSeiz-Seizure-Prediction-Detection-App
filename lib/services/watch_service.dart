import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:safeseiz/user/seizure/cubit/seizure_cubit.dart';
import 'package:safeseiz/services/seizure_detector.dart';
import 'package:safeseiz/user/sensors/cubit/sensors_cubit.dart';
import 'package:safeseiz/user/sensors/models/sensors_model.dart';

class WatchService {
  static const _eventChannel = EventChannel('com.example.safeseiz/watch_events');

  StreamSubscription? _subscription;
  final _sensorDataController = StreamController<Map<String, dynamic>>.broadcast();
  final _sosController = StreamController<void>.broadcast();
  final _seizureDetectedController = StreamController<void>.broadcast();

  SensorsCubit? _sensorsCubit;
  SeizureCubit? _seizureCubit;

  final SeizureDetector _seizureDetector = SeizureDetector();
  bool _detectorInitialized = false;

  DateTime? _lastSeizureTime;
  DateTime? get lastSeizureTime => _lastSeizureTime;

  Stream<Map<String, dynamic>> get sensorDataStream => _sensorDataController.stream;
  Stream<void> get sosStream => _sosController.stream;
  Stream<void> get seizureDetectedStream => _seizureDetectedController.stream;

  // Called from main.dart after BLoC providers are ready
  void setSensorsCubit(SensorsCubit cubit) {
    _sensorsCubit = cubit;
  }

  void setSeizureCubit(SeizureCubit cubit) {
    _seizureCubit = cubit;
  }

  Future<void> startListening() async {
    debugPrint('WatchService: startListening called');

    // Initialize SeizureDetector
    await _seizureDetector.initialize();
    _detectorInitialized = true;
    debugPrint('WatchService: SeizureDetector initialized');

    try {
      _subscription = _eventChannel.receiveBroadcastStream().listen((event) async {
          debugPrint('Watch event received: $event');
          final data = Map<String, dynamic>.from(event);
          final type = data['type'];

          if (type == 'sensor_data') {
            _sensorDataController.add(data);
            await _saveSensorData(data);
            await _runInference(data);
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
        timestamp: data['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
        ppg:    double.tryParse(data['ppg']     ?? '0') ?? 0.0,
        hr:        double.tryParse(data['hr']      ?? '0') ?? 0.0,
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
      debugPrint('Sensor reading saved: ${reading.timestamp}');
    } catch (e) {
      debugPrint('Error saving sensor reading: $e');
    }
  }

  Future<void> _runInference(Map<String, dynamic> data) async {
    if (!_detectorInitialized || _seizureCubit == null) return;

    try {
      final prediction = await _seizureDetector.addReading(
        ppg:    double.tryParse(data['ppg']     ?? '0') ?? 0.0,
        accelX: double.tryParse(data['accel_x'] ?? '0') ?? 0.0,
        accelY: double.tryParse(data['accel_y'] ?? '0') ?? 0.0,
        accelZ: double.tryParse(data['accel_z'] ?? '0') ?? 0.0,
        gyroX:  double.tryParse(data['gyro_x']  ?? '0') ?? 0.0,
        gyroY:  double.tryParse(data['gyro_y']  ?? '0') ?? 0.0,
        gyroZ:  double.tryParse(data['gyro_z']  ?? '0') ?? 0.0,
      );

      if (prediction == 1) {
        debugPrint('Seizure detected by AI');

        _lastSeizureTime = DateTime.now();

        // Notify listeners to trigger SOS
        _seizureDetectedController.add(null);
      }
    } catch (e) {
      debugPrint('Inference error: $e');
    }
  }

  void dispose() {
    stopListening();
    _sensorDataController.close();
    _sosController.close();
    _seizureDetectedController.close();
  }
}

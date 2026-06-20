import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../user/contacts/cubit/emergency_contacts_cubit.dart';
import '../user/contacts/models/emergency_contacts_model.dart';
import '../user/sos/cubit/sos_cubit.dart';
import '../user/seizure/seizure_detector.dart';
import '../screens/SOSPage.dart';

class WatchPage extends StatefulWidget {
  final String patientName;

  const WatchPage({
    super.key,
    required this.patientName,
  });

  @override
  State<WatchPage> createState() => _WatchPageState();
}

class _WatchPageState extends State<WatchPage> {
  static const _watchChannel =
  EventChannel('com.example.safeseiz/watch_events');

  String hr        = '--';
  String spo2      = '--';
  String accelX    = '--', accelY = '--', accelZ = '--';
  String gyroX     = '--', gyroY  = '--', gyroZ  = '--';
  String timestamp = '--';
  String status    = 'Waiting for watch...';
  String seizureStatus = 'Monitoring...';
  bool _isTesting = false;
  int _currentEventType = 0; // 0=normal, 1=pre-seizure, 2=seizure

  final SeizureDetector _detector = SeizureDetector();
  bool _detectorInitialized = false;

  @override
  void initState() {
    super.initState();
    _initDetector();
    _listenToWatch();
  }

  Future<void> _initDetector() async {
    await _detector.initialize();
    setState(() => _detectorInitialized = true);
  }

  List<EmergencyContactsModel> _getContacts() {
    return context.read<EmergencyContactsCubit>().contacts;
  }

  void _triggerAlert({bool isSeizure = true}) {
    context.read<SOSCubit>().sendAlert(
      contacts: _getContacts(),
      patientName: widget.patientName,
      isSeizure: isSeizure,
    );
  }

  void _navigateToSOSScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          lazy: false,
          create: (_) => SOSCubit()..fetchLocation(),
          child: const SOSPage(),
        ),
      ),
    );
  }

  Future<void> _runSyntheticTest() async {
    if (_isTesting) return;
    setState(() {
      _isTesting = true;
      seizureStatus = '⏳ Running test...';
      _currentEventType = 0;
    });

    _detector.reset();

    try {
      // Load real seizure data from assets
      final String jsonStr =
      await rootBundle.loadString('assets/seizure_test_data.json');
      final Map<String, dynamic> data = json.decode(jsonStr);

      final List<double> ecg  = List<double>.from(data['ecg']);
      final List<double> accX = List<double>.from(data['acc_x']);
      final List<double> accY = List<double>.from(data['acc_y']);
      final List<double> accZ = List<double>.from(data['acc_z']);

      debugPrint('Loaded seizure test data: ${ecg.length} samples');

      for (int i = 0; i < ecg.length; i++) {
        final int prediction = await _detector.addReading(
          ppg:    ecg[i],
          accelX: accX[i],
          accelY: accY[i],
          accelZ: accZ[i],
          gyroX:  0.0,
          gyroY:  0.0,
          gyroZ:  0.0,
        );

        if (prediction == 2) {
          setState(() => seizureStatus = '🚨 Seizure Detected!');
          if (_currentEventType != 2) {
            _navigateToSOSScreen();
            _currentEventType = 2;
          }
          break;
        } else if (prediction == 1) {
          setState(() => seizureStatus = '⚠️ Pre-seizure Warning');
          if (_currentEventType == 0) {
            _triggerAlert(isSeizure: false);
            _currentEventType = 1;
          }
        } else if (prediction == 0) {
          if (_currentEventType == 0) {
            setState(() => seizureStatus = '✓ Normal');
          }
        }

        if (i % 100 == 0) {
          await Future.delayed(const Duration(milliseconds: 1));
        }
      }
    } catch (e) {
      debugPrint('Test error: $e');
      setState(() => seizureStatus = 'Test error: $e');
    }

    setState(() {
      _isTesting = false;
      if (seizureStatus == '⏳ Running test...') {
        seizureStatus = '✓ Normal (test complete)';
      }
    });
  }

  void _listenToWatch() {
    _watchChannel.receiveBroadcastStream().listen(
          (event) async {
        final data = Map<String, dynamic>.from(event);

        if (data['type'] == 'sos') {
          _triggerAlert();
          return;
        }

        // Parse PPG — use first value of comma-separated string
        final String ppgStr = data['ppg'] ?? '';
        double ppgValue = 0.0;
        if (ppgStr.isNotEmpty) {
          final parts = ppgStr.split(',');
          if (parts.isNotEmpty) {
            ppgValue = double.tryParse(parts[0].trim()) ?? 0.0;
          }
        }

        // Run inference
        if (_detectorInitialized && !_isTesting) {
          final int prediction = await _detector.addReading(
            ppg:    ppgValue,
            accelX: double.tryParse(data['accel_x'] ?? '0') ?? 0.0,
            accelY: double.tryParse(data['accel_y'] ?? '0') ?? 0.0,
            accelZ: double.tryParse(data['accel_z'] ?? '0') ?? 0.0,
            gyroX:  double.tryParse(data['gyro_x']  ?? '0') ?? 0.0,
            gyroY:  double.tryParse(data['gyro_y']  ?? '0') ?? 0.0,
            gyroZ:  double.tryParse(data['gyro_z']  ?? '0') ?? 0.0,
          );

          if (prediction == 2) {
            setState(() => seizureStatus = '🚨 Seizure Detected!');
            if (_currentEventType != 2) {
              _navigateToSOSScreen();
              _currentEventType = 2;
            }
          } else if (prediction == 1) {
            setState(() => seizureStatus = '⚠️ Pre-seizure Warning');
            if (_currentEventType == 0) {
              _triggerAlert(isSeizure: false);
              _currentEventType = 1;
            }
          } else if (prediction == 0) {
            setState(() => seizureStatus = '✓ Normal');
            _currentEventType = 0;
          }
        }

        setState(() {
          hr        = data['hr']        ?? '--';
          spo2      = data['spo2']      ?? '--';
          accelX    = data['accel_x']   ?? '--';
          accelY    = data['accel_y']   ?? '--';
          accelZ    = data['accel_z']   ?? '--';
          gyroX     = data['gyro_x']    ?? '--';
          gyroY     = data['gyro_y']    ?? '--';
          gyroZ     = data['gyro_z']    ?? '--';
          timestamp = data['timestamp'] ?? '--';
          status    = 'Receiving data ✓';
        });
      },
      onError: (error) {
        setState(() => status = 'Error: $error');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watch Data'),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Connection status bar
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: status.contains('✓')
                    ? Colors.green.shade50
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: status.contains('✓')
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: status.contains('✓')
                      ? Colors.green.shade800
                      : Colors.orange.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Seizure status bar
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: seizureStatus.contains('🚨')
                    ? Colors.red.shade50
                    : seizureStatus.contains('⚠️')
                    ? Colors.orange.shade50
                    : seizureStatus.contains('✓')
                    ? Colors.green.shade50
                    : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: seizureStatus.contains('🚨')
                      ? Colors.red
                      : seizureStatus.contains('⚠️')
                      ? Colors.orange
                      : seizureStatus.contains('✓')
                      ? Colors.green
                      : Colors.blue,
                ),
              ),
              child: Text(
                seizureStatus,
                style: TextStyle(
                  color: seizureStatus.contains('🚨')
                      ? Colors.red.shade800
                      : seizureStatus.contains('⚠️')
                      ? Colors.orange.shade800
                      : seizureStatus.contains('✓')
                      ? Colors.green.shade800
                      : Colors.blue.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Vitals card
            _buildCard(
              title: 'Vitals',
              icon: Icons.favorite,
              color: Colors.red,
              children: [
                _buildRow('Heart Rate', '$hr bpm'),
                _buildRow('SpO2', '$spo2 %'),
              ],
            ),

            const SizedBox(height: 12),

            // Accelerometer card
            _buildCard(
              title: 'Accelerometer',
              icon: Icons.speed,
              color: Colors.blue,
              children: [
                _buildRow('X', accelX),
                _buildRow('Y', accelY),
                _buildRow('Z', accelZ),
              ],
            ),

            const SizedBox(height: 12),

            // Gyroscope card
            _buildCard(
              title: 'Gyroscope',
              icon: Icons.rotate_right,
              color: Colors.purple,
              children: [
                _buildRow('X', gyroX),
                _buildRow('Y', gyroY),
                _buildRow('Z', gyroZ),
              ],
            ),

            const SizedBox(height: 12),

            // Test button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isTesting ? null : _runSyntheticTest,
                icon: _isTesting
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.science),
                label: Text(_isTesting ? 'Testing...' : 'Test Seizure Detection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Last update: $timestamp',
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: color)),
            ]),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 15)),
        ],
      ),
    );
  }
}
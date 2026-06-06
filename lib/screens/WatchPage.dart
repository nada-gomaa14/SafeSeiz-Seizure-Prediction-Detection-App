import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../user/contacts/cubit/emergency_contacts_cubit.dart';
import '../user/contacts/models/emergency_contacts_model.dart';
import '../user/sos/cubit/sos_cubit.dart';

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
  static const _watchChannel = EventChannel('com.example.safeseiz/watch_events');

  String hr = '--';
  String spo2 = '--';
  String accelX = '--', accelY = '--', accelZ = '--';
  String gyroX = '--', gyroY = '--', gyroZ = '--';
  String timestamp = '--';
  String status = 'Waiting for watch...';

  @override
  void initState() {
    super.initState();
    _listenToWatch();
  }

  List<EmergencyContactsModel> _getContacts() {
    return context.read<EmergencyContactsCubit>().contacts;
  }

  void _listenToWatch() {
    _watchChannel.receiveBroadcastStream().listen(
          (event) {
        final data = Map<String, dynamic>.from(event);

        if (data['type'] == 'sos') {
          context.read<SOSCubit>().sendAlert(
            contacts: _getContacts(),
            patientName: widget.patientName,
          );
          return;
        }

        setState(() {
          hr        = data['hr']      ?? '--';
          spo2      = data['spo2']    ?? '--';
          accelX    = data['accel_x'] ?? '--';
          accelY    = data['accel_y'] ?? '--';
          accelZ    = data['accel_z'] ?? '--';
          gyroX     = data['gyro_x']  ?? '--';
          gyroY     = data['gyro_y']  ?? '--';
          gyroZ     = data['gyro_z']  ?? '--';
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
            // Status bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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

            // Timestamp
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
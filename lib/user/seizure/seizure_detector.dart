import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class SeizureDetector {
  static const int seqLen             = 30;
  static const int totalChannels      = 13;
  static const int windowSamples      = 128;
  static const int windowStepSamples  = 64;
  static const int postProcessN       = 2;

  static const MethodChannel _channel =
  MethodChannel('com.example.safeseiz/inference');

  List<double> _means = [];
  List<double> _stds  = [];

  final List<List<double>> _buffer =
  List.generate(totalChannels, (_) => []);

  final List<int> _predictionBuffer = [];

  bool _isInitialized = false;

  Future<void> initialize() async {
    final String jsonStr =
    await rootBundle.loadString('assets/norm_stats.json');
    final Map<String, dynamic> stats = json.decode(jsonStr);
    _means = List<double>.from(stats['means']);
    _stds  = List<double>.from(stats['stds']);
    _isInitialized = true;
  }

  double _lastPpg = 0.0;
  double _lastAccelX = 0.0, _lastAccelY = 0.0, _lastAccelZ = 0.0;
  double _lastGyroX = 0.0, _lastGyroY = 0.0, _lastGyroZ = 0.0;
  bool _hasLastReading = false;

// Number of interpolated samples between watch readings
// Watch sends at 5 Hz, model expects 64 Hz → 64/5 ≈ 13 samples per reading
  static const int samplesPerReading = 13;

  Future<int> addReading({
    required double ppg,
    required double accelX,
    required double accelY,
    required double accelZ,
    required double gyroX,
    required double gyroY,
    required double gyroZ,
  }) async {
    if (!_isInitialized) return -1;

    if (!_hasLastReading) {
      // First reading — just store it
      _lastPpg    = ppg;
      _lastAccelX = accelX;
      _lastAccelY = accelY;
      _lastAccelZ = accelZ;
      _lastGyroX  = gyroX;
      _lastGyroY  = gyroY;
      _lastGyroZ  = gyroZ;
      _hasLastReading = true;
      return -1;
    }

    // Generate interpolated samples between last and current reading
    for (int i = 1; i <= samplesPerReading; i++) {
      final double t = i / samplesPerReading;

      final List<double> sample = [
        _lerp(_lastPpg,    ppg,    t), // ch 0 — PPG
        _lerp(_lastAccelX, accelX, t), // ch 1
        _lerp(_lastAccelY, accelY, t), // ch 2
        _lerp(_lastAccelZ, accelZ, t), // ch 3
        _lerp(_lastGyroX,  gyroX,  t), // ch 4
        _lerp(_lastGyroY,  gyroY,  t), // ch 5
        _lerp(_lastGyroZ,  gyroZ,  t), // ch 6
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0, // ch 7-12 missing
      ];

      // Add to buffer
      for (int c = 0; c < totalChannels; c++) {
        _buffer[c].add(sample[c]);
      }
    }

    // Update last reading
    _lastPpg    = ppg;
    _lastAccelX = accelX;
    _lastAccelY = accelY;
    _lastAccelZ = accelZ;
    _lastGyroX  = gyroX;
    _lastGyroY  = gyroY;
    _lastGyroZ  = gyroZ;

    // Keep buffer size manageable
    final int maxBufferSize =
        seqLen * windowStepSamples + windowSamples + 100;
    for (int c = 0; c < totalChannels; c++) {
      if (_buffer[c].length > maxBufferSize) {
        _buffer[c].removeRange(0, _buffer[c].length - maxBufferSize);
      }
    }

    // Check if we have enough samples
    final int requiredSamples =
        (seqLen - 1) * windowStepSamples + windowSamples;

    debugPrint('Buffer size: ${_buffer[0].length} / $requiredSamples required');


    if (_buffer[0].length < requiredSamples) return -1;
    // After adding samples to buffer, before checking requiredSamples

    // Build sequence
    final int bufLen   = _buffer[0].length;
    final int seqStart = bufLen - requiredSamples;

    final List<List<List<double>>> sequence = List.generate(
      seqLen,
          (i) {
        final int windowStart = seqStart + i * windowStepSamples;
        return List.generate(
          totalChannels,
              (c) => List.generate(
            windowSamples,
                (s) => _normalise(_buffer[c][windowStart + s], c),
          ),
        );
      },
    );

    final int rawPrediction = await _runInference(sequence);
    return _applyPostProcessing(rawPrediction);
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  double _normalise(double value, int channel) {
    if (_means.isEmpty || _stds.isEmpty) return value;
    final double std = _stds[channel] < 1e-8 ? 1.0 : _stds[channel];
    return (value - _means[channel]) / std;
  }

  int _applyPostProcessing(int prediction) {
    _predictionBuffer.add(prediction);
    if (_predictionBuffer.length > postProcessN) {
      _predictionBuffer.removeAt(0);
    }
    if (_predictionBuffer.length < postProcessN) return 0;
    final bool allNonNormal = _predictionBuffer.every((p) => p > 0);
    return allNonNormal ? _predictionBuffer.last : 0;
  }

  Future<int> _runInference(List<List<List<double>>> sequence) async {
    try {
      debugPrint('Running inference...');
      final result = await _channel.invokeMethod('runInference', {
        'sequence': sequence
            .map((window) => window.map((ch) => ch).toList())
            .toList(),
      });
      debugPrint('Inference result: $result');
      return result as int;
    } catch (e) {
      debugPrint('Inference error: $e');
      return 0;
    }
  }

  void reset() {
    for (int c = 0; c < totalChannels; c++) {
      _buffer[c].clear();
    }
    _predictionBuffer.clear();
  }
}
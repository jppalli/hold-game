import 'dart:ui';
import 'dart:math';

class TensionDetector {
  final List<Offset> _recentPositions = [];
  final List<double> _recentVelocities = [];
  final int _historySize = 10;
  
  DateTime _lastUpdate = DateTime.now();

  void reset() {
    _recentPositions.clear();
    _recentVelocities.clear();
    _lastUpdate = DateTime.now();
  }

  double update(Offset position, Offset delta) {
    final now = DateTime.now();
    final dt = now.difference(_lastUpdate).inMilliseconds / 1000.0;
    _lastUpdate = now;

    _recentPositions.add(position);
    if (_recentPositions.length > _historySize) {
      _recentPositions.removeAt(0);
    }

    final velocity = delta.distance / max(dt, 0.001);
    _recentVelocities.add(velocity);
    if (_recentVelocities.length > _historySize) {
      _recentVelocities.removeAt(0);
    }

    return _calculateTension();
  }

  double _calculateTension() {
    if (_recentPositions.length < 3) return 0.0;

    final jitter = _calculateJitter();
    final velocitySpike = _calculateVelocitySpike();

    return min(1.0, (jitter * 0.7) + (velocitySpike * 0.3));
  }

  double _calculateJitter() {
    if (_recentPositions.length < 3) return 0.0;

    double totalDeviation = 0.0;
    for (int i = 1; i < _recentPositions.length - 1; i++) {
      final prev = _recentPositions[i - 1];
      final curr = _recentPositions[i];
      final next = _recentPositions[i + 1];

      final expectedNext = Offset(
        curr.dx + (curr.dx - prev.dx),
        curr.dy + (curr.dy - prev.dy),
      );

      final deviation = (next - expectedNext).distance;
      totalDeviation += deviation;
    }

    final avgDeviation = totalDeviation / (_recentPositions.length - 2);
    return min(1.0, avgDeviation / 20.0);
  }

  double _calculateVelocitySpike() {
    if (_recentVelocities.length < 3) return 0.0;

    final avgVelocity = _recentVelocities.reduce((a, b) => a + b) / 
                        _recentVelocities.length;
    
    final maxVelocity = _recentVelocities.reduce(max);
    
    if (avgVelocity < 1.0) return 0.0;
    
    final spike = (maxVelocity - avgVelocity) / avgVelocity;
    return min(1.0, spike / 2.0);
  }
}

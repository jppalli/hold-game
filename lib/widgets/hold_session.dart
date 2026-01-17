import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../core/tension_detector.dart';

class HoldSession extends StatefulWidget {
  final VoidCallback onComplete;

  const HoldSession({super.key, required this.onComplete});

  @override
  State<HoldSession> createState() => _HoldSessionState();
}

class _HoldSessionState extends State<HoldSession>
    with SingleTickerProviderStateMixin {
  final TensionDetector _tensionDetector = TensionDetector();
  Timer? _sessionTimer;
  late AnimationController _breathController;
  
  double _tensionLevel = 0.0;
  int _remainingSeconds = 60;
  bool _touching = false;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    
    _startSession();
  }

  void _startSession() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _endSession();
        }
      });
    });
  }

  void _endSession() {
    _sessionTimer?.cancel();
    if (!kIsWeb) HapticFeedback.mediumImpact();
    widget.onComplete();
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() => _touching = true);
    _tensionDetector.reset();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final tension = _tensionDetector.update(
      details.localPosition,
      details.delta,
    );
    
    setState(() => _tensionLevel = tension);
    
    if (!kIsWeb && tension > 0.5) {
      HapticFeedback.selectionClick();
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      _touching = false;
      _tensionLevel = 0.0;
    });
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: Container(
        width: size.width,
        height: size.height,
        color: Colors.black,
        child: Stack(
          children: [
            Center(
              child: AnimatedBuilder(
                animation: _breathController,
                builder: (context, child) {
                  final breathScale = _touching
                      ? 1.0
                      : 1.0 + (_breathController.value * 0.1);
                  
                  final wobbleOffset = _tensionLevel > 0.3
                      ? Offset(
                          (DateTime.now().millisecond % 10 - 5) * _tensionLevel,
                          (DateTime.now().millisecond % 8 - 4) * _tensionLevel,
                        )
                      : Offset.zero;
                  
                  return Transform.translate(
                    offset: wobbleOffset,
                    child: Transform.scale(
                      scale: breathScale,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Color.lerp(
                                const Color(0xFF6B8CFF),
                                const Color(0xFFFF6B8C),
                                _tensionLevel,
                              )!.withOpacity(0.9),
                              Color.lerp(
                                const Color(0xFF6B8CFF),
                                const Color(0xFFFF6B8C),
                                _tensionLevel,
                              )!.withOpacity(0.1),
                            ],
                            stops: [
                              0.3 - (_tensionLevel * 0.2),
                              1.0,
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '$_remainingSeconds',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white.withOpacity(0.3),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

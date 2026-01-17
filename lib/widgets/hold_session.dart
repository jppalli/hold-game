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
    with TickerProviderStateMixin {
  final TensionDetector _tensionDetector = TensionDetector();
  Timer? _sessionTimer;
  late AnimationController _breathController;
  late AnimationController _fadeController;
  late AnimationController _counterFlipController;
  
  double _tensionLevel = 0.0;
  int _remainingSeconds = 60;
  int _previousSeconds = 60;
  bool _touching = false;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    
    _counterFlipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _startSession();
  }

  void _startSession() {
    // Start countdown immediately, then every second
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _previousSeconds = _remainingSeconds;
          _remainingSeconds--;
        });
        _counterFlipController.forward(from: 0.0);
      }
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _endSession();
      }
    });
  }

  void _endSession() {
    _sessionTimer?.cancel();
    if (!kIsWeb) HapticFeedback.mediumImpact();
    
    // Fade out before completing
    _fadeController.reverse().then((_) {
      widget.onComplete();
    });
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
    _fadeController.dispose();
    _counterFlipController.dispose();
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
        child: FadeTransition(
          opacity: _fadeController,
          child: Stack(
            children: [
              Center(
                child: AnimatedBuilder(
                  animation: Listenable.merge([_breathController, _fadeController]),
                  builder: (context, child) {
                    final breathScale = _touching
                        ? 1.0
                        : 1.0 + (_breathController.value * 0.08);
                    
                    final wobbleOffset = _tensionLevel > 0.3
                        ? Offset(
                            (DateTime.now().millisecond % 10 - 5) * _tensionLevel * 0.5,
                            (DateTime.now().millisecond % 8 - 4) * _tensionLevel * 0.5,
                          )
                        : Offset.zero;
                    
                    final baseColor = Color.lerp(
                      const Color(0xFF6B8CFF),
                      const Color(0xFFFF6B8C),
                      _tensionLevel,
                    )!;
                    
                    return Transform.translate(
                      offset: wobbleOffset,
                      child: Transform.scale(
                        scale: breathScale,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: baseColor.withOpacity(0.4),
                                blurRadius: 60 - (_tensionLevel * 20),
                                spreadRadius: 10 - (_tensionLevel * 5),
                              ),
                              BoxShadow(
                                color: baseColor.withOpacity(0.2),
                                blurRadius: 100,
                                spreadRadius: 20,
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  baseColor.withOpacity(0.95),
                                  baseColor.withOpacity(0.6),
                                  baseColor.withOpacity(0.1),
                                  Colors.transparent,
                                ],
                                stops: [
                                  0.0,
                                  0.4 - (_tensionLevel * 0.15),
                                  0.7,
                                  1.0,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _counterFlipController,
                    builder: (context, child) {
                      final flipValue = _counterFlipController.value;
                      final isFirstHalf = flipValue < 0.5;
                      final displayNumber = isFirstHalf ? _previousSeconds : _remainingSeconds;
                      
                      // Page flip effect: rotate and fade
                      final rotation = flipValue * 3.14159; // 180 degrees in radians
                      final opacity = isFirstHalf 
                          ? (1.0 - (flipValue * 2)) * 0.25
                          : ((flipValue - 0.5) * 2) * 0.25;
                      
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // perspective
                          ..rotateX(rotation),
                        child: Opacity(
                          opacity: opacity.clamp(0.1, 0.25),
                          child: Text(
                            '$displayNumber',
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.w200,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../widgets/hold_session.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _sessionActive = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startSession() {
    if (!kIsWeb) HapticFeedback.lightImpact();
    setState(() => _sessionActive = true);
  }

  void _endSession() {
    if (!kIsWeb) HapticFeedback.mediumImpact();
    setState(() => _sessionActive = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _sessionActive
          ? HoldSession(onComplete: _endSession)
          : Center(
              child: GestureDetector(
                onTap: _startSession,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = 1.0 + (_pulseController.value * 0.15);
                    final opacity = 0.6 + (_pulseController.value * 0.4);
                    
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6B8CFF).withOpacity(opacity * 0.5),
                              blurRadius: 80,
                              spreadRadius: 20,
                            ),
                            BoxShadow(
                              color: const Color(0xFF6B8CFF).withOpacity(opacity * 0.3),
                              blurRadius: 120,
                              spreadRadius: 30,
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Color(0xFF6B8CFF).withOpacity(opacity),
                                Color(0xFF6B8CFF).withOpacity(opacity * 0.4),
                                Color(0xFF6B8CFF).withOpacity(0.0),
                              ],
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}

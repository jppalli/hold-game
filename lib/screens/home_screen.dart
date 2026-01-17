import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/hold_session.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _sessionActive = false;

  void _startSession() {
    HapticFeedback.lightImpact();
    setState(() => _sessionActive = true);
  }

  void _endSession() {
    HapticFeedback.mediumImpact();
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
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF6B8CFF).withOpacity(0.8),
                        const Color(0xFF6B8CFF).withOpacity(0.2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

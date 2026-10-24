import 'package:flutter/material.dart';

/// Original, non-animated FocusFlow companion. No network or external assets.
class FlowBuddy extends StatelessWidget {
  const FlowBuddy({super.key, this.size = 76, this.resting = false});

  final double size;
  final bool resting;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: size * 0.13,
              top: size * 0.26,
              child: Container(
                width: size * 0.74,
                height: size * 0.66,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7E3CC),
                  borderRadius: BorderRadius.circular(size * 0.35),
                  border: Border.all(
                    color: const Color(0xFF9A7861),
                    width: size * 0.018,
                  ),
                ),
                child: Center(
                  child: Text(
                    resting ? '– ᴗ –' : '• ᴗ •',
                    style: TextStyle(
                      fontSize: size * 0.18,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF493D34),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: size * 0.32,
              child: Transform.rotate(
                angle: -0.35,
                child: Icon(
                  Icons.eco_rounded,
                  color: const Color(0xFF547958),
                  size: size * 0.37,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

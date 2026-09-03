import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RevolLogo extends StatelessWidget {
  final double fontSize;
  final bool isDark;

  const RevolLogo({
    super.key,
    this.fontSize = 26,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDark ? Colors.white : const Color(0xFF173597);
    final accentColor = const Color(0xFF007AD5);
    final globeSize = fontSize * 0.72;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // "REVO"
            Text(
              'REVO',
              style: GoogleFonts.montserrat(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                color: primaryColor,
                letterSpacing: 1.0,
              ),
            ),

            // Globe icon inside blue circle
            Container(
              width: globeSize,
              height: globeSize,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.public,
                  color: Colors.white,
                  size: globeSize * 0.72,
                ),
              ),
            ),

            // "LIMS"
            Text(
              'LIMS ',
              style: GoogleFonts.montserrat(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                color: primaryColor,
                letterSpacing: 1.0,
              ),
            ),

            // "8.0"
            Text(
              '8.0',
              style: GoogleFonts.montserrat(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                color: accentColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),

        // "AI DRIVEN"
        Padding(
          padding: const EdgeInsets.only(top: 1.0),
          child: Text(
            'AI DRIVEN',
            style: GoogleFonts.montserrat(
              fontSize: fontSize * 0.38,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF173597),
              letterSpacing: 3.5,
            ),
          ),
        ),
      ],
    );
  }
}

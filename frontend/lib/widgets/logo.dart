/// Logo und Wortmarke des Thriftshops.
library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/design_tokens.dart';

class Logo extends StatelessWidget {
  const Logo({super.key, this.hoehe = 40, this.mitWortmarke = true, this.farbe});

  final double hoehe;
  final bool mitWortmarke;

  /// Farbe der Wortmarke (Standard: Textfarbe).
  final Color? farbe;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/bilder/logo.webp',
          height: hoehe,
          semanticLabel: 'Thriftshop Köln',
        ),
        if (mitWortmarke) ...[
          const SizedBox(width: Abstand.sm + 2),
          Text(
            'Thriftshop Köln',
            style: GoogleFonts.fraunces(
              fontSize: hoehe * 0.5,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: farbe ?? AppFarben.tinte,
            ),
          ),
        ],
      ],
    );
  }
}

/// Logo und Wortmarke des Thriftshops.
///
/// Die Bildmarke - ein schräg hängendes Preisschild mit den beiden Türmen des
/// Kölner Doms - wird als Vektor gezeichnet und bleibt so in jeder Größe scharf.
/// Dieselbe Form liegt als `web/favicon.svg` vor.
library;

import 'dart:math' as math;

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
    final marke = CustomPaint(size: Size.square(hoehe), painter: const _MarkePainter());

    if (!mitWortmarke) {
      return Semantics(label: 'Thriftshop Köln', image: true, child: marke);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(child: marke),
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
    );
  }
}

/// Zeichnet die Bildmarke in ein Quadrat; alle Koordinaten beziehen sich auf ein 64er-Raster.
class _MarkePainter extends CustomPainter {
  const _MarkePainter();

  static const double _raster = 64;
  static const double _neigung = -14 * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.shortestSide / _raster);

    // Schild um die Mitte neigen und so verkleinern, dass es samt Kordel ins Quadrat passt
    canvas.translate(_raster / 2, _raster / 2);
    canvas.rotate(_neigung);
    canvas.translate(-_raster / 2, -_raster / 2);
    canvas.translate(3.5, 5);
    canvas.scale(0.88);

    const ecke = Radius.circular(6);

    // Schild mit abgeschrägten oberen Ecken; das Loch bleibt durchsichtig
    final schild = Path()
      ..fillType = PathFillType.evenOdd
      ..moveTo(22, 4)
      ..lineTo(42, 4)
      ..lineTo(54, 17)
      ..lineTo(54, 54)
      ..arcToPoint(const Offset(48, 60), radius: ecke)
      ..lineTo(16, 60)
      ..arcToPoint(const Offset(10, 54), radius: ecke)
      ..lineTo(10, 17)
      ..close()
      ..addOval(Rect.fromCircle(center: const Offset(32, 14), radius: 3.6));
    canvas.drawPath(schild, Paint()..color = AppFarben.terrakotta);

    // Die beiden Domtürme mit Mittelschiff; das Portal ist ausgespart
    final dom = Path()
      ..fillType = PathFillType.evenOdd
      ..moveTo(17, 52)
      ..lineTo(17, 37)
      ..lineTo(22.5, 22)
      ..lineTo(28, 37)
      ..lineTo(28, 43)
      ..lineTo(36, 43)
      ..lineTo(36, 37)
      ..lineTo(41.5, 22)
      ..lineTo(47, 37)
      ..lineTo(47, 52)
      ..close()
      ..moveTo(29.8, 52)
      ..lineTo(29.8, 48.6)
      ..arcToPoint(const Offset(34.2, 48.6), radius: const Radius.circular(2.2))
      ..lineTo(34.2, 52)
      ..close();
    canvas.drawPath(dom, Paint()..color = AppFarben.papier);

    // Kordel durch das Loch
    final kordel = Path()
      ..moveTo(32, 14)
      ..cubicTo(30, 6, 36, 1, 44, 3);
    canvas.drawPath(
      kordel,
      Paint()
        ..color = AppFarben.tinte
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_MarkePainter oldDelegate) => false;
}

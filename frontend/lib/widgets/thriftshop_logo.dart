/// Hilfs-Widget für das Thriftshop-Logo in AppBars
library;

import 'package:flutter/material.dart';

/// Kleines Logo für AppBars (Leading)
Widget thriftshopLogo({double height = 32}) {
  return Image.asset(
    'assets/koeln_thriftshop_logo.png',
    height: height,
    fit: BoxFit.contain,
  );
}

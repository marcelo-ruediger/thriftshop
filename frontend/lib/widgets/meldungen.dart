/// Kurze Rückmeldungen (SnackBar) und Bestätigungsdialoge.
library;

import 'package:flutter/material.dart';

import '../core/constants/design_tokens.dart';

/// Zeigt eine kurze Meldung am unteren Bildschirmrand.
void meldung(BuildContext context, String text, {bool fehler = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              fehler ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: Abstand.sm + 4),
            Expanded(child: Text(text)),
          ],
        ),
        backgroundColor: fehler ? AppFarben.fehler : AppFarben.tinte,
        width: MediaQuery.sizeOf(context).width >= 600 ? 480 : null,
        duration: Duration(seconds: fehler ? 6 : 3),
      ),
    );
}

/// Fragt vor einer folgenreichen Aktion nach. Gibt `true` zurück, wenn bestätigt wurde.
Future<bool> bestaetigen(
  BuildContext context, {
  required String titel,
  required String text,
  required String aktion,
  bool gefaehrlich = false,
}) async {
  final ergebnis = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(titel),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Text(text),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          style: gefaehrlich
              ? FilledButton.styleFrom(backgroundColor: AppFarben.fehler)
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(aktion),
        ),
      ],
    ),
  );
  return ergebnis ?? false;
}

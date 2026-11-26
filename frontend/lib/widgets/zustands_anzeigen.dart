/// Anzeigen für die drei Zustände jeder Datenansicht: lädt, Fehler, leer.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../core/constants/design_tokens.dart';

/// Ladeanzeige. Dauert es länger, erscheint ein Hinweis auf den startenden Demo-Server.
class Ladeanzeige extends StatefulWidget {
  const Ladeanzeige({super.key});

  @override
  State<Ladeanzeige> createState() => _LadeanzeigeState();
}

class _LadeanzeigeState extends State<Ladeanzeige> {
  Timer? _timer;
  bool _dauertLange = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _dauertLange = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Abstand.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (_dauertLange) ...[
              const SizedBox(height: Abstand.lg),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Text(
                  'Der Demo-Server wacht gerade auf. Das kann bis zu einer Minute dauern.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Hinweis mit Symbol, Überschrift, Text und optionaler Aktion -
/// für leere Listen und für Fehler.
class Hinweisflaeche extends StatelessWidget {
  const Hinweisflaeche({
    super.key,
    required this.icon,
    required this.titel,
    this.text,
    this.aktion,
    this.aktionText,
  });

  /// Fehleranzeige mit „Erneut versuchen“.
  const Hinweisflaeche.fehler({
    super.key,
    required String nachricht,
    VoidCallback? erneutVersuchen,
  }) : icon = Icons.cloud_off_outlined,
       titel = 'Das hat nicht geklappt',
       text = nachricht,
       aktion = erneutVersuchen,
       aktionText = 'Erneut versuchen';

  final IconData icon;
  final String titel;
  final String? text;
  final VoidCallback? aktion;
  final String? aktionText;

  @override
  Widget build(BuildContext context) {
    final schrift = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Abstand.lg,
          vertical: Abstand.xxl,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppFarben.flaecheGetoent,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: AppFarben.tinteGedaempft),
              ),
              const SizedBox(height: Abstand.lg),
              Text(titel, style: schrift.headlineSmall, textAlign: TextAlign.center),
              if (text != null) ...[
                const SizedBox(height: Abstand.sm),
                Text(
                  text!,
                  textAlign: TextAlign.center,
                  style: schrift.bodyMedium?.copyWith(color: AppFarben.tinteGedaempft),
                ),
              ],
              if (aktion != null && aktionText != null) ...[
                const SizedBox(height: Abstand.lg),
                FilledButton(onPressed: aktion, child: Text(aktionText!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

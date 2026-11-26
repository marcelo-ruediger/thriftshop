/// Mein Konto: Stammdaten, Passwort, Abmelden und Konto löschen.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/design_tokens.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/format.dart';
import '../../core/utils/validierung.dart';
import '../../models/benutzer.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/abzeichen.dart';
import '../../widgets/meldungen.dart';
import '../../widgets/seiten_inhalt.dart';
import '../auth/auth_rahmen.dart';

class KontoScreen extends StatelessWidget {
  const KontoScreen({super.key});

  Future<void> _abmelden(BuildContext context) async {
    final router = GoRouter.of(context);
    await context.read<AuthProvider>().abmelden();
    router.go('/');
  }

  Future<void> _loeschen(BuildContext context) async {
    final ja = await bestaetigen(
      context,
      titel: 'Konto endgültig löschen?',
      text: 'Deine persönlichen Daten werden entfernt und noch laufende Bestellungen storniert. '
          'Das lässt sich nicht rückgängig machen. Abgeschlossene Bestellungen bleiben aus '
          'buchhalterischen Gründen anonymisiert erhalten.',
      aktion: 'Konto löschen',
      gefaehrlich: true,
    );
    if (!ja || !context.mounted) return;
    final router = GoRouter.of(context);
    try {
      await context.read<AuthProvider>().kontoLoeschen();
      router.go('/');
    } on ApiFehler catch (fehler) {
      if (context.mounted) meldung(context, fehler.nachricht, fehler: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final benutzer = context.watch<AuthProvider>().benutzer;
    // Direkt nach dem Abmelden wird die Seite noch einmal gebaut, bevor der Router umleitet
    if (benutzer == null) return const SizedBox.shrink();
    final schrift = Theme.of(context).textTheme;

    return SeitenInhalt.einfach(
      maxBreite: Breakpoints.schmalMax,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppFarben.gruen,
              child: Text(
                benutzer.initialen,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: Abstand.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(benutzer.name, style: schrift.headlineMedium),
                  const SizedBox(height: Abstand.xs),
                  Wrap(
                    spacing: Abstand.sm,
                    runSpacing: Abstand.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Abzeichen(
                        benutzer.rolle,
                        farbe: AppFarben.gruenDunkel,
                        hintergrund: AppFarben.gruenHell,
                      ),
                      if (benutzer.erstelltAm != null)
                        Text(
                          'Dabei seit ${datum(benutzer.erstelltAm!)}',
                          style: schrift.bodySmall,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: Abstand.lg),
        // Der Schlüssel füllt das Formular neu, wenn ein anderer Benutzer angemeldet ist
        _Stammdaten(benutzer, key: ValueKey(benutzer.benutzerId)),
        const SizedBox(height: Abstand.md),
        const _PasswortAendern(),
        const SizedBox(height: Abstand.md),
        Abschnitt(
          titel: 'Sitzung',
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: Abstand.md,
            runSpacing: Abstand.sm,
            children: [
              Text('Angemeldet als ${benutzer.email}', style: schrift.bodyMedium),
              OutlinedButton.icon(
                onPressed: () => _abmelden(context),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Abmelden'),
              ),
            ],
          ),
        ),
        const SizedBox(height: Abstand.md),
        Abschnitt(
          titel: 'Konto löschen',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Du kannst dein Konto jederzeit löschen. Deine persönlichen Daten werden dabei entfernt.',
                style: schrift.bodyMedium,
              ),
              const SizedBox(height: Abstand.md),
              OutlinedButton(
                onPressed: () => _loeschen(context),
                style: OutlinedButton.styleFrom(foregroundColor: AppFarben.fehler),
                child: const Text('Konto löschen'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stammdaten extends StatefulWidget {
  const _Stammdaten(this.benutzer, {super.key});

  final Benutzer benutzer;

  @override
  State<_Stammdaten> createState() => _StammdatenState();
}

class _StammdatenState extends State<_Stammdaten> {
  final _formular = GlobalKey<FormState>();
  late final _vorname = TextEditingController(text: widget.benutzer.vorname);
  late final _nachname = TextEditingController(text: widget.benutzer.nachname);
  late final _email = TextEditingController(text: widget.benutzer.email);
  late final _telefon = TextEditingController(text: widget.benutzer.telefon ?? '');
  bool _sendet = false;
  String? _fehler;

  @override
  void dispose() {
    for (final feld in [_vorname, _nachname, _email, _telefon]) {
      feld.dispose();
    }
    super.dispose();
  }

  Future<void> _speichern() async {
    if (!_formular.currentState!.validate()) return;
    setState(() {
      _sendet = true;
      _fehler = null;
    });
    try {
      await context.read<AuthProvider>().profilSpeichern(
        vorname: _vorname.text.trim(),
        nachname: _nachname.text.trim(),
        email: _email.text.trim(),
        telefon: _telefon.text.trim().isEmpty ? null : _telefon.text.trim(),
      );
      if (mounted) meldung(context, 'Deine Daten sind gespeichert.');
    } on ApiFehler catch (fehler) {
      if (mounted) setState(() => _fehler = fehler.nachricht);
    } finally {
      if (mounted) setState(() => _sendet = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Abschnitt(
      titel: 'Persönliche Daten',
      child: Form(
        key: _formular,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_fehler != null) Formularfehler(_fehler!),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _vorname,
                    decoration: const InputDecoration(labelText: 'Vorname'),
                    validator: pflichtfeld,
                  ),
                ),
                const SizedBox(width: Abstand.md),
                Expanded(
                  child: TextFormField(
                    controller: _nachname,
                    decoration: const InputDecoration(labelText: 'Nachname'),
                    validator: pflichtfeld,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Abstand.md),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'E-Mail-Adresse'),
              keyboardType: TextInputType.emailAddress,
              validator: emailPruefen,
            ),
            const SizedBox(height: Abstand.md),
            TextFormField(
              controller: _telefon,
              decoration: const InputDecoration(labelText: 'Telefon (optional)'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: Abstand.lg),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _sendet ? null : _speichern,
                child: SendeText('Speichern', sendet: _sendet),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswortAendern extends StatefulWidget {
  const _PasswortAendern();

  @override
  State<_PasswortAendern> createState() => _PasswortAendernState();
}

class _PasswortAendernState extends State<_PasswortAendern> {
  final _formular = GlobalKey<FormState>();
  final _aktuell = TextEditingController();
  final _neu = TextEditingController();
  bool _sendet = false;
  String? _fehler;

  @override
  void dispose() {
    _aktuell.dispose();
    _neu.dispose();
    super.dispose();
  }

  Future<void> _aendern() async {
    if (!_formular.currentState!.validate()) return;
    setState(() {
      _sendet = true;
      _fehler = null;
    });
    try {
      await context.read<AuthProvider>().passwortAendern(_aktuell.text, _neu.text);
      if (!mounted) return;
      _aktuell.clear();
      _neu.clear();
      meldung(context, 'Dein Passwort wurde geändert.');
    } on ApiFehler catch (fehler) {
      if (mounted) setState(() => _fehler = fehler.nachricht);
    } finally {
      if (mounted) setState(() => _sendet = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Abschnitt(
      titel: 'Passwort ändern',
      child: Form(
        key: _formular,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_fehler != null) Formularfehler(_fehler!),
            TextFormField(
              controller: _aktuell,
              decoration: const InputDecoration(labelText: 'Aktuelles Passwort'),
              obscureText: true,
              validator: (wert) => pflichtfeld(wert, 'Bitte gib dein aktuelles Passwort ein'),
            ),
            const SizedBox(height: Abstand.md),
            TextFormField(
              controller: _neu,
              decoration: const InputDecoration(
                labelText: 'Neues Passwort',
                helperText: 'Mindestens 8 Zeichen.',
              ),
              obscureText: true,
              validator: neuesPasswortPruefen,
            ),
            const SizedBox(height: Abstand.lg),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonal(
                onPressed: _sendet ? null : _aendern,
                child: SendeText('Passwort ändern', sendet: _sendet),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

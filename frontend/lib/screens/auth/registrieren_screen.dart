/// Registrierung eines neuen Kundenkontos.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/design_tokens.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/validierung.dart';
import '../../providers/auth_provider.dart';
import 'auth_rahmen.dart';

class RegistrierenScreen extends StatefulWidget {
  const RegistrierenScreen({super.key, this.weiter});

  /// Seite, zu der nach der Registrierung weitergeleitet wird.
  final String? weiter;

  @override
  State<RegistrierenScreen> createState() => _RegistrierenScreenState();
}

class _RegistrierenScreenState extends State<RegistrierenScreen> {
  final _formular = GlobalKey<FormState>();
  final _vorname = TextEditingController();
  final _nachname = TextEditingController();
  final _email = TextEditingController();
  final _telefon = TextEditingController();
  final _passwort = TextEditingController();
  bool _passwortSichtbar = false;
  bool _sendet = false;
  String? _fehler;

  @override
  void dispose() {
    for (final feld in [_vorname, _nachname, _email, _telefon, _passwort]) {
      feld.dispose();
    }
    super.dispose();
  }

  /// Nach erfolgreicher Registrierung leitet der Router automatisch weiter.
  Future<void> _absenden() async {
    if (!_formular.currentState!.validate()) return;
    setState(() {
      _sendet = true;
      _fehler = null;
    });
    try {
      await context.read<AuthProvider>().registrieren(
        vorname: _vorname.text.trim(),
        nachname: _nachname.text.trim(),
        email: _email.text.trim(),
        telefon: _telefon.text.trim().isEmpty ? null : _telefon.text.trim(),
        passwort: _passwort.text,
      );
    } on ApiFehler catch (fehler) {
      if (!mounted) return;
      setState(() {
        _sendet = false;
        _fehler = fehler.nachricht;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final anmelden = Uri(
      path: '/login',
      queryParameters: widget.weiter == null ? null : {'weiter': widget.weiter},
    ).toString();

    return AuthRahmen(
      titel: 'Konto erstellen',
      untertitel: 'In einer Minute erledigt – danach kannst du direkt bestellen.',
      children: [
        if (_fehler != null) Formularfehler(_fehler!),
        Form(
          key: _formular,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _vorname,
                        decoration: const InputDecoration(labelText: 'Vorname'),
                        autofillHints: const [AutofillHints.givenName],
                        textInputAction: TextInputAction.next,
                        validator: pflichtfeld,
                      ),
                    ),
                    const SizedBox(width: Abstand.md),
                    Expanded(
                      child: TextFormField(
                        controller: _nachname,
                        decoration: const InputDecoration(labelText: 'Nachname'),
                        autofillHints: const [AutofillHints.familyName],
                        textInputAction: TextInputAction.next,
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
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  validator: emailPruefen,
                ),
                const SizedBox(height: Abstand.md),
                TextFormField(
                  controller: _telefon,
                  decoration: const InputDecoration(
                    labelText: 'Telefon (optional)',
                    helperText: 'Nur für Rückfragen zu deiner Abholung.',
                  ),
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: Abstand.md),
                TextFormField(
                  controller: _passwort,
                  decoration: InputDecoration(
                    labelText: 'Passwort',
                    helperText: 'Mindestens 8 Zeichen.',
                    suffixIcon: IconButton(
                      tooltip: _passwortSichtbar ? 'Passwort verbergen' : 'Passwort anzeigen',
                      icon: Icon(
                        _passwortSichtbar
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _passwortSichtbar = !_passwortSichtbar),
                    ),
                  ),
                  obscureText: !_passwortSichtbar,
                  autofillHints: const [AutofillHints.newPassword],
                  onFieldSubmitted: (_) => _absenden(),
                  validator: neuesPasswortPruefen,
                ),
                const SizedBox(height: Abstand.lg),
                FilledButton(
                  onPressed: _sendet ? null : _absenden,
                  child: SendeText('Konto erstellen', sendet: _sendet),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Abstand.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Schon registriert?', style: Theme.of(context).textTheme.bodyMedium),
            TextButton(
              onPressed: () => context.go(anmelden),
              child: const Text('Anmelden'),
            ),
          ],
        ),
      ],
    );
  }
}

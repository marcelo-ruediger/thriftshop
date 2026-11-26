/// Anmeldung - mit Schnellzugang zu den Demo-Konten.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/design_tokens.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/validierung.dart';
import '../../providers/auth_provider.dart';
import 'auth_rahmen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.weiter});

  /// Seite, zu der nach der Anmeldung weitergeleitet wird.
  final String? weiter;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formular = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _passwort = TextEditingController();
  bool _passwortSichtbar = false;
  bool _sendet = false;
  String? _fehler;

  @override
  void dispose() {
    _email.dispose();
    _passwort.dispose();
    super.dispose();
  }

  /// Nach erfolgreicher Anmeldung leitet der Router automatisch weiter.
  Future<void> _anmelden(String email, String passwort) async {
    setState(() {
      _sendet = true;
      _fehler = null;
    });
    try {
      await context.read<AuthProvider>().anmelden(email, passwort);
    } on ApiFehler catch (fehler) {
      if (!mounted) return;
      setState(() {
        _sendet = false;
        _fehler = fehler.nachricht;
      });
    }
  }

  void _absenden() {
    if (_formular.currentState!.validate()) {
      _anmelden(_email.text.trim(), _passwort.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final schrift = Theme.of(context).textTheme;
    final registrieren = Uri(
      path: '/registrieren',
      queryParameters: widget.weiter == null ? null : {'weiter': widget.weiter},
    ).toString();

    return AuthRahmen(
      titel: 'Willkommen zurück',
      untertitel: 'Melde dich an, um zu bestellen und deine Bestellungen zu sehen.',
      children: [
        if (_fehler != null) Formularfehler(_fehler!),
        Form(
          key: _formular,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                  controller: _passwort,
                  decoration: InputDecoration(
                    labelText: 'Passwort',
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
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => _absenden(),
                  validator: (wert) => pflichtfeld(wert, 'Bitte gib dein Passwort ein'),
                ),
                const SizedBox(height: Abstand.lg),
                FilledButton(
                  onPressed: _sendet ? null : _absenden,
                  child: SendeText('Anmelden', sendet: _sendet),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: Abstand.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Noch kein Konto?', style: schrift.bodyMedium),
            TextButton(
              onPressed: () => context.go(registrieren),
              child: const Text('Jetzt registrieren'),
            ),
          ],
        ),
        const SizedBox(height: Abstand.md),
        // Schnellzugang für alle, die das Projekt nur ansehen möchten
        Container(
          padding: const EdgeInsets.all(Abstand.md),
          decoration: BoxDecoration(
            color: AppFarben.flaecheGetoent,
            borderRadius: BorderRadius.circular(Rundung.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Nur zum Ausprobieren hier?', style: schrift.titleSmall),
              const SizedBox(height: 2),
              Text(
                'Mit einem Demo-Konto bist du mit einem Klick drin.',
                style: schrift.bodySmall,
              ),
              const SizedBox(height: Abstand.sm + 4),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _sendet
                          ? null
                          : () => _anmelden('kunde@example.com', 'kunde1234'),
                      icon: const Icon(Icons.person_outline, size: 18),
                      label: const Text('Als Kundin'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppFarben.flaeche,
                        padding: const EdgeInsets.symmetric(horizontal: Abstand.sm),
                      ),
                    ),
                  ),
                  const SizedBox(width: Abstand.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _sendet
                          ? null
                          : () => _anmelden('admin@example.com', 'admin1234'),
                      icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
                      label: const Text('Als Admin'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppFarben.flaeche,
                        padding: const EdgeInsets.symmetric(horizontal: Abstand.sm),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Gemeinsames Layout für Anmeldung und Registrierung: Formular neben einem Stimmungsbild.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/design_tokens.dart';
import '../../widgets/logo.dart';

class AuthRahmen extends StatelessWidget {
  const AuthRahmen({
    super.key,
    required this.titel,
    required this.untertitel,
    required this.children,
  });

  final String titel;
  final String untertitel;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final schrift = Theme.of(context).textTheme;
    final breit = MediaQuery.sizeOf(context).width >= Breakpoints.desktop;

    final formular = Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Abstand.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () => context.go('/'),
                  borderRadius: BorderRadius.circular(Rundung.sm),
                  child: const Logo(hoehe: 44),
                ),
              ),
              const SizedBox(height: Abstand.xl),
              Text(titel, style: schrift.headlineLarge),
              const SizedBox(height: Abstand.sm),
              Text(
                untertitel,
                style: schrift.bodyLarge?.copyWith(color: AppFarben.tinteGedaempft),
              ),
              const SizedBox(height: Abstand.lg),
              ...children,
              const SizedBox(height: Abstand.lg),
              Center(
                child: TextButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Zurück zum Shop'),
                  style: TextButton.styleFrom(foregroundColor: AppFarben.tinteGedaempft),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: breit
            ? Row(
                children: [
                  const Expanded(child: _Bildseite()),
                  Expanded(child: formular),
                ],
              )
            : formular,
      ),
    );
  }
}

class _Bildseite extends StatelessWidget {
  const _Bildseite();

  @override
  Widget build(BuildContext context) {
    final schrift = Theme.of(context).textTheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/bilder/laden.webp', fit: BoxFit.cover, excludeFromSemantics: true),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppFarben.gruenDunkel.withValues(alpha: 0.35),
                AppFarben.gruenDunkel.withValues(alpha: 0.95),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(Abstand.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Text(
                  'Jedes Teil hat schon etwas erlebt. Bei dir geht die Geschichte weiter.',
                  style: schrift.headlineLarge?.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: Abstand.md),
              Text(
                'Thriftshop Köln – Second-Hand seit 2026',
                style: schrift.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Rote Fehlermeldung über einem Formular.
class Formularfehler extends StatelessWidget {
  const Formularfehler(this.nachricht, {super.key});

  final String nachricht;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Abstand.md),
      padding: const EdgeInsets.all(Abstand.sm + 4),
      decoration: BoxDecoration(
        color: AppFarben.fehlerHell,
        borderRadius: BorderRadius.circular(Rundung.md),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppFarben.fehler, size: 20),
          const SizedBox(width: Abstand.sm + 4),
          Expanded(
            child: Text(nachricht, style: const TextStyle(color: AppFarben.fehler)),
          ),
        ],
      ),
    );
  }
}

/// Inhalt einer Schaltfläche, die während des Sendens einen Ladekreis zeigt.
class SendeText extends StatelessWidget {
  const SendeText(this.text, {super.key, required this.sendet});

  final String text;
  final bool sendet;

  @override
  Widget build(BuildContext context) {
    return sendet
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          )
        : Text(text);
  }
}

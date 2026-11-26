/// Verwaltung - Benutzerkonten und Rollenvergabe (nur Administratoren).
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/design_tokens.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/format.dart';
import '../../models/benutzer.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/meldungen.dart';
import '../../widgets/zustands_anzeigen.dart';
import 'admin_rahmen.dart';

class AdminBenutzerScreen extends StatefulWidget {
  const AdminBenutzerScreen({super.key});

  @override
  State<AdminBenutzerScreen> createState() => _AdminBenutzerScreenState();
}

class _AdminBenutzerScreenState extends State<AdminBenutzerScreen> {
  /// Wird bei jeder abgelehnten Änderung erhöht, damit die Auswahlfelder neu
  /// aufgebaut werden und wieder die tatsächliche Rolle zeigen.
  int _abgelehnt = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AdminProvider>().benutzerLaden();
    });
  }

  Future<void> _rolleAendern(Benutzer benutzer, String rolle) async {
    try {
      await context.read<AdminProvider>().rolleAendern(benutzer.benutzerId, rolle);
      if (mounted) meldung(context, '${benutzer.name} hat jetzt die Rolle „$rolle“.');
    } on ApiFehler catch (fehler) {
      if (!mounted) return;
      setState(() => _abgelehnt++);
      meldung(context, fehler.nachricht, fehler: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final ich = context.watch<AuthProvider>().benutzer;
    final benutzer = admin.benutzer;
    final schrift = Theme.of(context).textTheme;

    return AdminRahmen(
      pfad: '/admin/benutzer',
      titel: 'Benutzer',
      untertitel: 'Mitarbeiter verwalten Produkte und Bestellungen, Administratoren zusätzlich die Rollen.',
      children: [
        if (benutzer == null)
          admin.fehler != null
              ? Hinweisflaeche.fehler(
                  nachricht: admin.fehler!,
                  erneutVersuchen: admin.benutzerLaden,
                )
              : const SizedBox(height: 320, child: Ladeanzeige())
        else
          Card(
            child: Column(
              children: [
                for (final (index, b) in benutzer.indexed) ...[
                  if (index > 0) const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Abstand.md,
                      vertical: Abstand.sm + 4,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppFarben.flaecheGetoent,
                          child: Text(
                            b.initialen,
                            style: schrift.labelLarge?.copyWith(color: AppFarben.tinte),
                          ),
                        ),
                        const SizedBox(width: Abstand.sm + 4),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b.benutzerId == ich?.benutzerId ? '${b.name} (du)' : b.name,
                                style: schrift.titleSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                b.erstelltAm == null
                                    ? b.email
                                    : '${b.email} · seit ${datum(b.erstelltAm!)}',
                                style: schrift.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: Abstand.sm),
                        SizedBox(
                          width: 170,
                          child: DropdownButtonFormField<String>(
                            // Neuer Schlüssel = neues Feld mit dem Wert vom Server: nach einer
                            // gespeicherten und auch nach einer abgelehnten Änderung
                            key: ValueKey('${b.benutzerId}-${b.rolle}-$_abgelehnt'),
                            initialValue: b.rolle,
                            isDense: true,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: Abstand.sm + 4,
                                vertical: Abstand.sm,
                              ),
                            ),
                            items: [
                              for (final rolle in Rollen.alle)
                                DropdownMenuItem(value: rolle, child: Text(rolle)),
                            ],
                            // Die eigene Rolle lässt sich nicht ändern (sonst sperrt man sich aus)
                            onChanged: b.benutzerId == ich?.benutzerId
                                ? null
                                : (rolle) {
                                    if (rolle != null && rolle != b.rolle) {
                                      _rolleAendern(b, rolle);
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// Dialog zum Anlegen und Bearbeiten eines Produkts - inklusive Bild-Upload.
library;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/config.dart';
import '../../core/constants/design_tokens.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/validierung.dart';
import '../../models/produkt.dart';
import '../../providers/admin_provider.dart';
import '../../providers/katalog_provider.dart';
import '../../widgets/produkt_bild.dart';
import '../auth/auth_rahmen.dart';

const _bildtypen = {
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'webp': 'image/webp',
};

/// Liest eine Zahl mit Komma oder Punkt als Dezimaltrennzeichen.
double? _zahl(String text) => double.tryParse(text.trim().replaceAll(',', '.'));

class ProduktDialog extends StatefulWidget {
  const ProduktDialog({super.key, this.produkt});

  /// `null` legt ein neues Produkt an.
  final Produkt? produkt;

  @override
  State<ProduktDialog> createState() => _ProduktDialogState();
}

class _ProduktDialogState extends State<ProduktDialog> {
  final _formular = GlobalKey<FormState>();
  late final Produkt? _p = widget.produkt;
  late final _bezeichnung = TextEditingController(text: _p?.bezeichnung);
  late final _info = TextEditingController(text: _p?.produktInfo);
  late final _preis = TextEditingController(
    text: _p?.preis.toStringAsFixed(2).replaceAll('.', ','),
  );
  late final _rabatt = TextEditingController(
    text: _p == null || _p.produktRabatt == 0
        ? ''
        : _p.produktRabatt.toStringAsFixed(0),
  );
  late final _bestand = TextEditingController(text: '${_p?.lagerbestand ?? 1}');
  late String? _kategorieId = _p?.kategorieId;
  late String? _zustandId = _p?.zustandId;
  late String? _bildpfad = _p?.bildpfad;
  late bool _aktiv = _p?.produktAktiv ?? true;

  bool _sendet = false;
  bool _laedtBild = false;
  String? _fehler;

  @override
  void dispose() {
    for (final feld in [_bezeichnung, _info, _preis, _rabatt, _bestand]) {
      feld.dispose();
    }
    super.dispose();
  }

  Future<void> _bildWaehlen() async {
    final auswahl = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _bildtypen.keys.toList(),
      withData: true,
    );
    final datei = auswahl?.files.firstOrNull;
    final bytes = datei?.bytes;
    if (datei == null || bytes == null || !mounted) return;

    final mimeTyp = _bildtypen[datei.extension?.toLowerCase()];
    if (mimeTyp == null) {
      setState(() => _fehler = 'Bitte wähle ein Bild im Format JPEG, PNG oder WebP.');
      return;
    }
    setState(() {
      _laedtBild = true;
      _fehler = null;
    });
    try {
      final bildpfad = await context.read<AdminProvider>().bildHochladen(
        bytes,
        datei.name,
        mimeTyp,
      );
      if (mounted) setState(() => _bildpfad = bildpfad);
    } on ApiFehler catch (fehler) {
      if (mounted) setState(() => _fehler = fehler.nachricht);
    } finally {
      if (mounted) setState(() => _laedtBild = false);
    }
  }

  Future<void> _speichern() async {
    if (!_formular.currentState!.validate()) return;
    final eingabe = ProduktEingabe(
      bezeichnung: _bezeichnung.text.trim(),
      produktInfo: _info.text.trim(),
      preis: _zahl(_preis.text)!,
      produktRabatt: _rabatt.text.trim().isEmpty ? 0 : _zahl(_rabatt.text)!,
      lagerbestand: int.parse(_bestand.text.trim()),
      zustandId: _zustandId!,
      kategorieId: _kategorieId!,
      bildpfad: _bildpfad,
      produktAktiv: _aktiv,
    );
    setState(() {
      _sendet = true;
      _fehler = null;
    });
    final admin = context.read<AdminProvider>();
    final navigator = Navigator.of(context);
    try {
      if (_p == null) {
        await admin.produktAnlegen(eingabe);
      } else {
        await admin.produktSpeichern(_p.produktId, eingabe);
      }
      navigator.pop(true);
    } on ApiFehler catch (fehler) {
      if (mounted) {
        setState(() {
          _sendet = false;
          _fehler = fehler.nachricht;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final katalog = context.watch<KatalogProvider>();
    final schrift = Theme.of(context).textTheme;

    return Dialog(
      insetPadding: const EdgeInsets.all(Abstand.md),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(Abstand.lg, Abstand.lg, Abstand.sm, Abstand.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _p == null ? 'Neues Produkt' : 'Produkt bearbeiten',
                      style: schrift.headlineSmall,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Schließen',
                    icon: const Icon(Icons.close),
                    onPressed: _sendet ? null : () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(Abstand.lg, Abstand.sm, Abstand.lg, Abstand.lg),
                child: Form(
                  key: _formular,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_fehler != null) Formularfehler(_fehler!),
                      Row(
                        children: [
                          SizedBox.square(
                            dimension: 96,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                border: Border.all(color: AppFarben.linie),
                                borderRadius: BorderRadius.circular(Rundung.md),
                              ),
                              child: ProduktBild(
                                _bildpfad == null ? null : AppConfig.bildUrl(_bildpfad!),
                                rundung: Rundung.md - 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: Abstand.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: _laedtBild ? null : _bildWaehlen,
                                  icon: _laedtBild
                                      ? const SizedBox.square(
                                          dimension: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(Icons.upload_outlined, size: 18),
                                  label: Text(
                                    _bildpfad == null ? 'Bild hochladen' : 'Bild ersetzen',
                                  ),
                                ),
                                const SizedBox(height: Abstand.sm),
                                Text(
                                  'JPEG, PNG oder WebP, höchstens 5 MB. Quadratisch wirkt am besten.',
                                  style: schrift.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Abstand.lg),
                      TextFormField(
                        controller: _bezeichnung,
                        decoration: const InputDecoration(labelText: 'Bezeichnung'),
                        maxLength: 120,
                        validator: (wert) => (wert ?? '').trim().length < 2
                            ? 'Mindestens 2 Zeichen'
                            : null,
                      ),
                      const SizedBox(height: Abstand.sm),
                      TextFormField(
                        controller: _info,
                        decoration: const InputDecoration(
                          labelText: 'Beschreibung',
                          hintText: 'Größe, Material, Besonderheiten, kleine Mängel …',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 4,
                        validator: pflichtfeld,
                      ),
                      const SizedBox(height: Abstand.md),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _preis,
                              decoration: const InputDecoration(
                                labelText: 'Preis',
                                suffixText: '€',
                                helperText: 'inkl. MwSt.',
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                              ],
                              validator: (wert) {
                                final preis = _zahl(wert ?? '');
                                if (preis == null) return 'Bitte einen Preis eingeben';
                                if (preis <= 0) return 'Muss größer als 0 sein';
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: Abstand.md),
                          Expanded(
                            child: TextFormField(
                              controller: _rabatt,
                              decoration: const InputDecoration(
                                labelText: 'Rabatt',
                                suffixText: '%',
                                helperText: 'leer = kein Rabatt',
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                              ],
                              validator: (wert) {
                                if ((wert ?? '').trim().isEmpty) return null;
                                final rabatt = _zahl(wert!);
                                if (rabatt == null || rabatt < 0 || rabatt >= 100) {
                                  return 'Zwischen 0 und 99';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: Abstand.md),
                          Expanded(
                            child: TextFormField(
                              controller: _bestand,
                              decoration: const InputDecoration(labelText: 'Lagerbestand'),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (wert) => int.tryParse((wert ?? '').trim()) == null
                                  ? 'Bitte eine Zahl'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Abstand.md),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _kategorieId,
                              isExpanded: true,
                              decoration: const InputDecoration(labelText: 'Kategorie'),
                              items: [
                                for (final k in katalog.kategorien)
                                  DropdownMenuItem(
                                    value: k.kategorieId,
                                    child: Text(k.bezeichnung, overflow: TextOverflow.ellipsis),
                                  ),
                              ],
                              onChanged: (wert) => _kategorieId = wert,
                              validator: (wert) => wert == null ? 'Bitte wählen' : null,
                            ),
                          ),
                          const SizedBox(width: Abstand.md),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _zustandId,
                              isExpanded: true,
                              decoration: const InputDecoration(labelText: 'Zustand'),
                              items: [
                                for (final z in katalog.zustaende)
                                  DropdownMenuItem(
                                    value: z.zustandId,
                                    child: Text(z.bezeichnung, overflow: TextOverflow.ellipsis),
                                  ),
                              ],
                              onChanged: (wert) => _zustandId = wert,
                              validator: (wert) => wert == null ? 'Bitte wählen' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Abstand.sm),
                      SwitchListTile(
                        value: _aktiv,
                        onChanged: (wert) => setState(() => _aktiv = wert),
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Im Shop sichtbar'),
                        subtitle: const Text('Ausgeschaltet bleibt das Produkt nur in der Verwaltung.'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(Abstand.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _sendet ? null : () => Navigator.of(context).pop(false),
                    child: const Text('Abbrechen'),
                  ),
                  const SizedBox(width: Abstand.sm),
                  FilledButton(
                    onPressed: _sendet || _laedtBild ? null : _speichern,
                    child: SendeText(
                      _p == null ? 'Produkt anlegen' : 'Speichern',
                      sendet: _sendet,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

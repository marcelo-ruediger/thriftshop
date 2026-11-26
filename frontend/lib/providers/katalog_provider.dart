/// Hält den Katalog (Produkte, Kategorien, Zustände) und den aktiven Filter.
library;

import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../models/produkt.dart';
import '../models/stammdaten.dart';
import '../services/shop_api.dart';

enum Sortierung {
  neueste('Neueste zuerst'),
  preisAufsteigend('Preis aufsteigend'),
  preisAbsteigend('Preis absteigend'),
  name('Name A–Z');

  const Sortierung(this.titel);
  final String titel;
}

class KatalogProvider extends ChangeNotifier {
  KatalogProvider(this._api);

  final ShopApi _api;

  List<Produkt> _produkte = [];
  List<Kategorie> _kategorien = [];
  List<Zustand> _zustaende = [];
  bool _geladen = false;
  bool _laedt = false;
  String? _fehler;

  String? _kategorieId;
  String _suche = '';
  Sortierung _sortierung = Sortierung.neueste;
  bool _nurAngebote = false;
  List<Produkt>? _gefiltert;

  List<Produkt> get produkte => _produkte;
  List<Kategorie> get kategorien => _kategorien;
  List<Zustand> get zustaende => _zustaende;

  /// `true`, sobald der Katalog mindestens einmal erfolgreich geladen wurde.
  bool get geladen => _geladen;
  bool get laedt => _laedt;
  String? get fehler => _fehler;

  String? get kategorieId => _kategorieId;
  String get suche => _suche;
  Sortierung get sortierung => _sortierung;
  bool get nurAngebote => _nurAngebote;
  bool get filterAktiv => _kategorieId != null || _suche.isNotEmpty || _nurAngebote;

  /// Lädt Produkte und Stammdaten. Mit [still] ohne Ladeanzeige (Aktualisierung im Hintergrund).
  Future<void> laden({bool still = false}) async {
    if (_laedt) return;
    _laedt = true;
    if (!still) {
      _fehler = null;
      notifyListeners();
    }
    try {
      final ergebnisse = await Future.wait([
        _api.produkte(),
        _api.kategorien(),
        _api.zustaende(),
      ]);
      _produkte = ergebnisse[0] as List<Produkt>;
      _kategorien = ergebnisse[1] as List<Kategorie>;
      _zustaende = ergebnisse[2] as List<Zustand>;
      _geladen = true;
      _fehler = null;
      _gefiltert = null;
    } on ApiFehler catch (fehler) {
      if (!still) _fehler = fehler.nachricht;
    } finally {
      _laedt = false;
      notifyListeners();
    }
  }

  // --- Nachschlagen -------------------------------------------------------------

  Kategorie? kategorie(String id) {
    for (final k in _kategorien) {
      if (k.kategorieId == id) return k;
    }
    return null;
  }

  Zustand? zustand(String id) {
    for (final z in _zustaende) {
      if (z.zustandId == id) return z;
    }
    return null;
  }

  Produkt? produktNachSlug(String slug) {
    for (final p in _produkte) {
      if (p.slug == slug) return p;
    }
    return null;
  }

  int anzahlInKategorie(String kategorieId) =>
      _produkte.where((p) => p.kategorieId == kategorieId).length;

  /// Andere verfügbare Produkte derselben Kategorie.
  List<Produkt> aehnliche(Produkt produkt, {int anzahl = 4}) => _produkte
      .where(
        (p) =>
            p.kategorieId == produkt.kategorieId &&
            p.produktId != produkt.produktId &&
            !p.ausverkauft,
      )
      .take(anzahl)
      .toList();

  // --- Filter -------------------------------------------------------------------

  void kategorieWaehlen(String? kategorieId) {
    _kategorieId = kategorieId;
    _filterGeaendert();
  }

  void suchen(String begriff) {
    _suche = begriff.trim();
    _filterGeaendert();
  }

  void sortieren(Sortierung sortierung) {
    _sortierung = sortierung;
    _filterGeaendert();
  }

  void nurAngeboteZeigen(bool wert) {
    _nurAngebote = wert;
    _filterGeaendert();
  }

  void filterZuruecksetzen() {
    _kategorieId = null;
    _suche = '';
    _nurAngebote = false;
    _filterGeaendert();
  }

  void _filterGeaendert() {
    _gefiltert = null;
    notifyListeners();
  }

  /// Die Produkte nach aktivem Filter und Sortierung.
  List<Produkt> get gefiltert => _gefiltert ??= _filtern();

  List<Produkt> _filtern() {
    final begriff = _suche.toLowerCase();
    final treffer = _produkte.where((p) {
      if (_kategorieId != null && p.kategorieId != _kategorieId) return false;
      if (_nurAngebote && !p.reduziert) return false;
      if (begriff.isNotEmpty &&
          !p.bezeichnung.toLowerCase().contains(begriff) &&
          !p.produktInfo.toLowerCase().contains(begriff)) {
        return false;
      }
      return true;
    }).toList();

    switch (_sortierung) {
      case Sortierung.neueste:
        treffer.sort((a, b) => b.erstellungsdatum.compareTo(a.erstellungsdatum));
      case Sortierung.preisAufsteigend:
        treffer.sort((a, b) => a.endpreis.compareTo(b.endpreis));
      case Sortierung.preisAbsteigend:
        treffer.sort((a, b) => b.endpreis.compareTo(a.endpreis));
      case Sortierung.name:
        treffer.sort(
          (a, b) => a.bezeichnung.toLowerCase().compareTo(b.bezeichnung.toLowerCase()),
        );
    }
    return treffer;
  }
}

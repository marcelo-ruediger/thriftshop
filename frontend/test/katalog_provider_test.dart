import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thriftshop_koeln/core/network/api_client.dart';
import 'package:thriftshop_koeln/models/produkt.dart';
import 'package:thriftshop_koeln/models/stammdaten.dart';
import 'package:thriftshop_koeln/providers/katalog_provider.dart';
import 'package:thriftshop_koeln/services/shop_api.dart';

Produkt produkt(
  String name, {
  required String kategorie,
  required double preis,
  double rabatt = 0,
  int tag = 1,
}) => Produkt(
  produktId: name,
  produktnr: 'P00001',
  bezeichnung: name,
  slug: name.toLowerCase(),
  produktInfo: 'Beschreibung von $name',
  preis: preis,
  produktRabatt: rabatt,
  rabattProzent: rabatt,
  endpreis: preis * (100 - rabatt) / 100,
  steuersatz: 19,
  lagerbestand: 1,
  zustandId: 'gut',
  kategorieId: kategorie,
  produktAktiv: true,
  erstellungsdatum: DateTime.utc(2026, 1, tag),
);

/// Liefert feste Daten statt das Backend aufzurufen.
class FakeApi extends ShopApi {
  FakeApi(super.client);

  @override
  Future<List<Produkt>> produkte() async => [
    produkt('Lederjacke', kategorie: 'mode', preis: 80, tag: 1),
    produkt('Wollpullover', kategorie: 'mode', preis: 30, rabatt: 50, tag: 3),
    produkt('Kofferradio', kategorie: 'technik', preis: 60, tag: 2),
  ];

  @override
  Future<List<Kategorie>> kategorien() async => const [
    Kategorie(kategorieId: 'mode', bezeichnung: 'Mode', slug: 'mode', kategorieRabatt: 0, steuersatz: 19),
    Kategorie(kategorieId: 'technik', bezeichnung: 'Technik', slug: 'technik', kategorieRabatt: 0, steuersatz: 19),
  ];

  @override
  Future<List<Zustand>> zustaende() async => const [
    Zustand(zustandId: 'gut', bezeichnung: 'Gut', beschreibung: 'Leichte Gebrauchsspuren'),
  ];
}

void main() {
  late KatalogProvider katalog;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    katalog = KatalogProvider(FakeApi(ApiClient(TokenSpeicher(prefs))));
    await katalog.laden();
  });

  List<String> namen() => katalog.gefiltert.map((p) => p.bezeichnung).toList();

  test('zeigt ohne Filter alles, das Neueste zuerst', () {
    expect(katalog.geladen, isTrue);
    expect(namen(), ['Wollpullover', 'Kofferradio', 'Lederjacke']);
    expect(katalog.filterAktiv, isFalse);
  });

  test('filtert nach Kategorie', () {
    katalog.kategorieWaehlen('technik');
    expect(namen(), ['Kofferradio']);
    expect(katalog.anzahlInKategorie('mode'), 2);
  });

  test('sucht in Bezeichnung und Beschreibung, ohne auf Großschreibung zu achten', () {
    katalog.suchen('  LEDER ');
    expect(namen(), ['Lederjacke']);
    katalog.suchen('beschreibung von koffer');
    expect(namen(), ['Kofferradio']);
  });

  test('sortiert nach dem Preis nach Rabatt', () {
    katalog.sortieren(Sortierung.preisAufsteigend);
    expect(namen(), ['Wollpullover', 'Kofferradio', 'Lederjacke']); // 15, 60, 80
    katalog.sortieren(Sortierung.preisAbsteigend);
    expect(namen().first, 'Lederjacke');
  });

  test('zeigt auf Wunsch nur reduzierte Artikel', () {
    katalog.nurAngeboteZeigen(true);
    expect(namen(), ['Wollpullover']);
  });

  test('Filter lassen sich kombinieren und zurücksetzen', () {
    katalog.kategorieWaehlen('mode');
    katalog.suchen('jacke');
    expect(namen(), ['Lederjacke']);

    katalog.filterZuruecksetzen();
    expect(namen().length, 3);
  });

  test('schlägt ähnliche Produkte aus derselben Kategorie vor', () {
    final jacke = katalog.produktNachSlug('lederjacke')!;
    expect(katalog.aehnliche(jacke).map((p) => p.bezeichnung), ['Wollpullover']);
  });
}

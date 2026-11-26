import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thriftshop_koeln/core/network/api_client.dart';
import 'package:thriftshop_koeln/models/bestellung.dart';
import 'package:thriftshop_koeln/models/produkt.dart';
import 'package:thriftshop_koeln/providers/bestell_provider.dart';
import 'package:thriftshop_koeln/services/shop_api.dart';

Bestellung bestellung(String nr) => Bestellung(
  bestellungId: nr,
  bestellnr: nr,
  status: Bestellstatus.offen,
  bestelldatum: DateTime.utc(2026),
  zahlungsart: Zahlungsarten.abholung,
  benutzerId: 'u',
  artikelAnzahl: 1,
  gesamtpreis: 10,
  enthalteneMwst: 1.6,
  positionen: const [],
);

/// Liefert feste Daten statt das Backend aufzurufen und merkt sich die gesendete Summe.
class FakeApi extends ShopApi {
  FakeApi(super.client);

  double? gesendeteSumme;

  @override
  Future<Bestellung> bestellen({
    required Map<String, int> mengen,
    required String zahlungsart,
    required double erwarteteSumme,
    String? anmerkung,
  }) async {
    gesendeteSumme = erwarteteSumme;
    return bestellung('B00003');
  }

  @override
  Future<List<Bestellung>> meineBestellungen() async => [
    bestellung('B00002'),
    bestellung('B00001'),
  ];
}

void main() {
  late FakeApi api;
  late BestellProvider provider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    api = FakeApi(ApiClient(TokenSpeicher(await SharedPreferences.getInstance())));
    provider = BestellProvider(api);
  });

  test('eine nie geladene Historie bleibt nach dem Bestellen „nicht geladen“', () async {
    await provider.bestellen(const [], zahlungsart: Zahlungsarten.abholung, erwarteteSumme: 10);

    // null = die Bestellübersicht lädt beim Öffnen alles vom Server,
    // statt nur die eine neue Bestellung zu zeigen
    expect(provider.bestellungen, isNull);
  });

  test('eine geladene Historie wird um die neue Bestellung ergänzt', () async {
    await provider.laden();
    await provider.bestellen(const [], zahlungsart: Zahlungsarten.abholung, erwarteteSumme: 10);

    expect(provider.bestellungen!.map((b) => b.bestellnr), ['B00003', 'B00002', 'B00001']);
  });

  test('die angezeigte Summe wird an den Server gesendet', () async {
    await provider.bestellen(
      const [],
      zahlungsart: Zahlungsarten.rechnung,
      erwarteteSumme: 82.15,
    );
    expect(api.gesendeteSumme, 82.15);
  });

  test('Produkt bearbeiten: ein unveränderter Bestand wird nicht mitgesendet', () {
    ProduktEingabe eingabe({int? bestand}) => ProduktEingabe(
      bezeichnung: 'Jacke',
      produktInfo: 'Info',
      preis: 20,
      produktRabatt: 12.5,
      zustandId: 'z',
      kategorieId: 'k',
      produktAktiv: true,
      lagerbestand: bestand,
    );

    expect(eingabe().toJson().containsKey('lagerbestand'), isFalse);
    expect(eingabe(bestand: 3).toJson()['lagerbestand'], 3);
    expect(eingabe().toJson()['produkt_rabatt'], '12.50');
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thriftshop_koeln/models/produkt.dart';
import 'package:thriftshop_koeln/providers/warenkorb_provider.dart';

Produkt produkt(
  String id, {
  double preis = 20,
  double rabatt = 0,
  int bestand = 3,
}) => Produkt(
  produktId: id,
  produktnr: 'P00001',
  bezeichnung: 'Artikel $id',
  slug: 'artikel-$id',
  produktInfo: 'Testartikel',
  preis: preis,
  produktRabatt: rabatt,
  rabattProzent: rabatt,
  endpreis: preis * (100 - rabatt) / 100,
  steuersatz: 19,
  lagerbestand: bestand,
  zustandId: 'z',
  kategorieId: 'k',
  produktAktiv: true,
  erstellungsdatum: DateTime.utc(2026),
);

Future<WarenkorbProvider> warenkorb() async {
  final prefs = await SharedPreferences.getInstance();
  return WarenkorbProvider(prefs);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('rechnet Anzahl, Summe und enthaltene Mehrwertsteuer', () async {
    final korb = await warenkorb();
    korb.hinzufuegen(produkt('a', preis: 50, rabatt: 20), menge: 2);
    korb.hinzufuegen(produkt('b', preis: 39));

    expect(korb.anzahl, 3);
    expect(korb.summe, closeTo(119, 0.001)); // 2 × 40 + 39
    expect(korb.mwst, closeTo(19, 0.001));
  });

  test('legt nie mehr in den Warenkorb, als auf Lager ist', () async {
    final korb = await warenkorb();
    final jacke = produkt('a', bestand: 2);

    expect(korb.hinzufuegen(jacke, menge: 5), 2);
    expect(korb.hinzufuegen(jacke), 0);
    expect(korb.mengeVon('a'), 2);

    korb.mengeAendern('a', 9);
    expect(korb.mengeVon('a'), 2);
  });

  test('Menge 0 entfernt die Position', () async {
    final korb = await warenkorb();
    korb.hinzufuegen(produkt('a'));
    korb.mengeAendern('a', 0);
    expect(korb.istLeer, isTrue);
  });

  test('übersteht einen Neustart', () async {
    final korb = await warenkorb();
    korb.hinzufuegen(produkt('a'), menge: 2);

    final neuGestartet = await warenkorb();
    expect(neuGestartet.mengeVon('a'), 2);
    expect(neuGestartet.items.single.produkt.bezeichnung, 'Artikel a');
  });

  test('Abgleich übernimmt neue Preise und entfernt Vergriffenes', () async {
    final korb = await warenkorb();
    korb.hinzufuegen(produkt('a', preis: 20), menge: 3);
    korb.hinzufuegen(produkt('b'));
    korb.hinzufuegen(produkt('c'));

    korb.abgleichen([
      produkt('a', preis: 25, bestand: 1), // teurer und nur noch eins da
      produkt('b', bestand: 0), // inzwischen ausverkauft
      // 'c' wurde aus dem Shop genommen
    ]);

    expect(korb.items.map((i) => i.produkt.produktId), ['a']);
    expect(korb.mengeVon('a'), 1);
    expect(korb.summe, 25);
    expect(korb.hinweis, isNotNull);
  });
}

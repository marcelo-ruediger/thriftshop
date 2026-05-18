/// Detail-Screen für Produkte
/// Zeigt alle Produktdetails inklusive Bild, Preis, Beschreibung etc.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../models/produkt.dart';

class ProduktDetailScreen extends StatefulWidget {
  /// Das angezeigte Produkt
  final Produkt produkt;

  const ProduktDetailScreen({super.key, required this.produkt});

  @override
  State<ProduktDetailScreen> createState() => _ProduktDetailScreenState();
}

class _ProduktDetailScreenState extends State<ProduktDetailScreen> {
  /// Ausgewählte Menge
  int _menge = 1;

  /// Gibt an, ob das Produkt favorisiert ist
  bool _isFavorit = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aktuellerPreis = _getAktuellerPreis();
    final farbe = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar mit Bild-Hintergrund
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(background: _buildBildHeader()),
            actions: [
              // Favoriten-Button
              IconButton(
                icon: Icon(
                  _isFavorit ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorit ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isFavorit = !_isFavorit;
                  });
                  if (_isFavorit) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Zur Favoritenliste hinzugefügt'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
              ),
              // Teilen-Button
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Teilen-Funktion kommt bald!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
            backgroundColor: Colors.grey[200],
          ),

          // Produktdetails
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Produktname und ID
                    Text(
                      widget.produkt.bezeichnung,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Artikel-Nr: ${widget.produkt.produktnr}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Preisbereich
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: farbe.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.produkt.produktRabatt > 0)
                                Text(
                                  '${widget.produkt.preis.toStringAsFixed(2)} €',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                '${aktuellerPreis.toStringAsFixed(2)} €',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: farbe.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (widget.produkt.produktRabatt > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Chip(
                                    label: Text(
                                      '-${widget.produkt.produktRabatt.toInt()}%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    backgroundColor: Colors.red,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Chip(
                                label: Text(
                                  'Auf Lager',
                                  style: TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.green,
                                visualDensity: VisualDensity.compact,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Kategorie: ${widget.produkt.kategorieId.substring(0, 8)}...',
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                'Zustand: ${widget.produkt.zustandId.substring(0, 8)}...',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Beschreibung
                    if (widget.produkt.produktInfo.isNotEmpty) ...[
                      Text(
                        'Beschreibung',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.produkt.produktInfo,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Menge-Auswahl
                    Text(
                      'Menge',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // MINUS Button
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: OutlinedButton(
                            onPressed: _menge > 1
                                ? () {
                                    setState(() {
                                      _menge--;
                                    });
                                  }
                                : null,
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Icon(Icons.remove),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Mengenanzeige
                        Container(
                          width: 60,
                          height: 44,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '$_menge',
                              style: theme.textTheme.headlineSmall,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // PLUS Button
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: OutlinedButton(
                            onPressed: _menge < widget.produkt.lagerbestand
                                ? () {
                                    setState(() {
                                      _menge++;
                                    });
                                  }
                                : null,
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Icon(Icons.add),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${widget.produkt.lagerbestand} Stück verfügbar',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Bottom Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Gesamtpreis
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Gesamtpreis',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  '${(aktuellerPreis * _menge).toStringAsFixed(2)} €',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: farbe.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Zum Warenkorb hinzufügen Button
            Expanded(
              child: FilledButton.icon(
                onPressed: _fuerWarenkorbHinzufuegen,
                icon: const Icon(Icons.shopping_cart_outlined),
                label: const Text('In den Warenkorb'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Berechnet den aktuellen Preis mit Rabatt
  double _getAktuellerPreis() {
    final rabatt = widget.produkt.produktRabatt;
    if (rabatt > 0) {
      return widget.produkt.preis * (1 - rabatt / 100);
    }
    return widget.produkt.preis;
  }

  /// Build für das Produktbild mit Platzhalter
  Widget _buildBildHeader() {
    final bildpfad = widget.produkt.bildpfad;
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Center(
            child: bildpfad != null && bildpfad.isNotEmpty
                ? Image.asset(
                    'assets/produktbilder/$bildpfad',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildBildPlatzhalter();
                    },
                  )
                : _buildBildPlatzhalter(),
          ),
        ),
      ),
    );
  }

  /// Build für den Bild-Platzhalter
  Widget _buildBildPlatzhalter() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.image_not_supported_outlined,
          size: 64,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 8),
        Text(
          'Kein Bild verfügbar',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    );
  }

  /// Fügt das Produkt zum Warenkorb hinzu
  void _fuerWarenkorbHinzufuegen() {
    final cartProvider = context.read<CartProvider>();
    cartProvider.addItem(widget.produkt, quantity: _menge);

    // Zeigt eine Bestätigungsnachricht
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.produkt.bezeichnung} (x$_menge) zum Warenkorb hinzugefügt!',
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Ansehen',
          textColor: Colors.white,
          onPressed: () {
            // TODO: Zur Warenkorb-Seite navigieren
          },
        ),
      ),
    );
  }
}

/// Produktdetail-Bildschirm für die Thriftshop-App
/// Zeigt Produktdetails und ermöglicht das Hinzufügen zum Warenkorb
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../services/kategorie_service.dart';
import '../../services/zustand_service.dart';
import '../../models/produkt.dart';

class ProduktDetailScreen extends StatefulWidget {
  final Produkt produkt;

  const ProduktDetailScreen({super.key, required this.produkt});

  @override
  State<ProduktDetailScreen> createState() => _ProduktDetailScreenState();
}

class _ProduktDetailScreenState extends State<ProduktDetailScreen> {
  int _menge = 1;
  bool _isFavorite = false;
  bool _isAddingToCart = false;

  @override
  Widget build(BuildContext context) {
    final zustandService = context.watch<ZustandService>();
    final kategorieService = context.watch<KategorieService>();

    final zustandName = zustandService.getZustandName(widget.produkt.zustandId);
    final zustandColor = zustandService.getZustandColor(
      widget.produkt.zustandId,
    );
    final kategorieName = kategorieService.getKategorieName(
      widget.produkt.kategorieId,
    );
    final rabattierterPreis = _berechneRabattiertenPreis();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produktdetails'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isFavorite
                        ? 'Zur Favoritenliste hinzugefügt'
                        : 'Aus Favoritenliste entfernt',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Produktbild-Platzhalter
          Container(
            height: 300,
            color: Colors.grey.shade200,
            child: const Center(
              child: Icon(Icons.image_outlined, size: 80, color: Colors.grey),
            ),
          ),
          // Scrollable product details
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategorie und Zustand
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            kategorieName,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (zustandName != 'Unbekannt')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: zustandColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              zustandName,
                              style: TextStyle(
                                fontSize: 13,
                                color: zustandColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Produktname
                    Text(
                      widget.produkt.bezeichnung,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Produkt-ID und Artikelnummer
                    Row(
                      children: [
                        Text(
                          'ID: ${widget.produkt.produktId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Art.-Nr: ${widget.produkt.produktnr}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Preis
                    if (widget.produkt.produktRabatt > 0)
                      Row(
                        children: [
                          Text(
                            '${rabattierterPreis.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B4513),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${widget.produkt.preis.toStringAsFixed(2)} €',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade500,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '-${widget.produkt.produktRabatt.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        '${widget.produkt.preis.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B4513),
                        ),
                      ),
                    const SizedBox(height: 24),
                    // Beschreibung
                    if (widget.produkt.produktInfo.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Beschreibung',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.produkt.produktInfo,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.5,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    // Produkt-Details
                    _buildDetailRow(
                      'Lagerbestand',
                      '${widget.produkt.lagerbestand} verfügbar',
                    ),
                    _buildDetailRow(
                      'Rabatt',
                      widget.produkt.produktRabatt > 0
                          ? '${widget.produkt.produktRabatt.toStringAsFixed(0)}%'
                          : 'Kein Rabatt',
                    ),
                    _buildDetailRow(
                      'Aktiv',
                      widget.produkt.produktAktiv ? 'Ja' : 'Nein',
                    ),
                    const SizedBox(height: 24),
                    // Menge-Auswahl
                    const Text(
                      'Menge',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Mengen-Steuerung
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: _menge > 1
                                    ? () => setState(() => _menge--)
                                    : null,
                                icon: const Icon(Icons.remove),
                                color: Color(0xFF8B4513),
                                disabledColor: Colors.grey.shade400,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                child: Text(
                                  '$_menge',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: _menge < widget.produkt.lagerbestand
                                    ? () => setState(() => _menge++)
                                    : null,
                                icon: const Icon(Icons.add),
                                color: Color(0xFF8B4513),
                                disabledColor: Colors.grey.shade400,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Gesamtpreis
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gesamtpreis',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(_berechneRabattiertenPreis() * _menge).toStringAsFixed(2)} €',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF8B4513),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          // Fixed bottom button
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: _isAddingToCart ? null : _addToCart,
              icon: _isAddingToCart
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Icon(Icons.shopping_cart),
              label: const Text(
                'In den Warenkorb',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8B4513),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  double _berechneRabattiertenPreis() {
    if (widget.produkt.produktRabatt <= 0) {
      return widget.produkt.preis;
    }
    final rabatt = widget.produkt.preis * (widget.produkt.produktRabatt / 100);
    return widget.produkt.preis - rabatt;
  }

  Future<void> _addToCart() async {
    setState(() {
      _isAddingToCart = true;
    });

    try {
      // CartProvider aktualisieren
      final cartProvider = context.read<CartProvider>();
      cartProvider.addItem(widget.produkt, quantity: _menge);

      if (!mounted) return;

      // Erfolgsmeldung anzeigen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.produkt.bezeichnung} (${_menge}x) hinzugefügt',
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'Ansehen',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/warenkorb');
            },
          ),
        ),
      );

      // Zurück zur Produktliste
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAddingToCart = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Hinzufügen: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/// Bestell-Screen für Checkout-Prozess
/// Sammel Adressdaten, Zahlungsmethode und erstellt Bestellung via API

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/warenkorb_item.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../router.dart';

class BestellScreen extends StatefulWidget {
  final List<WarenkorbItem> items;
  final double gesamtpreis;

  const BestellScreen({
    super.key,
    required this.items,
    required this.gesamtpreis,
  });

  @override
  State<BestellScreen> createState() => _BestellScreenState();
}

class _BestellScreenState extends State<BestellScreen> {
  final _formKey = GlobalKey<FormState>();
  // ignore: unused_field
  String _adresse = '';
  // ignore: unused_field
  String _email = '';
  bool _bestellt = false;
  String? _fehler;

  final List<String> _zahlungsmethoden = [
    'Rechnung',
    'PayPal',
    'Kreditkarte',
    'SEPA-Lastschrift',
  ];
  String _zahlungsmethode = 'Rechnung';

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.benutzer != null) {
      _email = auth.benutzer!.email;
    }
  }

  Future<void> _bestellungAbsenden(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _bestellt = true;
      _fehler = null;
    });

    try {
      final orderProvider = context.read<OrderProvider>();
      
      await orderProvider.placeOrder(widget.items, widget.gesamtpreis);

      if (context.mounted) {
        context.read<CartProvider>().clearCart();
        
        // Erfolgs-Dialog anzeigen
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
            title: const Text('Bestellung erfolgreich!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Ihre Bestellung wurde erfolgreich aufgegeben.'),
                const SizedBox(height: 12),
                Text(
                  'Gesamtbetrag: ${widget.gesamtpreis.toStringAsFixed(2)} €',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    Routes.produktliste,
                    (route) => false,
                  );
                },
                child: const Text('Weiter einkaufen'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        setState(() {
          _fehler = 'Fehler: $e';
        });
      }
    } finally {
      if (context.mounted) {
        setState(() => _bestellt = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bestellung')),
        body: const Center(
          child: Text('Ihr Warenkorb ist leer.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bestellung aufgeben'),
      ),
      body: _bestellt
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _bauBestellungsUbersicht(context),
                    const SizedBox(height: 24),
                    _bauAdressFelder(context),
                    const SizedBox(height: 24),
                    _bauZahlungsmethode(context),
                    const SizedBox(height: 16),
                    if (_fehler != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: Colors.red.withValues(alpha: 0.1),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _fehler!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    ElevatedButton(
                      onPressed: () => _bestellungAbsenden(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: const Text(
                        'Kostenpflichtig bestellen',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _bauBestellungsUbersicht(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bestellübersicht',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            ...widget.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.produkt.bezeichnung} x ${item.menge}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    '${(item.produkt.preis * item.menge).toStringAsFixed(2)} €',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            )),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gesamtsumme',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${widget.gesamtpreis.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bauAdressFelder(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lieferadresse',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Straße, Hausnummer',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.home),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Bitte geben Sie Ihre Adresse ein';
            }
            return null;
          },
          onSaved: (value) => _adresse = value!,
        ),
        const SizedBox(height: 12),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'E-Mail',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Bitte geben Sie Ihre E-Mail ein';
            }
            if (!value.contains('@')) {
              return 'Ungültige E-Mail-Adresse';
            }
            return null;
          },
          onSaved: (value) => _email = value!,
        ),
      ],
    );
  }

  Widget _bauZahlungsmethode(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Zahlungsmethode',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _zahlungsmethode,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.payment),
          ),
          items: _zahlungsmethoden.map((methode) {
            return DropdownMenuItem(
              value: methode,
              child: Text(methode),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _zahlungsmethode = value);
            }
          },
        ),
      ],
    );
  }
}

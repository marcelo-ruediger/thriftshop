/// Warenkorb-Bildschirm für die Thriftshop-App
/// Zeigt alle Items im Warenkorb mit Mengenänderung und Gesamtpreis
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../router.dart';

class WarenkorbScreen extends StatelessWidget {
  const WarenkorbScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Warenkorb'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              if (cart.items.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  tooltip: 'Warenkorb leeren',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Warenkorb leeren?'),
                        content: const Text(
                          'Möchten Sie wirklich alle Artikel entfernen?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Abbrechen'),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<CartProvider>().clearCart();
                              Navigator.pop(context);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Warenkorb geleert'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            },
                            child: const Text(
                              'Leeren',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          final items = cart.items;

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 96,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Ihr Warenkorb ist leer',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Fügen Sie Produkte hinzu, um zu beginnen',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        Routes.produktliste,
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.shopping_bag),
                    label: const Text('Produkte ansehen'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: 50,
                            height: 50,
                            color: Theme.of(context).colorScheme.primaryContainer,
                            child: item.produkt.bildpfad != null
                                ? Image.asset(
                                    'assets/produktbilder/${item.produkt.bildpfad}',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.image_not_supported_outlined);
                                    },
                                  )
                                : const Icon(Icons.image_not_supported_outlined),
                          ),
                        ),
                        title: Text(
                          item.produkt.bezeichnung,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('ID: ${item.produkt.produktId}'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text('Menge: '),
                                SizedBox(
                                  width: 100,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                        onPressed: item.menge <= 1
                                            ? null
                                            : () {
                                                context
                                                    .read<CartProvider>()
                                                    .updateQuantity(
                                                      item.produkt.produktId,
                                                      item.menge - 1,
                                                    );
                                              },
                                      ),
                                      Expanded(
                                        child: Text(
                                          '${item.menge}',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                        ),
                                        onPressed:
                                            item.menge <
                                                item.produkt.lagerbestand
                                            ? () {
                                                context
                                                    .read<CartProvider>()
                                                    .updateQuantity(
                                                      item.produkt.produktId,
                                                      item.menge + 1,
                                                    );
                                              }
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${(item.produkt.preis * item.menge).toStringAsFixed(2)} €',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            context.read<CartProvider>().removeItem(
                              item.produkt.produktId,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Artikel entfernt'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Artikel:', style: TextStyle(fontSize: 16)),
                        Text(
                          '${cart.itemCount} (${items.length} verschiedene)',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Gesamtsumme:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${cart.totalPrice.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final auth = context.read<AuthProvider>();
                          if (!auth.isAuthenticated) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Bitte einloggen, um fortzufahren',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              Navigator.pushNamed(context, Routes.start);
                            }
                            return;
                          }

                          // Navigation zum Checkout
                          Navigator.pushNamed(
                            context,
                            Routes.bestell,
                            arguments: cart.items,
                          );
                        },
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('Zur Kasse'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

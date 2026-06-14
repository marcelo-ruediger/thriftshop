/// Produktliste-Bildschirm für die Thriftshop-App
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../router.dart';
import '../../services/kategorie_service.dart';
import '../../services/zustand_service.dart';
import '../../models/produkt.dart';
import 'produktdetail_screen.dart';

class ProduktListeScreen extends StatefulWidget {
  const ProduktListeScreen({super.key});

  @override
  State<ProduktListeScreen> createState() => _ProduktListeScreenState();
}

class _ProduktListeScreenState extends State<ProduktListeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Produkte beim ersten Laden laden
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = context.read<ProductProvider>();
      productProvider.loadProdukte();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produkte'),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.warenkorb);
                    },
                  ),
                  if (cartProvider.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          cartProvider.itemCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          return Column(
            children: [
              // Suchleiste
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SearchBar(
                  controller: _searchController,
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 16),
                  ),
                  leading: const Icon(Icons.search),
                  hintText: 'Produkte suchen...',
                  onSubmitted: (value) {
                    productProvider.filterBySearch(value);
                  },
                ),
              ),
              // Kategorie-Filter
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount:
                      productProvider.categories.length + 1, // +1 für "Alle"
                  itemBuilder: (context, index) {
                    final category = index == 0
                        ? 'Alle'
                        : productProvider.categories[index - 1];
                    final isSelected =
                        productProvider.selectedCategory == category;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            productProvider.filterByCategory(category);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              // Produkt-Grid
              Expanded(
                child: productProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : productProvider.errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              productProvider.errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => productProvider.loadProdukte(),
                              child: const Text('Erneut versuchen'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => productProvider.loadProdukte(),
                        child: productProvider.produkte.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.inventory_2_outlined,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      productProvider.searchQuery.isNotEmpty
                                          ? 'Keine Produkte für "${productProvider.searchQuery}" gefunden'
                                          : 'Keine Produkte gefunden',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2, // Zwei Spalten
                                      childAspectRatio:
                                          0.75, // Verhältnis von Breite zu Höhe
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                    ),
                                itemCount: productProvider.produkte.length,
                                itemBuilder: (context, index) {
                                  final produkt =
                                      productProvider.produkte[index];
                                  return _buildProduktCard(context, produkt);
                                },
                              ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProduktCard(BuildContext context, Produkt produkt) {
    final zustandService = context.watch<ZustandService>();

    final zustandName = zustandService.getZustandName(produkt.zustandId);
    final zustandColor = zustandService.getZustandColor(produkt.zustandId);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProduktDetailScreen(produkt: produkt),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Produktbild
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: _buildProduktbild(produkt),
              ),
            ),
            // Produktinformationen
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bezeichnung
                    Text(
                      produkt.bezeichnung,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Kategorie
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        context.read<KategorieService>().getKategorieName(
                          produkt.kategorieId,
                        ),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Zustand und Preis
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Zustand
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: zustandColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            zustandName,
                            style: TextStyle(fontSize: 10, color: zustandColor),
                          ),
                        ),
                        // Preis
                        Text(
                          '${produkt.preis.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF8B4513),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build für Produktbild in der Liste
  Widget _buildProduktbild(Produkt produkt) {
    final bildpfad = produkt.bildpfad;
    return Container(
      color: Colors.grey.shade200,
      child: bildpfad != null && bildpfad.isNotEmpty
          ? Image.asset(
              'assets/produktbilder/$bildpfad',
              fit: BoxFit.contain,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return _buildProduktbildPlatzhalter();
              },
            )
          : _buildProduktbildPlatzhalter(),
    );
  }

  /// Build für Produktbild-Platzhalter
  Widget _buildProduktbildPlatzhalter() {
    return Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 48,
        color: Colors.grey.shade400,
      ),
    );
  }

}

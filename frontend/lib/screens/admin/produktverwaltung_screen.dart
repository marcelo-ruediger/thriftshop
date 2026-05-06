/// Screen 7: Produktverwaltung (Admin)
/// CRUD-Operationen für Produkte
///
/// Dieses Screen ermöglicht die Verwaltung von Produkten
/// (Erstellen, Bearbeiten, Löschen) für Administratoren.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/produkt.dart';
import '../../models/kategorie.dart';
import '../../models/zustand.dart';
import '../../services/kategorie_service.dart';
import '../../services/zustand_service.dart';
import '../../router.dart';

class ProduktverwaltungScreen extends StatefulWidget {
  const ProduktverwaltungScreen({super.key});

  @override
  State<ProduktverwaltungScreen> createState() =>
      _ProduktverwaltungScreenState();
}

class _ProduktverwaltungScreenState extends State<ProduktverwaltungScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bezeichnungController = TextEditingController();
  final _produktInfoController = TextEditingController();
  final _preisController = TextEditingController();
  final _rabattController = TextEditingController();
  final _lagerbestandController = TextEditingController();
  final _produktnrController = TextEditingController();
  final _slugController = TextEditingController();

  Kategorie? _selectedKategorie;
  Zustand? _selectedZustand;
  bool _produktAktiv = true;
  Produkt? _bearbeitungsProdukt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = context.read<ProductProvider>();
      productProvider.loadProdukte();
    });
  }

  @override
  void dispose() {
    _bezeichnungController.dispose();
    _produktInfoController.dispose();
    _preisController.dispose();
    _rabattController.dispose();
    _lagerbestandController.dispose();
    _produktnrController.dispose();
    _slugController.dispose();
    super.dispose();
  }

  void _zeigeProduktDialog({Produkt? produkt}) {
    if (produkt != null) {
      // Edit-Modus
      setState(() {
        _bearbeitungsProdukt = produkt;
        _bezeichnungController.text = produkt.bezeichnung;
        _produktInfoController.text = produkt.produktInfo;
        _preisController.text = produkt.preis.toString();
        _rabattController.text = produkt.produktRabatt.toString();
        _lagerbestandController.text = produkt.lagerbestand.toString();
        _produktnrController.text = produkt.produktnr;
        _slugController.text = produkt.slug;
        _produktAktiv = produkt.produktAktiv;
      });
      // Kategorien und Zustände finden
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final kategorieService = context.read<KategorieService>();
        final zustandService = context.read<ZustandService>();
        setState(() {
          _selectedKategorie = kategorieService.kategorien.firstWhere(
            (k) => k.kategorieId == produkt.kategorieId,
            orElse: () => kategorieService.kategorien.first,
          );
          _selectedZustand = zustandService.zustaende.firstWhere(
            (z) => z.zustandId == produkt.zustandId,
            orElse: () => zustandService.zustaende.first,
          );
        });
      });
    } else {
      // Create-Modus
      setState(() {
        _bearbeitungsProdukt = null;
        _bezeichnungController.clear();
        _produktInfoController.clear();
        _preisController.clear();
        _rabattController.clear();
        _lagerbestandController.clear();
        _produktnrController.clear();
        _slugController.clear();
        _produktAktiv = true;
        _selectedKategorie = null;
        _selectedZustand = null;
      });
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          _bearbeitungsProdukt == null ? 'Neues Produkt' : 'Produkt bearbeiten',
        ),
        content: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bezeichnung
                  TextFormField(
                    controller: _bezeichnungController,
                    decoration: const InputDecoration(
                      labelText: 'Bezeichnung *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bitte geben Sie eine Bezeichnung ein';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  // Produktinfo
                  TextFormField(
                    controller: _produktInfoController,
                    decoration: const InputDecoration(
                      labelText: 'Produktinfo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.info_outline),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _preisController,
                          decoration: const InputDecoration(
                            labelText: 'Preis (€) *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Bitte geben Sie einen Preis ein';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Ungültiger Preis';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _rabattController,
                          decoration: const InputDecoration(
                            labelText: 'Rabatt (%)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.percent),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _lagerbestandController,
                          decoration: const InputDecoration(
                            labelText: 'Lagerbestand *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.inventory),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Bitte geben Sie einen Lagerbestand ein';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Ungültiger Lagerbestand';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _produktnrController,
                          decoration: const InputDecoration(
                            labelText: 'Produktnr',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.tag),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Kategorie Dropdown
                  DropdownButtonFormField<Kategorie>(
                    initialValue: _selectedKategorie,
                    decoration: const InputDecoration(
                      labelText: 'Kategorie *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: context.read<KategorieService>().kategorien.map((
                      kategorie,
                    ) {
                      return DropdownMenuItem(
                        value: kategorie,
                        child: Text(kategorie.bezeichnung),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedKategorie = value);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Bitte wählen Sie eine Kategorie';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  // Zustand Dropdown
                  DropdownButtonFormField<Zustand>(
                    initialValue: _selectedZustand,
                    decoration: const InputDecoration(
                      labelText: 'Zustand *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.star),
                    ),
                    items: context.read<ZustandService>().zustaende.map((
                      zustand,
                    ) {
                      return DropdownMenuItem(
                        value: zustand,
                        child: Text(zustand.bezeichnung),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedZustand = value);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Bitte wählen Sie einen Zustand';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  // Slug
                  TextFormField(
                    controller: _slugController,
                    decoration: const InputDecoration(
                      labelText: 'Slug',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Aktiv
                  SwitchListTile(
                    title: const Text('Produkt aktiv'),
                    value: _produktAktiv,
                    onChanged: (newValue) {
                      setState(() => _produktAktiv = newValue);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _bearbeitungsProdukt = null;
              });
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate() ||
                  _selectedKategorie == null ||
                  _selectedZustand == null) {
                return;
              }

              final produkt = Produkt(
                produktId: _bearbeitungsProdukt?.produktId ?? '',
                laufendeNr: _bearbeitungsProdukt?.laufendeNr ?? 0,
                bezeichnung: _bezeichnungController.text,
                slug: _slugController.text.isNotEmpty
                    ? _slugController.text
                    : _bezeichnungController.text.toLowerCase().replaceAll(
                        RegExp(r'[^a-z0-9äöüß]'),
                        '-',
                      ),
                produktInfo: _produktInfoController.text,
                preis: double.parse(_preisController.text),
                produktRabatt: double.tryParse(_rabattController.text) ?? 0,
                lagerbestand: int.parse(_lagerbestandController.text),
                zustandId: _selectedZustand!.zustandId,
                kategorieId: _selectedKategorie!.kategorieId,
                produktAktiv: _produktAktiv,
                produktnr: _produktnrController.text,
              );

              final productProvider = context.read<ProductProvider>();

              try {
                if (_bearbeitungsProdukt != null) {
                  // Update
                  final snackBar = const SnackBar(
                    content: Text('Produkt erfolgreich aktualisiert!'),
                    backgroundColor: Colors.green,
                  );
                  final dialogCtx = dialogContext;
                  await productProvider.updateProdukt(produkt);
                  if (mounted) {
                    Navigator.of(dialogCtx).pop();
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    scaffoldMessenger.showSnackBar(snackBar);
                  }
                } else {
                  // Create
                  final snackBar = const SnackBar(
                    content: Text('Produkt erfolgreich erstellt!'),
                    backgroundColor: Colors.green,
                  );
                  final dialogCtx = dialogContext;
                  await productProvider.createProdukt(produkt);
                  if (mounted) {
                    Navigator.of(dialogCtx).pop();
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    scaffoldMessenger.showSnackBar(snackBar);
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Fehler: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(
              _bearbeitungsProdukt == null ? 'Erstellen' : 'Speichern',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loescheProdukt(Produkt produkt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.delete_forever, color: Colors.red, size: 48),
        title: const Text('Produkt löschen?'),
        content: Text(
          'Sind Sie sicher, dass Sie "${produkt.bezeichnung}" löschen möchten?\n\n'
          'Diese Aktion kann nicht rückgängig gemacht werden.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final productProvider = context.read<ProductProvider>();
      try {
        await productProvider.deleteProdukt(produkt.produktId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produkt gelöscht'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fehler beim Löschen: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildProduktRow(Produkt produkt) {
    final kategorieService = context.read<KategorieService>();
    final zustandService = context.read<ZustandService>();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            produkt.bezeichnung[0],
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          produkt.bezeichnung,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                // Kategorie
                Chip(
                  label: Text(
                    kategorieService.getKategorieName(produkt.kategorieId),
                    style: const TextStyle(fontSize: 10),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 4),
                // Zustand
                Chip(
                  label: Text(
                    zustandService.getZustandName(produkt.zustandId),
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: zustandService
                      .getZustandColor(produkt.zustandId)
                      .withValues(alpha: 0.2),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Stand: ${DateFormat('dd.MM.yyyy').format(produkt.erstellungsdatum!)}',
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: produkt.produktAktiv
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                produkt.produktAktiv ? 'Aktiv' : 'Inaktiv',
                style: TextStyle(
                  fontSize: 12,
                  color: produkt.produktAktiv ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Bearbeiten
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _zeigeProduktDialog(produkt: produkt),
              tooltip: 'Bearbeiten',
            ),
            // Löschen
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _loescheProdukt(produkt),
              tooltip: 'Löschen',
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Produktinfo', produkt.produktInfo),
                _detailRow('Preis', '${produkt.preis.toStringAsFixed(2)} €'),
                _detailRow('Rabatt', '${produkt.produktRabatt}%'),
                _detailRow('Lagerbestand', '${produkt.lagerbestand}'),
                _detailRow('Produktnr', produkt.produktnr),
                _detailRow('Slug', produkt.slug),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Nur für Administratoren
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.benutzer == null ||
            authProvider.benutzer!.rolle != 'Administrator') {
          return Scaffold(
            appBar: AppBar(title: const Text('Produktverwaltung')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Zugriff verweigert',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Dieser Bereich ist nur für Administratoren'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil(Routes.start, (route) => false),
                    child: const Text('Zum Login'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Produktverwaltung'),
            actions: [
              // Refresh
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context.read<ProductProvider>().refresh(),
                tooltip: 'Aktualisieren',
              ),
              // Neues Produkt
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _zeigeProduktDialog(),
                tooltip: 'Neues Produkt',
                style: IconButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          body: Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              if (productProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (productProvider.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(productProvider.errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => productProvider.loadProdukte(),
                        child: const Text('Erneut versuchen'),
                      ),
                    ],
                  ),
                );
              }

              if (productProvider.produkte.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text('Keine Produkte vorhanden'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _zeigeProduktDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Neues Produkt erstellen'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => productProvider.loadProdukte(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: productProvider.produkte.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    return _buildProduktRow(productProvider.produkte[index]);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

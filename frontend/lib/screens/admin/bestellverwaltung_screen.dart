import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/bestellposition.dart';

class BestellverwaltungScreen extends StatefulWidget {
  const BestellverwaltungScreen({super.key});

  @override
  State<BestellverwaltungScreen> createState() =>
      _BestellverwaltungScreenState();
}

class _BestellverwaltungScreenState extends State<BestellverwaltungScreen> {
  // ignore: unused_field
  String? _selectedBestellungId;
  // ignore: unused_field
  List<Bestellposition>? _currentPositionen;
  String? _selectedStatus;

  final List<String> _statusFilter = [
    'Alle',
    'Offen',
    'In Bearbeitung',
    'Abgeschlossen',
    'Storniert',
    'Erstattet',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadAllBestellungen();
    });
  }

  Future<void> _refreshBestellungen() async {
    await context.read<OrderProvider>().loadAllBestellungen();
  }

  void _updateStatus(String bestellungId, String neuerStatus) async {
    context.read<OrderProvider>().updateStatus(bestellungId, neuerStatus);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status erfolgreich aktualisiert'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _zeigeBestellDetails(Map<String, dynamic> bestellung) {
    final bestellungId = bestellung['bestellung_id'] as String;

    setState(() {
      _selectedBestellungId = bestellungId;
      _currentPositionen = context
          .read<OrderProvider>()
          .selectedBestellungPositionen;
    });

    // Positionen laden
    context.read<OrderProvider>().loadBestellpositionen(bestellungId);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bestellung #${bestellung['laufende_nr']}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    // Status-Information
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('dd.MM.yyyy HH:mm').format(
                            DateTime.parse(
                              bestellung['bestelldatum'] as String,
                            ),
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Benutzer-ID: ${bestellung['benutzer_id']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    const Text(
                      'Bestellpositionen',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Positionen laden und anzeigen
                    FutureBuilder(
                      future: context
                          .read<OrderProvider>()
                          .loadBestellpositionen(bestellungId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final positionen =
                            context
                                .read<OrderProvider>()
                                .selectedBestellungPositionen ??
                            [];

                        if (positionen.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('Keine Positionen gefunden'),
                            ),
                          );
                        }

                        return Column(
                          children: positionen.map((pos) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text('Produkt-ID: ${pos.produktId}'),
                                subtitle: Text('Menge: ${pos.menge}'),
                                trailing: Text(
                                  '${pos.einzelpreisGebucht.toStringAsFixed(2)} €',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Status-Übersicht
                    const Text(
                      'Statusverwaltung',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusButtons(
                      bestellungId,
                      bestellung['status'] as String,
                      setModalState,
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Schließen'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusButtons(
    String bestellungId,
    String aktuellerStatus,
    StateSetter setModalState,
  ) {
    final erlaubteUebergaenge = _getErlaubteUebergaenge(aktuellerStatus);

    if (erlaubteUebergaenge.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'Keine weiteren Statusänderungen möglich',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: erlaubteUebergaenge.map((status) {
        return ElevatedButton(
          onPressed: () async {
            _updateStatus(bestellungId, status);
            if (mounted) {
              setModalState(() {});
            }
          },
          child: Text(status),
        );
      }).toList(),
    );
  }

  List<String> _getErlaubteUebergaenge(String aktuellerStatus) {
    switch (aktuellerStatus) {
      case 'Offen':
        return ['In Bearbeitung', 'Storniert'];
      case 'In Bearbeitung':
        return ['Abgeschlossen', 'Storniert'];
      case 'Abgeschlossen':
        return [];
      case 'Storniert':
        return ['Erstattet'];
      case 'Erstattet':
        return [];
      default:
        return [];
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Offen':
        return Colors.orange;
      case 'In Bearbeitung':
        return Colors.blue;
      case 'Abgeschlossen':
        return Colors.green;
      case 'Storniert':
        return Colors.red;
      case 'Erstattet':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getStatusIcon(String status) {
    switch (status) {
      case 'Offen':
        return '⏳';
      case 'In Bearbeitung':
        return '🔄';
      case 'Abgeschlossen':
        return '✅';
      case 'Storniert':
        return '❌';
      case 'Erstattet':
        return '💰';
      default:
        return '❓';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Admin-Zugriffskontrolle
    final authProvider = context.read<AuthProvider>();
    if (authProvider.benutzer == null ||
        (authProvider.benutzer!.rolle != 'Administrator' &&
            authProvider.benutzer!.rolle != 'Mitarbeiter')) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bestellverwaltung')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Zugriff verweigert',
                style: TextStyle(fontSize: 24, color: Colors.red),
              ),
              SizedBox(height: 8),
              Text(
                'Nur Administratoren und Mitarbeiter dürfen diesen Bereich nutzen',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bestellverwaltung'),
        actions: [
          // Refresh-Button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshBestellungen,
          ),
        ],
      ),
      body: Column(
        children: [
          // Status-Filter
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.brown[50],
            child: Row(
              children: [
                const Text(
                  'Filter:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedStatus,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: _statusFilter.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedStatus = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // Bestellungsliste
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, orderProvider, child) {
                // Ladezustand
                if (orderProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Fehler
                if (orderProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          orderProvider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _refreshBestellungen,
                          child: const Text('Erneut versuchen'),
                        ),
                      ],
                    ),
                  );
                }

                // Filtere Bestellungen nach Status
                // Filtere Bestellungen nach Status
                // Wenn _selectedStatus null ist (="Alle"), zeige alle Bestellungen
                final gefilterteBestellungen =
                    _selectedStatus == null || _selectedStatus == 'Alle'
                    ? orderProvider.allBestellungen
                    : orderProvider.allBestellungen
                        .where((bestellung) => bestellung['status'] == _selectedStatus)
                        .toList();

                // Leere Liste
                if (gefilterteBestellungen.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Keine Bestellungen gefunden',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  );
                }

                // Bestellungsliste
                return ListView.builder(
                  itemCount: gefilterteBestellungen.length,
                  itemBuilder: (context, index) {
                    final bestellung = gefilterteBestellungen[index];
                    final status = bestellung['status'] as String;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(status),
                          child: Text(
                            _getStatusIcon(status),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        title: Text(
                          'Bestellung #${bestellung['laufende_nr']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Datum: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(bestellung['bestelldatum'] as String))}',
                            ),
                            Text('Benutzer-ID: ${bestellung['benutzer_id']}'),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  status,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: _getStatusColor(status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _zeigeBestellDetails(bestellung),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Screen 5: Meine Bestellungen
/// Zeigt Bestellhistorie mit Status und Stornieren-Option
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';
import '../../router.dart';
import '../../models/bestellung.dart';

class MeineBestellungenScreen extends StatefulWidget {
  const MeineBestellungenScreen({super.key});

  @override
  State<MeineBestellungenScreen> createState() =>
      _MeineBestellungenScreenState();
}

class _MeineBestellungenScreenState extends State<MeineBestellungenScreen> {
  @override
  void initState() {
    super.initState();
    // Bestellungen laden
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadBestellungen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meine Bestellungen'),
        actions: [
          // Refresh-Button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<OrderProvider>().refresh();
            },
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
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
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    orderProvider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => orderProvider.loadBestellungen(),
                    child: const Text('Erneut versuchen'),
                  ),
                ],
              ),
            );
          }

          // Leere Liste
          if (orderProvider.bestellungen.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Noch keine Bestellungen vorhanden',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(Routes.produktliste);
                    },
                    child: const Text('Produkte ansehen'),
                  ),
                ],
              ),
            );
          }

          // Bestellungsliste
          return ListView.builder(
            itemCount: orderProvider.bestellungen.length,
            itemBuilder: (context, index) {
              final bestellung = orderProvider.bestellungen[index];
              return _buildBestellungCard(context, bestellung);
            },
          );
        },
      ),
    );
  }

  Widget _buildBestellungCard(BuildContext context, Bestellung bestellung) {
    // Status-Farbe
    Color statusFarbe;
    IconData statusIcon;
    switch (bestellung.status) {
      case 'Offen':
        statusFarbe = Colors.blue;
        statusIcon = Icons.pending;
        break;
      case 'In Bearbeitung':
        statusFarbe = Colors.orange;
        statusIcon = Icons.forward_to_inbox;
        break;
      case 'Abgeschlossen':
        statusFarbe = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Storniert':
        statusFarbe = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'Erstattet':
        statusFarbe = Colors.purple;
        statusIcon = Icons.restore;
        break;
      default:
        statusFarbe = Colors.grey;
        statusIcon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusFarbe,
          child: Icon(statusIcon, color: Colors.white),
        ),
        title: Text(
          'Bestellung #${bestellung.laufendeNr}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          bestellung.status,
          style: TextStyle(color: statusFarbe, fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  'Bestelldatum',
                  _formatDatum(bestellung.bestelldatum),
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Bestellnummer', bestellung.bestellungId),
                const SizedBox(height: 16),
                // Status-Informationen
                const Text(
                  'Status-Übersicht',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildStatusBadge(bestellung.status),
                const SizedBox(height: 16),
                // Aktion-Buttons
                if (bestellung.status == 'Offen' ||
                    bestellung.status == 'In Bearbeitung')
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              _zeigeStornoDialog(context, bestellung),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          child: const Text('Stornieren'),
                        ),
                      ),
                    ],
                  ),
                if (bestellung.status == 'Erstattet')
                  const Text(
                    'Diese Bestellung wurde erstattet.',
                    style: TextStyle(color: Colors.purple),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    return Chip(
      label: Text(status),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  String _formatDatum(DateTime datum) {
    final tage = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    final monate = [
      'Jan',
      'Feb',
      'Mär',
      'Apr',
      'Mai',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Okt',
      'Nov',
      'Dez',
    ];

    return '${tage[datum.weekday - 1]}, '
        '${datum.day}. ${monate[datum.month - 1]} ${datum.year} '
        '${datum.hour.toString().padLeft(2, '0')}:${datum.minute.toString().padLeft(2, '0')} Uhr';
  }

  void _zeigeStornoDialog(BuildContext context, Bestellung bestellung) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.warning_amber, color: Colors.orange, size: 64),
        title: const Text('Bestellung stornieren?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bestellung #${bestellung.laufendeNr}'),
            const SizedBox(height: 8),
            const Text(
              'Sind Sie sicher, dass Sie diese Bestellung stornieren möchten? '
              'Diese Aktion kann nicht rückgängig gemacht werden.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              try {
                await context.read<OrderProvider>().cancelOrder(
                  bestellung.bestellungId,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bestellung wurde storniert'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Fehler beim Stornieren: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Stornieren'),
          ),
        ],
      ),
    );
  }
}

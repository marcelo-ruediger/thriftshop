/// Screen 6: Profil
/// Zeigt und bearbeitet Benutzerprofil mit Logout und Account-Löschung

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../models/benutzer.dart';
import '../../router.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vornameController = TextEditingController();
  final _nachnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonController = TextEditingController();
  bool _bearbeitungsModus = false;

  @override
  void initState() {
    super.initState();
    // Benutzerdaten laden
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.benutzer != null) {
        _ladeBenutzerdaten(auth.benutzer!);
      }
    });
  }

  void _ladeBenutzerdaten(Benutzer benutzer) {
    _vornameController.text = benutzer.vorname;
    _nachnameController.text = benutzer.nachname;
    _emailController.text = benutzer.email;
    _telefonController.text = benutzer.telefonnummer;
  }

  Future<void> _profilSpeichern() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    if (auth.benutzer == null) return;

    // Benutzer-Objekt aktualisieren
    final aktualisierterBenutzer = Benutzer(
      benutzerId: auth.benutzer!.benutzerId,
      vorname: _vornameController.text,
      nachname: _nachnameController.text,
      email: _emailController.text,
      telefonnummer: _telefonController.text,
      passwortHash: auth.benutzer!.passwortHash,
      rolle: auth.benutzer!.rolle,
    );

    try {
      await auth.updateProfile(aktualisierterBenutzer);
      if (mounted) {
        setState(() => _bearbeitungsModus = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil erfolgreich gespeichert!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Speichern: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.logout, color: Colors.orange, size: 64),
        title: const Text('Abmelden'),
        content: const Text('Möchten Sie sich wirklich abmelden?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Abmelden'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<AuthProvider>().logout();
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(Routes.start, (route) => false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fehler beim Abmelden: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _kontoLoeschen() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.delete_forever, color: Colors.red, size: 64),
        title: const Text('Konto löschen?'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Achtung: Diese Aktion kann nicht rückgängig gemacht werden!',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Ihr gesamtes Profil und alle Bestellungen werden gelöscht.'),
          ],
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
            child: const Text('Endgültig löschen'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await context.read<AuthProvider>().deleteAccount();
        if (mounted) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(Routes.start, (route) => false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ihr Konto wurde gelöscht'),
              backgroundColor: Colors.red,
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

  @override
  void dispose() {
    _vornameController.dispose();
    _nachnameController.dispose();
    _emailController.dispose();
    _telefonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          // Bearbeitungs-Button
          IconButton(
            icon: Icon(_bearbeitungsModus ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                _bearbeitungsModus = !_bearbeitungsModus;
              });
              if (!_bearbeitungsModus) {
                // Werte zurücksetzen wenn abgebrochen wird
                _ladeBenutzerdaten(context.read<AuthProvider>().benutzer!);
              }
            },
            tooltip: _bearbeitungsModus ? 'Abbrechen' : 'Bearbeiten',
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Kein Benutzer eingeloggt
          if (authProvider.benutzer == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Bitte melden Sie sich an'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(Routes.start);
                    },
                    child: const Text('Zum Login'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profil-Avatar
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        child: Text(
                          '${authProvider.benutzer!.vorname[0]}${authProvider.benutzer!.nachname[0]}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      if (_bearbeitungsModus)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            child: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Rollen-Badge
                  Chip(
                    label: Text(authProvider.benutzer!.rolle),
                    backgroundColor:
                        authProvider.benutzer!.rolle == 'Administrator'
                        ? Colors.purple.withValues(alpha: 0.2)
                        : Colors.blue.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 32),

                  // Persönliche Daten
                  const Text(
                    'Persönliche Daten',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _vornameController,
                    decoration: const InputDecoration(
                      labelText: 'Vorname',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    enabled: _bearbeitungsModus,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bitte geben Sie Ihren Vornamen ein';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _nachnameController,
                    decoration: const InputDecoration(
                      labelText: 'Nachname',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    enabled: _bearbeitungsModus,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bitte geben Sie Ihren Nachnamen ein';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'E-Mail',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    enabled: _bearbeitungsModus,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Bitte geben Sie Ihre E-Mail ein';
                      }
                      if (!value.contains('@')) {
                        return 'Ungültige E-Mail-Adresse';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _telefonController,
                    decoration: const InputDecoration(
                      labelText: 'Telefonnummer',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    enabled: _bearbeitungsModus,
                  ),

                  const SizedBox(height: 32),

                  // Speichern-Button (nur im Bearbeitungsmodus)
                  if (_bearbeitungsModus) ...[
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() => _bearbeitungsModus = false);
                              // Werte zurücksetzen
                              _ladeBenutzerdaten(authProvider.benutzer!);
                            },
                            child: const Text('Abbrechen'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _profilSpeichern,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('Speichern'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Abmelden-Button
                  OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Abmelden'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Konto löschen (Gefahrenzone)
                  Card(
                    color: Colors.red.withValues(alpha: 0.05),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gefahrenzone',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Wenn Sie Ihr Konto löschen, werden alle Ihre Daten unwiderruflich gelöscht.',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _kontoLoeschen,
                              icon: const Icon(Icons.delete_forever),
                              label: const Text('Konto löschen'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

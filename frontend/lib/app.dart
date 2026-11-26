/// Wurzel-Widget: Theme, Lokalisierung und Router.
library;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'widgets/logo.dart';

class ThriftshopApp extends StatefulWidget {
  const ThriftshopApp({super.key});

  @override
  State<ThriftshopApp> createState() => _ThriftshopAppState();
}

class _ThriftshopAppState extends State<ThriftshopApp> {
  late final GoRouter _router = routerErstellen(context.read<AuthProvider>());

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bereit = context.select<AuthProvider, bool>((auth) => auth.bereit);

    return MaterialApp.router(
      title: 'Thriftshop Köln',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.hell,
      routerConfig: _router,
      locale: const Locale('de', 'DE'),
      supportedLocales: const [Locale('de', 'DE')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      // Bis die Sitzung wiederhergestellt ist, nur das Logo zeigen - so blitzt
      // keine geschützte Seite und kein Login-Formular kurz auf.
      builder: (context, child) => bereit ? child! : const _Startbildschirm(),
    );
  }
}

class _Startbildschirm extends StatelessWidget {
  const _Startbildschirm();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Logo(hoehe: 72, mitWortmarke: false),
            SizedBox(height: 24),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
}

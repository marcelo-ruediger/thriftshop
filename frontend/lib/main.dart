/// Hauptdatei für die Thriftshop-App
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'exports.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/profile_provider.dart';
import 'services/kategorie_service.dart';
import 'services/zustand_service.dart';
import 'widgets/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ThriftShopApp());
}

class ThriftShopApp extends StatelessWidget {
  const ThriftShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services (Singletons)
        Provider<KategorieService>(
          create: (_) => KategorieService()..loadKategorien(),
        ),
        Provider<ZustandService>(
          create: (_) => ZustandService()..loadZustaende(),
        ),
        // State Management (ChangeNotifiers)
        ChangeNotifierProvider(
          create: (_) {
            final provider = AuthProvider();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              provider.initialize();
            });
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: MaterialApp(
        title: 'ThriftShop',
        debugShowCheckedModeBanner: false,
        onGenerateRoute: RouteGenerator.generateRoute,
        initialRoute: Routes.start,
        routes: {
          Routes.start: (context) => const MainNavigation(),
          Routes.produktliste: (context) => const MainNavigation(),
          Routes.login: (context) => const LoginScreen(),
          Routes.registration: (context) => const RegistrationScreen(),
          Routes.produktdetail: (context) =>
              throw UnsupportedError('Use arguments'),
          Routes.warenkorb: (context) => const MainNavigation(),
          Routes.bestell: (context) => throw UnsupportedError('Use arguments'),
          Routes.profil: (context) => const MainNavigation(),
        },
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8B4513), // Braun als Hauptfarbe
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
          ),
        ),
      ),
    );
  }
}

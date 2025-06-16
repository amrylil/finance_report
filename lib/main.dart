import 'package:flutter/material.dart';
import 'package:laporan_keuangan_app/screens/add_transaksi_screen.dart';
import 'package:laporan_keuangan_app/screens/dompet/add_dompet_screen.dart';
import 'package:provider/provider.dart';

// Providers
import './providers/auth_provider.dart';
import './providers/transaksi_provider.dart';
import './providers/kategori_provider.dart';
import './providers/dompet_provider.dart';

// Screens
import './screens/login_screen.dart';
import './screens/register_screen.dart';
import './screens/splash_screen.dart';
import './screens/main_navigation_screen.dart';
// Import screen yang baru

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, TransaksiProvider>(
          create: (ctx) => TransaksiProvider(),
          update: (ctx, auth, previous) => previous!..authToken = auth.token,
        ),
        ChangeNotifierProxyProvider<AuthProvider, DompetProvider>(
          create: (ctx) => DompetProvider(),
          update: (ctx, auth, previous) => previous!..authToken = auth.token,
        ),
        ChangeNotifierProxyProvider<AuthProvider, KategoriProvider>(
          create: (ctx) => KategoriProvider(),
          update: (ctx, auth, previous) => previous!..authToken = auth.token,
        ),
      ],
      child: Consumer<AuthProvider>(
        builder:
            (ctx, auth, _) => MaterialApp(
              title: 'Laporan Keuangan',
              theme: ThemeData(
                primarySwatch: Colors.indigo,
                scaffoldBackgroundColor: Color(0xFFF4F6F8),
              ),
              home:
                  auth.isAuthenticated
                      ? MainNavigationScreen()
                      : FutureBuilder(
                        future: auth.tryAutoLogin(),
                        builder:
                            (ctx, snapshot) =>
                                snapshot.connectionState ==
                                        ConnectionState.waiting
                                    ? SplashScreen()
                                    : LoginScreen(),
                      ),
              routes: {
                RegisterScreen.routeName: (ctx) => RegisterScreen(),
                AddDompetScreen.routeName: (ctx) => AddDompetScreen(),
                // Tambahkan rute untuk halaman tambah transaksi di sini
                TambahTransaksiScreen.routeName:
                    (ctx) => TambahTransaksiScreen(),
              },
            ),
      ),
    );
  }
}

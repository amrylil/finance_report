import 'dart:io';

import 'package:flutter/material.dart';
import 'package:laporan_keuangan_app/http_overrides.dart';
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

void main() {
  HttpOverrides.global = MyHttpOverrides();
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
              title: 'Finance Report',
              theme: ThemeData(
                primarySwatch: Colors.indigo,
                scaffoldBackgroundColor: Color(0xFFF4F6F8),
                appBarTheme: AppBarTheme(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  centerTitle: true,
                  titleTextStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              home:
                  auth.isAuthenticated
                      ? AppWrapper()
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
                TambahTransaksiScreen.routeName:
                    (ctx) => TambahTransaksiScreen(),
              },
            ),
      ),
    );
  }
}

class AppWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 15,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Finance Report',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          Consumer<AuthProvider>(
            builder:
                (ctx, auth, _) => PopupMenuButton<String>(
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.person, color: Colors.white, size: 20),
                  ),
                  onSelected: (value) {
                    if (value == 'logout') {
                      _showLogoutDialog(context, auth);
                    } else if (value == 'profile') {
                      _showProfileInfo(context, auth);
                    }
                  },
                  itemBuilder:
                      (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'profile',
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: Colors.grey[700],
                              ),
                              SizedBox(width: 12),
                              Text('Profil'),
                            ],
                          ),
                        ),
                        PopupMenuDivider(),
                        PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, color: Colors.red),
                              SizedBox(width: 12),
                              Text(
                                'Keluar',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                ),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: MainNavigationScreen(),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 12),
              Text('Konfirmasi Keluar'),
            ],
          ),
          content: Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();

                // Show loading

                try {
                  await auth.logout();
                  Navigator.of(context).pop(); // Close loading dialog

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Berhasil keluar dari aplikasi'),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                } catch (error) {
                  Navigator.of(context).pop(); // Close loading dialog

                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error, color: Colors.white),
                          SizedBox(width: 12),
                          Expanded(child: Text('Gagal keluar: $error')),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Keluar'),
            ),
          ],
        );
      },
    );
  }

  void _showProfileInfo(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.indigo,
                child: Icon(Icons.person, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Informasi Profil'),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

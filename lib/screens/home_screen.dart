import 'package:flutter/material.dart';
import 'package:laporan_keuangan_app/screens/dompet/add_dompet_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaksi_provider.dart';
import '../providers/dompet_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late Future _dataFetchFuture;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    _dataFetchFuture = _fetchAllData();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllData() async {
    try {
      await Provider.of<TransaksiProvider>(
        context,
        listen: false,
      ).fetchAndSetTransaksi();
      await Provider.of<DompetProvider>(
        context,
        listen: false,
      ).fetchAndSetDompet();
    } catch (error) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.simpleCurrency(
      locale: 'id_ID',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FutureBuilder(
        future: _dataFetchFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          } else if (snapshot.error != null) {
            return _buildErrorState();
          } else {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: RefreshIndicator(
                onRefresh: () => _fetchAllData(),
                color: Colors.indigo,
                child: LayoutBuilder(
                  // Tambahkan LayoutBuilder untuk responsive
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          children: [
                            _buildHeaderSection(formatCurrency),
                            _buildContentSection(formatCurrency),
                            // Kurangi space untuk FAB
                            SizedBox(height: 80),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.indigo),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Memuat data keuangan...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Gagal memuat data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[800],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Periksa koneksi internet Anda',
              style: TextStyle(color: Colors.red[600]),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _dataFetchFuture = _fetchAllData();
                });
              },
              icon: Icon(Icons.refresh),
              label: Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(NumberFormat formatCurrency) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.indigo, Colors.indigo.shade400],
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Consumer<DompetProvider>(
              builder:
                  (ctx, dompetData, _) =>
                      _buildTotalSaldoCard(dompetData, formatCurrency),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 30),
            child: Consumer<TransaksiProvider>(
              builder:
                  (ctx, txData, _) =>
                      _buildRingkasanCard(txData, formatCurrency),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(NumberFormat formatCurrency) {
    return Container(
      child: Column(
        children: [
          SizedBox(height: 20),
          _buildSectionHeader('Dompet Saya', Icons.account_balance_wallet),
          Consumer<DompetProvider>(
            builder:
                (ctx, dompetData, _) =>
                    _buildDaftarDompet(dompetData, formatCurrency),
          ),
          SizedBox(height: 30),
          _buildSectionHeader('Transaksi Terbaru', Icons.receipt_long),
          Consumer<TransaksiProvider>(
            builder:
                (ctx, txData, _) =>
                    _buildDaftarTransaksi(txData, formatCurrency),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSaldoCard(DompetProvider data, NumberFormat format) {
    double totalSaldo = data.items.fold(
      0.0,
      (sum, dompet) => sum + dompet.saldoAwal,
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.white.withOpacity(0.95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance, color: Colors.indigo, size: 28),
              SizedBox(width: 12),
              Text(
                'Total Saldo',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            format.format(totalSaldo),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${data.items.length} Dompet Aktif',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildRingkasanCard(TransaksiProvider data, NumberFormat format) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: IntrinsicHeight(
        // Tambahkan IntrinsicHeight untuk konsistensi tinggi
        child: Row(
          children: [
            Expanded(
              child: _buildInfoKeuangan(
                'Pemasukan',
                data.totalPemasukan,
                Colors.green,
                Icons.trending_up,
                format,
              ),
            ),
            Container(width: 1, height: 40, color: Colors.grey[300]),
            Expanded(
              child: _buildInfoKeuangan(
                'Pengeluaran',
                data.totalPengeluaran,
                Colors.red,
                Icons.trending_down,
                format,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoKeuangan(
    String title,
    double amount,
    Color color,
    IconData icon,
    NumberFormat format,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        FittedBox(
          // Tambahkan FittedBox untuk text yang panjang
          child: Text(
            format.format(amount),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.indigo, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            // Tambahkan Expanded untuk mencegah overflow
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaftarDompet(DompetProvider data, NumberFormat format) {
    if (data.items.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 50,
              color: Colors.grey[400],
            ),
            SizedBox(height: 12),
            Text(
              'Belum ada dompet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Tambah dompet pertama Anda',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 140,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 15),
        scrollDirection: Axis.horizontal,
        itemCount: data.items.length,
        itemBuilder: (ctx, i) {
          final dompet = data.items[i];
          return Container(
            width: 160,
            margin: EdgeInsets.symmetric(horizontal: 5),
            child: Card(
              elevation: 8,
              shadowColor: Colors.indigo.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.indigo.shade50, Colors.indigo.shade100],
                  ),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: Colors.indigo,
                          size: 24,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Aktif',
                            style: TextStyle(
                              color: Colors.indigo,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dompet.nama,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo[800],
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        FittedBox(
                          // Tambahkan FittedBox untuk saldo
                          child: Text(
                            format.format(dompet.saldoAwal),
                            style: TextStyle(
                              color: Colors.indigo[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDaftarTransaksi(TransaksiProvider data, NumberFormat format) {
    if (data.items.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 50,
              color: Colors.grey[400],
            ),
            SizedBox(height: 12),
            Text(
              'Belum ada transaksi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            Text(
              'Transaksi Anda akan muncul di sini',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: data.items.length > 5 ? 5 : data.items.length,
        itemBuilder: (ctx, i) {
          final tx = data.items[i];
          final isPemasukan = tx.tipe == 'pemasukan';
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: 4,
              shadowColor: Colors.grey.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                        isPemasukan ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isPemasukan ? Icons.add_circle : Icons.remove_circle,
                    color: isPemasukan ? Colors.green : Colors.red,
                    size: 24,
                  ),
                ),
                title: Text(
                  tx.deskripsi,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1, // Batasi jumlah baris
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    tx.kategori.nama,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: FittedBox(
                  // Tambahkan FittedBox untuk trailing
                  child: Text(
                    '${isPemasukan ? '+' : '-'} ${format.format(tx.jumlah)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isPemasukan ? Colors.green : Colors.red,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

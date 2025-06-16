import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laporan_keuangan_app/screens/add_transaksi_screen.dart';
import 'package:provider/provider.dart';

import '../providers/transaksi_provider.dart';
import '../models/transaksi.dart';

class TransaksiListScreen extends StatefulWidget {
  @override
  _TransaksiListScreenState createState() => _TransaksiListScreenState();
}

class _TransaksiListScreenState extends State<TransaksiListScreen> {
  late Future<void> _transaksiFuture;

  @override
  void initState() {
    super.initState();
    _transaksiFuture =
        Provider.of<TransaksiProvider>(
          context,
          listen: false,
        ).fetchAndSetTransaksi();
  }

  Future<void> _refreshTransaksi(BuildContext context) async {
    setState(() {
      _transaksiFuture =
          Provider.of<TransaksiProvider>(
            context,
            listen: false,
          ).fetchAndSetTransaksi();
    });
  }

  // Menampilkan dialog konfirmasi penghapusan
  void _showDeleteConfirmDialog(String txId) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Anda yakin?'),
            content: Text(
              'Tindakan ini akan menghapus transaksi secara permanen.',
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Batal'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              TextButton(
                child: Text('Hapus', style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  try {
                    await Provider.of<TransaksiProvider>(
                      context,
                      listen: false,
                    ).deleteTransaksi(txId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Transaksi berhasil dihapus!')),
                    );
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal menghapus transaksi: $error'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
    );
  }

  // Widget untuk menampilkan ringkasan
  Widget _buildSummaryCard(double totalPemasukan, double totalPengeluaran) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Pemasukan',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  currencyFormatter.format(totalPemasukan),
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Pengeluaran',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  currencyFormatter.format(totalPengeluaran),
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan satu item transaksi
  Widget _buildTransactionItem(Transaksi tx) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final isPemasukan = tx.tipe == 'pemasukan';
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isPemasukan ? Colors.green.shade100 : Colors.red.shade100,
          child: Icon(
            isPemasukan ? Icons.arrow_upward : Icons.arrow_downward,
            color: isPemasukan ? Colors.green.shade800 : Colors.red.shade800,
            size: 24,
          ),
        ),
        title: Text(
          tx.deskripsi,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('d MMMM yyyy').format(tx.tanggal)),
            if (tx.kategori != null)
              Chip(
                label: Text(tx.kategori!.nama, style: TextStyle(fontSize: 12)),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
        trailing: SizedBox(
          width: 100,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.edit, color: Colors.grey[700]),
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    TambahTransaksiScreen.routeName,
                    arguments: tx, // Mengirim data transaksi ke halaman edit
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Theme.of(context).hintColor),
                onPressed: () => _showDeleteConfirmDialog(tx.id),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Transaksi'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder(
        future: _transaksiFuture,
        builder:
            (ctx, snapshot) =>
                snapshot.connectionState == ConnectionState.waiting
                    ? Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                      onRefresh: () => _refreshTransaksi(context),
                      child: Consumer<TransaksiProvider>(
                        builder:
                            (ctx, transaksiData, child) => Column(
                              children: [
                                _buildSummaryCard(
                                  transaksiData.totalPemasukan,
                                  transaksiData.totalPengeluaran,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0,
                                    vertical: 5.0,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Riwayat Transaksi',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.headlineMedium,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child:
                                      transaksiData.items.isEmpty
                                          ? Center(
                                            child: Text('Belum ada transaksi.'),
                                          )
                                          : ListView.builder(
                                            padding: EdgeInsets.only(
                                              bottom: 80,
                                            ),
                                            itemCount:
                                                transaksiData.items.length,
                                            itemBuilder:
                                                (ctx, i) =>
                                                    _buildTransactionItem(
                                                      transaksiData.items[i],
                                                    ),
                                          ),
                                ),
                              ],
                            ),
                      ),
                    ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi tanpa argumen berarti "mode tambah"
          Navigator.of(context).pushNamed(TambahTransaksiScreen.routeName);
        },
        child: Icon(Icons.add),
        tooltip: 'Tambah Transaksi',
      ),
    );
  }
}

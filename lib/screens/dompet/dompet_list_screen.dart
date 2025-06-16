import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:laporan_keuangan_app/models/dompet.dart';
import 'package:laporan_keuangan_app/providers/dompet_provider.dart';
import 'package:provider/provider.dart';

class DompetListScreen extends StatefulWidget {
  @override
  _DompetListScreenState createState() => _DompetListScreenState();
}

class _DompetListScreenState extends State<DompetListScreen> {
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<DompetProvider>(context, listen: false)
          .fetchAndSetDompet()
          .then((_) {
            setState(() {
              _isLoading = false;
            });
          })
          .catchError((error) {
            // Handle error jika diperlukan, misalnya menampilkan snackbar
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal memuat data dompet.')),
            );
          });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  // Menampilkan dialog untuk menambah atau mengedit dompet
  void _showAddOrEditDompetDialog({Dompet? dompet}) {
    final _formKey = GlobalKey<FormState>();
    final _namaController = TextEditingController(text: dompet?.nama);
    // Saldo sekarang bisa diedit
    final _saldoController = TextEditingController(
      text: dompet?.saldoAwal.toStringAsFixed(0) ?? '',
    );

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(dompet == null ? 'Tambah Dompet Baru' : 'Edit Dompet'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: _namaController,
                    decoration: InputDecoration(labelText: 'Nama Dompet'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama tidak boleh kosong.';
                      }
                      return null;
                    },
                  ),
                  // Field saldo sekarang selalu ditampilkan
                  TextFormField(
                    controller: _saldoController,
                    decoration: InputDecoration(
                      labelText: dompet == null ? 'Saldo Awal' : 'Saldo',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Saldo tidak boleh kosong.';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Masukkan angka yang valid.';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Batal'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              ElevatedButton(
                child: Text('Simpan'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final nama = _namaController.text;
                    final saldo = double.parse(_saldoController.text);
                    try {
                      final provider = Provider.of<DompetProvider>(
                        context,
                        listen: false,
                      );
                      if (dompet == null) {
                        // Tambah dompet baru
                        await provider.addDompet(nama, saldo);
                      } else {
                        // Update dompet yang ada dengan saldo baru
                        await provider.updateDompet(dompet.id, nama, saldo);
                      }
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Dompet berhasil disimpan!')),
                      );
                    } catch (error) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text('Gagal menyimpan dompet: $error'),
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
    );
  }

  // Menampilkan dialog konfirmasi penghapusan
  void _showDeleteConfirmDialog(String dompetId) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Anda yakin?'),
            content: Text('Apakah Anda ingin menghapus dompet ini?'),
            actions: <Widget>[
              TextButton(
                child: Text('Tidak'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              TextButton(
                child: Text('Ya', style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  try {
                    await Provider.of<DompetProvider>(
                      context,
                      listen: false,
                    ).deleteDompet(dompetId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Dompet berhasil dihapus!')),
                    );
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menghapus dompet: $error')),
                    );
                  }
                },
              ),
            ],
          ),
    );
  }

  // Widget untuk menampilkan satu item dompet
  Widget _buildDompetItem(Dompet dompet) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColorLight,
          child: Icon(
            Icons.account_balance_wallet_outlined,
            color: Theme.of(context).primaryColorDark,
          ),
        ),
        title: Text(dompet.nama, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          currencyFormatter.format(dompet.saldoAwal),
          style: TextStyle(color: Colors.grey[600], fontSize: 15),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit, color: Colors.grey[700]),
              onPressed: () => _showAddOrEditDompetDialog(dompet: dompet),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Theme.of(context).primaryColor),
              onPressed: () => _showDeleteConfirmDialog(dompet.id),
              tooltip: 'Hapus',
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Dompet'),
        automaticallyImplyLeading: false,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Consumer<DompetProvider>(
                builder:
                    (ctx, dompetData, child) =>
                        dompetData.items.isEmpty
                            ? Center(
                              child: Text(
                                'Belum ada dompet. Silakan tambahkan.',
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.only(
                                top: 10,
                                bottom: 80,
                              ),
                              itemCount: dompetData.items.length,
                              itemBuilder:
                                  (ctx, i) =>
                                      _buildDompetItem(dompetData.items[i]),
                            ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditDompetDialog(),
        child: Icon(Icons.add),
        tooltip: 'Tambah Dompet',
      ),
    );
  }
}

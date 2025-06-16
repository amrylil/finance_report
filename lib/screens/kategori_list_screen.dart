import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Asumsi path ini benar sesuai struktur proyek Anda
import '../providers/kategori_provider.dart';
import '../models/kategori.dart';

class KategoriListScreen extends StatefulWidget {
  @override
  _KategoriListScreenState createState() => _KategoriListScreenState();
}

class _KategoriListScreenState extends State<KategoriListScreen> {
  late Future<void> _kategoriFuture;

  @override
  void initState() {
    super.initState();
    // Panggil fetch data sekali saat widget pertama kali dibuat
    _kategoriFuture =
        Provider.of<KategoriProvider>(
          context,
          listen: false,
        ).fetchAndSetKategori();
  }

  // Fungsi untuk refresh data
  Future<void> _refreshKategori(BuildContext context) async {
    setState(() {
      _kategoriFuture =
          Provider.of<KategoriProvider>(
            context,
            listen: false,
          ).fetchAndSetKategori();
    });
  }

  // Menampilkan dialog untuk menambah atau mengedit kategori
  void _showAddOrEditKategoriDialog({Kategori? kategori}) {
    final _formKey = GlobalKey<FormState>();
    final _namaController = TextEditingController(text: kategori?.nama);
    String? _selectedTipe = kategori?.tipe ?? 'pengeluaran';

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(kategori == null ? 'Tambah Kategori' : 'Edit Kategori'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _namaController,
                    decoration: InputDecoration(labelText: 'Nama Kategori'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama tidak boleh kosong.';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedTipe,
                    decoration: InputDecoration(labelText: 'Tipe Kategori'),
                    items: [
                      DropdownMenuItem(
                        value: 'pengeluaran',
                        child: Text('Pengeluaran'),
                      ),
                      DropdownMenuItem(
                        value: 'pemasukan',
                        child: Text('Pemasukan'),
                      ),
                    ],
                    onChanged: (value) {
                      _selectedTipe = value;
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
                    final provider = Provider.of<KategoriProvider>(
                      context,
                      listen: false,
                    );
                    try {
                      if (kategori == null) {
                        await provider.addKategori(
                          nama: _namaController.text,
                          tipe: _selectedTipe!,
                        );
                      } else {
                        await provider.updateKategori(
                          id: kategori.id,
                          nama: _namaController.text,
                          tipe: _selectedTipe,
                        );
                      }
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Kategori berhasil disimpan!')),
                      );
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Gagal menyimpan kategori: $error'),
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
  void _showDeleteConfirmDialog(String kategoriId) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Anda yakin?'),
            content: Text('Apakah Anda ingin menghapus kategori ini?'),
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
                    await Provider.of<KategoriProvider>(
                      context,
                      listen: false,
                    ).deleteKategori(kategoriId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Kategori berhasil dihapus!')),
                    );
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal menghapus kategori: $error'),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
    );
  }

  // Widget untuk menampilkan satu item kategori
  Widget _buildKategoriItem(Kategori kategori) {
    final isPemasukan = kategori.tipe == 'pemasukan';
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              isPemasukan ? Colors.green.shade100 : Colors.red.shade100,
          child: Icon(
            isPemasukan
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            color: isPemasukan ? Colors.green.shade800 : Colors.red.shade800,
          ),
        ),
        title: Text(kategori.nama),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit, color: Colors.grey[700]),
              onPressed: () => _showAddOrEditKategoriDialog(kategori: kategori),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Theme.of(context).hintColor),
              onPressed: () => _showDeleteConfirmDialog(kategori.id),
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
        title: Text('Daftar Kategori'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder(
        future: _kategoriFuture,
        builder:
            (ctx, snapshot) =>
                snapshot.connectionState == ConnectionState.waiting
                    ? Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                      onRefresh: () => _refreshKategori(context),
                      child: Consumer<KategoriProvider>(
                        builder:
                            (ctx, kategoriData, child) =>
                                kategoriData.items.isEmpty
                                    ? Center(child: Text('Belum ada kategori.'))
                                    : ListView.builder(
                                      itemCount: kategoriData.items.length,
                                      itemBuilder:
                                          (ctx, i) => _buildKategoriItem(
                                            kategoriData.items[i],
                                          ),
                                    ),
                      ),
                    ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditKategoriDialog(),
        child: Icon(Icons.add),
        tooltip: 'Tambah Kategori',
      ),
    );
  }
}

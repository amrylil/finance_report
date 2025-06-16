import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Asumsi path ini benar sesuai struktur proyek Anda
import '../providers/kategori_provider.dart';
import '../models/kategori.dart';

class KategoriListScreen extends StatefulWidget {
  @override
  _KategoriListScreenState createState() => _KategoriListScreenState();
}

class _KategoriListScreenState extends State<KategoriListScreen>
    with TickerProviderStateMixin {
  late Future<void> _kategoriFuture;
  late AnimationController _animationController;
  late AnimationController _fabAnimationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    // Panggil fetch data sekali saat widget pertama kali dibuat
    _kategoriFuture =
        Provider.of<KategoriProvider>(
          context,
          listen: false,
        ).fetchAndSetKategori();

    _animationController.forward();
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
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
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Container(
              padding: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          kategori == null
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      kategori == null ? Icons.add_circle : Icons.edit,
                      color: kategori == null ? Colors.blue : Colors.orange,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    kategori == null ? 'Tambah Kategori' : 'Edit Kategori',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            content: Container(
              width: double.maxFinite,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextFormField(
                        controller: _namaController,
                        decoration: InputDecoration(
                          labelText: 'Nama Kategori',
                          prefixIcon: Icon(Icons.category, color: Colors.blue),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          labelStyle: TextStyle(color: Colors.grey[600]),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama tidak boleh kosong.';
                          }
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedTipe,
                        decoration: InputDecoration(
                          labelText: 'Tipe Kategori',
                          prefixIcon: Icon(
                            Icons.swap_vert,
                            color: Colors.purple,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          labelStyle: TextStyle(color: Colors.grey[600]),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'pengeluaran',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.arrow_downward,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text('Pengeluaran'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'pemasukan',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.arrow_upward,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text('Pemasukan'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          _selectedTipe = value;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  'Batal',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      kategori == null ? Colors.blue : Colors.orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.save, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Simpan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
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
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Kategori berhasil disimpan!'),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: EdgeInsets.all(16),
                        ),
                      );
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.error, color: Colors.white),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text('Gagal menyimpan kategori: $error'),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: EdgeInsets.all(16),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Konfirmasi Hapus',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              'Kategori ini akan dihapus secara permanen. Apakah Anda yakin?',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  'Tidak',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_forever, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Ya, Hapus',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  try {
                    await Provider.of<KategoriProvider>(
                      context,
                      listen: false,
                    ).deleteKategori(kategoriId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Kategori berhasil dihapus!'),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: EdgeInsets.all(16),
                      ),
                    );
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.error, color: Colors.white),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text('Gagal menghapus kategori: $error'),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: EdgeInsets.all(16),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
    );
  }

  // Widget untuk menampilkan header dengan statistik
  Widget _buildHeaderCard(List<Kategori> kategoris) {
    final totalKategori = kategoris.length;
    final kategoriPemasukan =
        kategoris.where((k) => k.tipe == 'pemasukan').length;
    final kategoriPengeluaran =
        kategoris.where((k) => k.tipe == 'pengeluaran').length;

    return Container(
      margin: EdgeInsets.fromLTRB(20, 20, 20, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade600, Colors.purple.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.category, color: Colors.white, size: 24),
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Kategori',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$totalKategori Kategori',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_upward,
                            color: Colors.green.shade200,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pemasukan',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '$kategoriPemasukan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_downward,
                            color: Colors.red.shade200,
                            size: 16,
                          ),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pengeluaran',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '$kategoriPengeluaran',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan satu item kategori
  Widget _buildKategoriItem(Kategori kategori, int index) {
    final isPemasukan = kategori.tipe == 'pemasukan';

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, 0.5),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                (index * 0.1).clamp(0.0, 1.0),
                ((index * 0.1) + 0.3).clamp(0.0, 1.0),
                curve: Curves.easeOutCubic,
              ),
            ),
          ),
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                (index * 0.1).clamp(0.0, 1.0),
                ((index * 0.1) + 0.5).clamp(0.0, 1.0),
                curve: Curves.easeOut,
              ),
            ),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: isPemasukan ? Colors.green : Colors.red,
                        width: 4,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Icon dengan gradient background
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors:
                                  isPemasukan
                                      ? [
                                        Colors.green.shade400,
                                        Colors.green.shade600,
                                      ]
                                      : [
                                        Colors.red.shade400,
                                        Colors.red.shade600,
                                      ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isPemasukan ? Colors.green : Colors.red)
                                    .withOpacity(0.3),
                                spreadRadius: 0,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            isPemasukan
                                ? Icons.trending_up
                                : Icons.trending_down,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kategori.nama,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              SizedBox(height: 4),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isPemasukan
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isPemasukan ? 'Pemasukan' : 'Pengeluaran',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        isPemasukan
                                            ? Colors.green.shade700
                                            : Colors.red.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Action buttons
                        Column(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(Icons.edit, size: 18),
                                color: Colors.orange.shade600,
                                onPressed:
                                    () => _showAddOrEditKategoriDialog(
                                      kategori: kategori,
                                    ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(Icons.delete, size: 18),
                                color: Colors.red.shade600,
                                onPressed:
                                    () => _showDeleteConfirmDialog(kategori.id),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Daftar Kategori',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder(
        future: _kategoriFuture,
        builder:
            (ctx, snapshot) =>
                snapshot.connectionState == ConnectionState.waiting
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.purple,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Memuat kategori...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: () => _refreshKategori(context),
                      color: Colors.purple,
                      child: Consumer<KategoriProvider>(
                        builder:
                            (ctx, kategoriData, child) => Column(
                              children: [
                                _buildHeaderCard(kategoriData.items),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    20,
                                    20,
                                    10,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.list_alt,
                                        color: Colors.grey[700],
                                        size: 24,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Daftar Kategori',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child:
                                      kategoriData.items.isEmpty
                                          ? Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.category_outlined,
                                                  size: 64,
                                                  color: Colors.grey[400],
                                                ),
                                                SizedBox(height: 16),
                                                Text(
                                                  'Belum ada kategori',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey[600],
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Tambahkan kategori pertama Anda',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                          : ListView.builder(
                                            padding: EdgeInsets.only(
                                              bottom: 100,
                                              top: 8,
                                            ),
                                            itemCount:
                                                kategoriData.items.length,
                                            itemBuilder:
                                                (ctx, i) => _buildKategoriItem(
                                                  kategoriData.items[i],
                                                  i,
                                                ),
                                          ),
                                ),
                              ],
                            ),
                      ),
                    ),
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _fabAnimationController,
          curve: Curves.elasticOut,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.purple.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3),
                spreadRadius: 0,
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => _showAddOrEditKategoriDialog(),
            child: Icon(Icons.add, size: 28),
            backgroundColor: Colors.transparent,
            elevation: 0,
            tooltip: 'Tambah Kategori',
          ),
        ),
      ),
    );
  }
}

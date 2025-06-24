import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transaksi.dart';
import '../providers/transaksi_provider.dart';
import '../providers/dompet_provider.dart';
import '../providers/kategori_provider.dart';

class TambahTransaksiScreen extends StatefulWidget {
  static const routeName = '/tambah-transaksi';

  @override
  _TambahTransaksiScreenState createState() => _TambahTransaksiScreenState();
}

class _TambahTransaksiScreenState extends State<TambahTransaksiScreen> {
  final _formKey = GlobalKey<FormState>();

  // State untuk menampung nilai-nilai form
  var _id = '';
  var _deskripsi = '';
  var _jumlah = 0.0;
  var _tipe = 'pengeluaran';
  var _tanggal = DateTime.now();
  String? _selectedKategoriId;
  String? _selectedDompetId;

  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final tx = ModalRoute.of(context)!.settings.arguments as Transaksi?;
      if (tx != null) {
        // Jika ini mode edit, isi state dengan data yang ada
        _id = tx.id;
        _deskripsi = tx.deskripsi;
        _jumlah = tx.jumlah;
        _tipe = tx.tipe;
        _tanggal = tx.tanggal;
        _selectedKategoriId = tx.kategori.id;
        _selectedDompetId = tx.dompet.id;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<TransaksiProvider>(context, listen: false);
      if (_id.isEmpty) {
        // Mode Tambah
        await provider.addTransaksi(
          deskripsi: _deskripsi,
          jumlah: _jumlah,
          tipe: _tipe,
          tanggal: _tanggal,
          idKategori: _selectedKategoriId!,
          idDompet: _selectedDompetId!,
        );
      } else {
        // Mode Edit
        await provider.updateTransaksi(
          id: _id,
          deskripsi: _deskripsi,
          jumlah: _jumlah,
          tipe: _tipe,
          tanggal: _tanggal,
          idKategori: _selectedKategoriId,
          idDompet: _selectedDompetId,
        );
      }
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text('Transaksi berhasil disimpan!'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Gagal menyimpan transaksi: $error')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _presentDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: _tipe == 'pemasukan' ? Colors.green : Colors.red,
            ),
          ),
          child: child!,
        );
      },
    ).then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _tanggal = pickedDate;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final dompetProvider = Provider.of<DompetProvider>(context, listen: false);
    final kategoriProvider = Provider.of<KategoriProvider>(
      context,
      listen: false,
    );

    final theme = Theme.of(context);
    final primaryColor = _tipe == 'pemasukan' ? Colors.green : Colors.red;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _id.isEmpty ? 'Tambah Transaksi' : 'Edit Transaksi',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Menyimpan transaksi...',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              )
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header Card dengan Tipe Transaksi
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
                          child: Column(
                            children: [
                              Icon(
                                _tipe == 'pemasukan'
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                                color: Colors.white,
                                size: 48,
                              ),
                              SizedBox(height: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ToggleButtons(
                                  isSelected: [
                                    _tipe == 'pengeluaran',
                                    _tipe == 'pemasukan',
                                  ],
                                  onPressed: (index) {
                                    setState(() {
                                      _tipe =
                                          index == 0
                                              ? 'pengeluaran'
                                              : 'pemasukan';
                                      _selectedKategoriId = null;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  selectedColor: primaryColor,
                                  fillColor: Colors.white,
                                  color: Colors.white,
                                  borderColor: Colors.transparent,
                                  selectedBorderColor: Colors.transparent,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.remove_circle_outline),
                                          SizedBox(width: 8),
                                          Text(
                                            'Pengeluaran',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.add_circle_outline),
                                          SizedBox(width: 8),
                                          Text(
                                            'Pemasukan',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Form Content
                      Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            // Deskripsi Field
                            _buildFormCard(
                              child: TextFormField(
                                initialValue: _deskripsi,
                                decoration: InputDecoration(
                                  labelText: 'Deskripsi Transaksi',
                                  prefixIcon: Icon(
                                    Icons.description,
                                    color: primaryColor,
                                  ),
                                  border: InputBorder.none,
                                  labelStyle: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                validator:
                                    (value) =>
                                        value!.isEmpty
                                            ? 'Deskripsi tidak boleh kosong.'
                                            : null,
                                onSaved: (value) => _deskripsi = value!,
                              ),
                            ),

                            SizedBox(height: 16),

                            // Jumlah Field
                            _buildFormCard(
                              child: TextFormField(
                                initialValue:
                                    _jumlah > 0
                                        ? _jumlah.toStringAsFixed(0)
                                        : '',
                                decoration: InputDecoration(
                                  labelText: 'Jumlah',
                                  prefixIcon: Icon(
                                    Icons.payments,
                                    color: primaryColor,
                                  ),
                                  prefixText: 'Rp ',
                                  border: InputBorder.none,
                                  labelStyle: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value!.isEmpty)
                                    return 'Jumlah tidak boleh kosong.';
                                  if (double.tryParse(value) == null)
                                    return 'Masukkan angka yang valid.';
                                  if (double.parse(value) <= 0)
                                    return 'Jumlah harus lebih dari 0.';
                                  return null;
                                },
                                onSaved:
                                    (value) => _jumlah = double.parse(value!),
                              ),
                            ),

                            SizedBox(height: 16),

                            // Dompet Dropdown
                            _buildFormCard(
                              child: DropdownButtonFormField<String>(
                                value: _selectedDompetId,
                                hint: Text(
                                  'Pilih Dompet',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Dompet',
                                  prefixIcon: Icon(
                                    Icons.wallet,
                                    color: primaryColor,
                                  ),
                                  border: InputBorder.none,
                                  labelStyle: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                items:
                                    dompetProvider.items.map((dompet) {
                                      return DropdownMenuItem(
                                        value: dompet.id,
                                        child: Text(dompet.nama),
                                      );
                                    }).toList(),
                                onChanged:
                                    (value) => setState(
                                      () => _selectedDompetId = value,
                                    ),
                                validator:
                                    (value) =>
                                        value == null
                                            ? 'Harap pilih dompet.'
                                            : null,
                              ),
                            ),

                            SizedBox(height: 16),

                            // Kategori Dropdown
                            _buildFormCard(
                              child: DropdownButtonFormField<String>(
                                value: _selectedKategoriId,
                                hint: Text(
                                  'Pilih Kategori',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Kategori',
                                  prefixIcon: Icon(
                                    Icons.category,
                                    color: primaryColor,
                                  ),
                                  border: InputBorder.none,
                                  labelStyle: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                items:
                                    kategoriProvider.items
                                        .where((kat) => kat.tipe == _tipe)
                                        .map((kategori) {
                                          return DropdownMenuItem(
                                            value: kategori.id,
                                            child: Text(kategori.nama),
                                          );
                                        })
                                        .toList(),
                                onChanged:
                                    (value) => setState(
                                      () => _selectedKategoriId = value,
                                    ),
                                validator:
                                    (value) =>
                                        value == null
                                            ? 'Harap pilih kategori.'
                                            : null,
                              ),
                            ),

                            SizedBox(height: 16),

                            // Date Picker Card
                            _buildFormCard(
                              child: InkWell(
                                onTap: _presentDatePicker,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        color: primaryColor,
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Tanggal Transaksi',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              DateFormat(
                                                'EEEE, d MMMM yyyy',
                                              ).format(_tanggal),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Colors.grey[400],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 32),

                            // Submit Button
                            Container(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _submitData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shadowColor: primaryColor.withOpacity(0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.save, size: 24),
                                    SizedBox(width: 12),
                                    Text(
                                      _id.isEmpty
                                          ? 'Simpan Transaksi'
                                          : 'Update Transaksi',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildFormCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: child,
    );
  }
}

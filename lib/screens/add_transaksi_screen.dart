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
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan transaksi: $error')),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_id.isEmpty ? 'Tambah Transaksi' : 'Edit Transaksi'),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextFormField(
                        initialValue: _deskripsi,
                        decoration: InputDecoration(labelText: 'Deskripsi'),
                        validator:
                            (value) =>
                                value!.isEmpty
                                    ? 'Deskripsi tidak boleh kosong.'
                                    : null,
                        onSaved: (value) => _deskripsi = value!,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        initialValue:
                            _jumlah > 0 ? _jumlah.toStringAsFixed(0) : '',
                        decoration: InputDecoration(
                          labelText: 'Jumlah',
                          prefixText: 'Rp ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty)
                            return 'Jumlah tidak boleh kosong.';
                          if (double.tryParse(value) == null)
                            return 'Masukkan angka yang valid.';
                          return null;
                        },
                        onSaved: (value) => _jumlah = double.parse(value!),
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _tipe,
                        decoration: InputDecoration(
                          labelText: 'Tipe Transaksi',
                        ),
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
                          setState(() {
                            _tipe = value!;
                            _selectedKategoriId =
                                null; // Reset pilihan kategori saat tipe berubah
                          });
                        },
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedDompetId,
                        hint: Text('Pilih Dompet'),
                        decoration: InputDecoration(labelText: 'Dompet'),
                        items:
                            dompetProvider.items.map((dompet) {
                              return DropdownMenuItem(
                                value: dompet.id,
                                child: Text(dompet.nama),
                              );
                            }).toList(),
                        onChanged:
                            (value) =>
                                setState(() => _selectedDompetId = value),
                        validator:
                            (value) =>
                                value == null ? 'Harap pilih dompet.' : null,
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedKategoriId,
                        hint: Text('Pilih Kategori'),
                        decoration: InputDecoration(labelText: 'Kategori'),
                        items:
                            kategoriProvider.items
                                .where(
                                  (kat) => kat.tipe == _tipe,
                                ) // Filter kategori sesuai tipe
                                .map((kategori) {
                                  return DropdownMenuItem(
                                    value: kategori.id,
                                    child: Text(kategori.nama),
                                  );
                                })
                                .toList(),
                        onChanged:
                            (value) =>
                                setState(() => _selectedKategoriId = value),
                        validator:
                            (value) =>
                                value == null ? 'Harap pilih kategori.' : null,
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Tanggal: ${DateFormat('d MMMM yyyy').format(_tanggal)}',
                            ),
                          ),
                          TextButton(
                            onPressed: _presentDatePicker,
                            child: Text(
                              'Pilih Tanggal',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _submitData,
                        child: Text('Simpan Transaksi'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}

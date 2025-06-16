import 'package:flutter/material.dart';
import '../models/transaksi.dart';
import '../services/transaksi_service.dart';

class TransaksiProvider with ChangeNotifier {
  final TransaksiService _transaksiService = TransaksiService();
  List<Transaksi> _items = [];
  bool _isLoading = false;
  String? authToken;

  List<Transaksi> get items => [..._items];
  bool get isLoading => _isLoading;

  double get totalPemasukan => _items
      .where((tx) => tx.tipe == 'pemasukan')
      .fold(0.0, (sum, item) => sum + item.jumlah);
  double get totalPengeluaran => _items
      .where((tx) => tx.tipe == 'pengeluaran')
      .fold(0.0, (sum, item) => sum + item.jumlah);

  Future<void> fetchAndSetTransaksi() async {
    if (authToken == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _transaksiService.fetchTransaksi(authToken!);
    } catch (error) {
      _items = [];
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaksi({
    required String deskripsi,
    required double jumlah,
    required String tipe,
    required DateTime tanggal,
    required String idKategori,
    required String idDompet,
  }) async {
    if (authToken == null) return;
    try {
      final newTransaksi = await _transaksiService.createTransaksi(
        token: authToken!,
        deskripsi: deskripsi,
        jumlah: jumlah,
        tipe: tipe,
        tanggal: tanggal,
        idKategori: idKategori,
        idDompet: idDompet,
      );
      _items.insert(0, newTransaksi); // Tambah di awal list agar muncul di atas
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateTransaksi({
    required String id,
    String? deskripsi,
    double? jumlah,
    String? tipe,
    DateTime? tanggal,
    String? idKategori,
    String? idDompet,
  }) async {
    if (authToken == null) return;
    final txIndex = _items.indexWhere((tx) => tx.id == id);
    if (txIndex >= 0) {
      try {
        final updatedTx = await _transaksiService.updateTransaksi(
          token: authToken!,
          id: id,
          deskripsi: deskripsi,
          jumlah: jumlah,
          tipe: tipe,
          tanggal: tanggal,
          idKategori: idKategori,
          idDompet: idDompet,
        );
        _items[txIndex] = updatedTx;
        notifyListeners();
      } catch (error) {
        rethrow;
      }
    }
  }

  Future<void> deleteTransaksi(String id) async {
    if (authToken == null) return;
    final existingTxIndex = _items.indexWhere((tx) => tx.id == id);
    Transaksi? existingTx = _items[existingTxIndex];
    _items.removeAt(existingTxIndex);
    notifyListeners();

    try {
      await _transaksiService.deleteTransaksi(authToken!, id);
      existingTx = null;
    } catch (error) {
      // Jika gagal, kembalikan transaksi ke list
      _items.insert(existingTxIndex, existingTx!);
      notifyListeners();
      rethrow;
    }
  }
}

import 'package:flutter/material.dart';
import '../models/dompet.dart';
import '../services/dompet_service.dart';

class DompetProvider with ChangeNotifier {
  final DompetService _dompetService = DompetService();
  List<Dompet> _items = [];
  String? authToken;

  List<Dompet> get items => [..._items];

  Future<void> fetchAndSetDompet() async {
    if (authToken == null) return;
    try {
      _items = await _dompetService.fetchDompet(authToken!);
      notifyListeners();
    } catch (error) {
      _items = [];
      // Sebaiknya rethrow error agar bisa ditangani di UI jika perlu
      rethrow;
    }
  }

  Future<void> addDompet(String nama, double saldoAwal) async {
    if (authToken == null) return;
    try {
      final newDompet = await _dompetService.createDompet(
        authToken!,
        nama,
        saldoAwal,
      );
      _items.add(newDompet);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateDompet(String id, String nama, double saldo) async {
    if (authToken == null) return;
    // Cari index dari dompet yang akan diupdate
    final dompetIndex = _items.indexWhere((dom) => dom.id == id);
    if (dompetIndex >= 0) {
      try {
        // Panggil service untuk update ke server
        final updatedDompet = await _dompetService.updateDompet(
          authToken!,
          id,
          nama,
          saldo,
        );
        // Perbarui item di list lokal
        _items[dompetIndex] = updatedDompet;
        notifyListeners();
      } catch (error) {
        rethrow;
      }
    }
  }

  Future<void> deleteDompet(String id) async {
    if (authToken == null) return;
    // Optimistic Deleting: hapus dari UI dulu
    final existingDompetIndex = _items.indexWhere((dom) => dom.id == id);
    Dompet? existingDompet = _items[existingDompetIndex];
    _items.removeAt(existingDompetIndex);
    notifyListeners();

    try {
      final success = await _dompetService.deleteDompet(authToken!, id);
      if (!success) {
        // Jika gagal, kembalikan dompet ke list
        _items.insert(existingDompetIndex, existingDompet);
        notifyListeners();
        // Beri pesan error
        throw Exception('Gagal menghapus dompet dari server.');
      }
      // Jika berhasil, null-kan referensi
      existingDompet = null;
    } catch (error) {
      // Jika terjadi error koneksi dll, kembalikan dompet
      _items.insert(existingDompetIndex, existingDompet!);
      notifyListeners();
      rethrow;
    }
  }
}

import 'package:flutter/material.dart';
import '../models/kategori.dart';
import '../services/kategori_service.dart';

class KategoriProvider with ChangeNotifier {
  final KategoriService _kategoriService = KategoriService();
  List<Kategori> _items = [];
  String? authToken;

  List<Kategori> get items => [..._items];

  Future<void> fetchAndSetKategori() async {
    if (authToken == null) return;
    try {
      _items = await _kategoriService.fetchKategori(authToken!);
      notifyListeners();
    } catch (error) {
      _items = [];
      rethrow; // Teruskan error agar bisa ditangani di UI
    }
  }

  Future<void> addKategori({required String nama, required String tipe}) async {
    if (authToken == null) return;
    try {
      final newKategori = await _kategoriService.createKategori(
        token: authToken!,
        nama: nama,
        tipe: tipe,
      );
      _items.add(newKategori);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateKategori({
    required String id,
    String? nama,
    String? tipe,
  }) async {
    if (authToken == null) return;
    final katIndex = _items.indexWhere((kat) => kat.id == id);
    if (katIndex >= 0) {
      try {
        final updatedKategori = await _kategoriService.updateKategori(
          token: authToken!,
          id: id,
          nama: nama,
          tipe: tipe,
        );
        _items[katIndex] = updatedKategori;
        notifyListeners();
      } catch (error) {
        rethrow;
      }
    }
  }

  Future<void> deleteKategori(String id) async {
    if (authToken == null) return;
    final existingKatIndex = _items.indexWhere((kat) => kat.id == id);
    Kategori? existingKategori = _items[existingKatIndex];
    // Optimistic Deleting: Hapus dari UI terlebih dahulu
    _items.removeAt(existingKatIndex);
    notifyListeners();

    try {
      await _kategoriService.deleteKategori(authToken!, id);
      existingKategori = null;
    } catch (error) {
      // Jika gagal, kembalikan data ke UI
      _items.insert(existingKatIndex, existingKategori!);
      notifyListeners();
      rethrow;
    }
  }
}

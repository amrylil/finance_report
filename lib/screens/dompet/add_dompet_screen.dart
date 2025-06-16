import 'package:flutter/material.dart';
import 'package:laporan_keuangan_app/providers/auth_provider.dart';
import 'package:laporan_keuangan_app/providers/dompet_provider.dart';
import 'package:provider/provider.dart';

class AddDompetScreen extends StatefulWidget {
  static const routeName = '/add-dompet';

  @override
  _AddDompetScreenState createState() => _AddDompetScreenState();
}

class _AddDompetScreenState extends State<AddDompetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _saldoController = TextEditingController();
  bool _isLoading = false;

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final token = Provider.of<AuthProvider>(context, listen: false).token;

    if (token == null) {
      _showErrorDialog('Token tidak ditemukan. Silakan login kembali.');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Panggil provider. Jika ada error, akan langsung loncat ke blok catch.
      await Provider.of<DompetProvider>(context, listen: false).addDompet(
        _namaController.text.trim(),
        double.parse(_saldoController.text),
      );

      // Jika kode mencapai baris ini, berarti sukses
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dompet berhasil ditambahkan!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      // Tangani error yang dilempar dari provider
      if (mounted) {
        _showErrorDialog('Gagal menambahkan dompet: ${error.toString()}');
      }
    } finally {
      // Pastikan loading state selalu dimatikan
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('Error'),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    _namaController.dispose();
    _saldoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Dompet Baru'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveForm,
            tooltip: 'Simpan Dompet',
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Menyimpan dompet...',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet,
                                  size: 64,
                                  color: Theme.of(context).primaryColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Informasi Dompet',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  controller: _namaController,
                                  decoration: InputDecoration(
                                    labelText: 'Nama Dompet',
                                    hintText: 'Contoh: Dompet Utama, Tabungan',
                                    prefixIcon: const Icon(Icons.label_outline),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                  ),
                                  textInputAction: TextInputAction.next,
                                  textCapitalization: TextCapitalization.words,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Nama dompet tidak boleh kosong';
                                    }
                                    if (value.trim().length < 3) {
                                      return 'Nama dompet minimal 3 karakter';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _saldoController,
                                  decoration: InputDecoration(
                                    labelText: 'Saldo Awal',
                                    hintText: '0',
                                    prefixIcon: const Icon(Icons.attach_money),
                                    prefixText: 'Rp ',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[50],
                                  ),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _saveForm(),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Saldo awal tidak boleh kosong';
                                    }
                                    final parsedValue = double.tryParse(value);
                                    if (parsedValue == null) {
                                      return 'Masukkan angka yang valid';
                                    }
                                    if (parsedValue < 0) {
                                      return 'Saldo tidak boleh negatif';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _saveForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Text('Menyimpan...'),
                                    ],
                                  )
                                  : const Text(
                                    'SIMPAN DOMPET',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}

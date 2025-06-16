import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:laporan_keuangan_app/models/dompet.dart';
import 'package:laporan_keuangan_app/providers/dompet_provider.dart';
import 'package:provider/provider.dart';

class DompetListScreen extends StatefulWidget {
  @override
  _DompetListScreenState createState() => _DompetListScreenState();
}

class _DompetListScreenState extends State<DompetListScreen>
    with TickerProviderStateMixin {
  var _isInit = true;
  var _isLoading = false;
  late AnimationController _animationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _fabScaleAnimation;

  final List<Color> _walletColors = [
    Colors.indigo,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.blue,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fabAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

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
            _animationController.forward();
            _fabAnimationController.forward();
          })
          .catchError((error) {
            setState(() {
              _isLoading = false;
            });
            _showErrorSnackBar('Gagal memuat data dompet.');
          });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showAddOrEditDompetDialog({Dompet? dompet}) {
    HapticFeedback.lightImpact();

    final _formKey = GlobalKey<FormState>();
    final _namaController = TextEditingController(text: dompet?.nama);
    final _saldoController = TextEditingController(
      text: dompet?.saldoAwal.toStringAsFixed(0) ?? '',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 16,
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.grey[50]!],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with icon
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          dompet == null ? Icons.add_card : Icons.edit,
                          color: Colors.indigo,
                          size: 28,
                        ),
                        SizedBox(width: 12),
                        Text(
                          dompet == null ? 'Tambah Dompet Baru' : 'Edit Dompet',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Nama Dompet Field
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: TextFormField(
                            controller: _namaController,
                            decoration: InputDecoration(
                              labelText: 'Nama Dompet',
                              prefixIcon: Icon(
                                Icons.account_balance_wallet,
                                color: Colors.indigo,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 16),

                        // Saldo Field
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: TextFormField(
                            controller: _saldoController,
                            decoration: InputDecoration(
                              labelText:
                                  dompet == null ? 'Saldo Awal' : 'Saldo',
                              prefixIcon: Icon(
                                Icons.attach_money,
                                color: Colors.green,
                              ),
                              prefixText: 'Rp ',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Saldo tidak boleh kosong';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Masukkan angka yang valid';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: Colors.grey[400]!),
                          ),
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
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
                                  await provider.addDompet(nama, saldo);
                                } else {
                                  await provider.updateDompet(
                                    dompet.id,
                                    nama,
                                    saldo,
                                  );
                                }
                                Navigator.of(ctx).pop();
                                _showSuccessSnackBar(
                                  'Dompet berhasil disimpan!',
                                );
                              } catch (error) {
                                _showErrorSnackBar(
                                  'Gagal menyimpan dompet: $error',
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Simpan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showDeleteConfirmDialog(String dompetId, String namaWallet) {
    HapticFeedback.mediumImpact();

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text('Konfirmasi Hapus'),
              ],
            ),
            content: Text(
              'Apakah Anda yakin ingin menghapus dompet "$namaWallet"?\n\nTindakan ini tidak dapat dibatalkan.',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'Batal',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  try {
                    await Provider.of<DompetProvider>(
                      context,
                      listen: false,
                    ).deleteDompet(dompetId);
                    _showSuccessSnackBar('Dompet berhasil dihapus!');
                  } catch (error) {
                    _showErrorSnackBar('Gagal menghapus dompet: $error');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Hapus',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildDompetItem(Dompet dompet, int index) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final color = _walletColors[index % _walletColors.length];

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * (index + 1)),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                elevation: 8,
                shadowColor: color.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, color.withOpacity(0.05)],
                    ),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(20),
                    leading: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [color, color.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      dompet.nama,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.grey[800],
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text(
                          currencyFormatter.format(dompet.saldoAwal),
                          style: TextStyle(
                            color: color,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Aktif',
                            style: TextStyle(
                              color: color,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.edit_outlined, color: color),
                            onPressed:
                                () =>
                                    _showAddOrEditDompetDialog(dompet: dompet),
                            tooltip: 'Edit Dompet',
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(Icons.delete_outline, color: Colors.red),
                            onPressed:
                                () => _showDeleteConfirmDialog(
                                  dompet.id,
                                  dompet.nama,
                                ),
                            tooltip: 'Hapus Dompet',
                          ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: Colors.indigo.shade300,
            ),
          ),
          SizedBox(height: 32),
          Text(
            'Belum Ada Dompet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Mulai kelola keuangan Anda dengan\nmenambahkan dompet pertama',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showAddOrEditDompetDialog(),
            icon: Icon(Icons.add),
            label: Text('Tambah Dompet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.indigo),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Memuat dompet...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigo,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dompet Saya',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Consumer<DompetProvider>(
                  builder:
                      (ctx, dompetData, _) => Text(
                        '${dompetData.items.length} Dompet',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? _buildLoadingState()
              : Consumer<DompetProvider>(
                builder:
                    (ctx, dompetData, child) =>
                        dompetData.items.isEmpty
                            ? _buildEmptyState()
                            : RefreshIndicator(
                              onRefresh: () async {
                                await Provider.of<DompetProvider>(
                                  context,
                                  listen: false,
                                ).fetchAndSetDompet();
                              },
                              color: Colors.indigo,
                              child: ListView.builder(
                                padding: EdgeInsets.only(top: 16, bottom: 100),
                                itemCount: dompetData.items.length,
                                itemBuilder:
                                    (ctx, i) => _buildDompetItem(
                                      dompetData.items[i],
                                      i,
                                    ),
                              ),
                            ),
              ),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.indigo.withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () => _showAddOrEditDompetDialog(),
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            elevation: 0,
            icon: Icon(Icons.add, size: 24),
            label: Text(
              'Tambah Dompet',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

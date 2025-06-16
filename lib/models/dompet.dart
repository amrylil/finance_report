class Dompet {
  final String id;
  final String nama;
  final double saldoAwal;

  Dompet({required this.id, required this.nama, required this.saldoAwal});

  factory Dompet.fromJson(Map<String, dynamic> json) {
    return Dompet(
      id: json['id'],
      nama: json['nama'],
      // Parsing 'saldo_awal' dari JSON API
      saldoAwal: double.parse(json['saldo_awal'].toString()),
    );
  }
}

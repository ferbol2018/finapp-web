class Movimiento {
  final int id;
  final double monto;
  final String tipo;
  final String descripcion;
  final String categoria;

  Movimiento({
    required this.id,
    required this.monto,
    required this.tipo,
    required this.descripcion,
    required this.categoria,
  });

  factory Movimiento.fromJson(Map<String, dynamic> json) {
    return Movimiento(
      id: json['id'],
      monto: (json['monto'] as num).toDouble(),
      tipo: json['tipo'],
      descripcion: json['descripcion'],
      categoria: json['categoria'],
    );
  }
}